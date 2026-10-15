# Delivery and Commerce Audit

**Audit date:** 2026-10-10  
**Scope:** Read-only review of the Flutter application in `agro_marketplace_`.  
**Repository documentation:** The root `README.md` is still the default Flutter starter document. No separate task-tracking or commerce design document was found.

## 1. Executive summary

The application has a working client-side skeleton for authentication, buyer/seller role routing, seller product CRUD, active-product browsing, a per-user cart, batched order document creation, buyer order-package display, and seller status updates. Firestore is the only observed commerce backend; no Cloud Functions source was found.

The requested delivery and commerce work is not yet implemented. In particular:

- “Fast Delivery” does not exist. The existing `DeliveryType` enum calls the option `instant`, not fast, and is not used by product, cart, checkout, or order code.
- Regular delivery is only represented by a default enum value; checkout always adds one fixed `AppConstants.deliveryFee`.
- Buyer checkout accepts one arbitrary free-text string and does not select or validate a saved delivery address.
- Cart quantity can be increased without rechecking product stock, and the cart screen has no quantity update controls.
- Checkout trusts cart item price, seller, product identity, and quantity; it performs no stock reservation/decrement.
- Order creation and cart clearing are separate operations, so a successful order can coexist with a failed cart clear or a retry-created duplicate.
- Firestore rules allow the authenticated buyer to create client-supplied order totals, items, seller assignments, addresses, and statuses. There is no server-side authority for these values.
- Order status vocabulary differs between Dart enums, UI, controller, and rules.

## 2. Existing architecture and relevant files

### Application layers

- **Bootstrap/configuration:** `lib/main.dart`, `lib/main_dev.dart`, `lib/app/bootstrap/bootstrap.dart`, `lib/shared/services/firebase_service.dart`, `firebase.json`.
- **Routing and role gates:** `lib/app/router/app_router.dart`, `lib/app/router/route_names.dart`.
- **Authentication/profile:** `lib/features/auth/data/auth_repository.dart`, `lib/features/auth/data/user_repository.dart`, `lib/features/auth/presentation/providers/auth_provider.dart`, `lib/features/auth/domain/entities/app_user.dart`.
- **Shared address/location:** `lib/shared/models/address.dart`, `lib/shared/models/detailed_address.dart`, `lib/shared/models/location.dart`, `lib/shared/services/geocoding_service.dart`.
- **Seller products:** `lib/features/seller_inventory/domain/entities/product.dart`, `product_image.dart`, `data/product_repository.dart`, `presentation/providers/product_form_controller.dart`, `inventory_providers.dart`, and the add/list screens.
- **Buyer browsing:** `lib/features/buyer_shopping/presentation/providers/shopping_providers.dart`, `search_providers.dart`, and the home/search/detail screens.
- **Cart:** `lib/features/buyer_shopping/domain/entities/cart_item.dart`, `data/cart_repository.dart`, `presentation/screens/cart_screen.dart`.
- **Checkout/orders:** `customer_order.dart`, `seller_order.dart`, `data/checkout_repository.dart`, `buyer_order_repository.dart`, `seller_order_repository.dart`, checkout/order providers and screens.
- **Security:** `firestore.rules`. No `functions/`, `functions/src/`, JavaScript, or TypeScript Cloud Functions source exists under the project.

The state-management pattern is Riverpod with generated providers. Repositories directly use `FirebaseFirestore`; there is no domain/service layer enforcing commerce invariants between UI and Firestore.

## 3. Current data model and Firestore layout

### Implemented collections/documents

| Collection/path | Observed data and owner | Code evidence |
|---|---|---|
| `users/{uid}` | `AppUser`: uid, email, role, profile/contact fields, one structured `address`, status and timestamps. | `auth/domain/entities/app_user.dart`, `auth/data/user_repository.dart` |
| `users/{uid}/cartItems/{itemId}` | Denormalized `CartItem`: product/seller IDs, name, price, unit, quantity, optional base64 image, addedAt. | `buyer_shopping/domain/entities/cart_item.dart`, `cart_repository.dart` |
| `products/{productId}` | `Product`: sellerId, name, description, price, unit, stockQuantity, category, optional brand, minOrderQuantity, attributes, images, status and timestamps. | `seller_inventory/domain/entities/product.dart`, `product_repository.dart` |
| `customerOrders/{orderId}` | `CustomerOrder`: buyerId, cart item snapshots, totalAmount, status, shippingAddress, timestamps; checkout additionally writes `sellerIds`. | `buyer_shopping/domain/entities/customer_order.dart`, `checkout_repository.dart` |
| `sellerOrders/{orderId}` | One denormalized package per seller: parentOrderId, buyerId, sellerId, item snapshots, seller total, status, shippingAddress, timestamps. | `seller_orders/domain/entities/seller_order.dart`, `checkout_repository.dart` |
| `supportRequests/{id}` | Support form payload; unrelated to commerce. | buyer/seller help screens and rules |

### Declared but not implemented commerce collections

`FirestorePaths` declares `sellerProfiles`, `sellerBusinessProfiles`, `sellerStores`, `sellerDeliveryProfiles`, `sellerDeliveryZones`, `inventory`, `inventoryTransactions`, discounts, notifications, and audit logs. No commerce repository writes or reads these collections. The seller business screen instead stores structured address/location fields in `users/{uid}`.

### Delivery/location capabilities

- `DetailedAddress` and `GeoLocation` support latitude, longitude and optional geohash.
- Seller business/profile screens can capture device location and reverse-geocode it into the user address.
- There is no buyer saved-address collection/list, no country code field, no delivery-zone query, no distance/coverage calculation, and no delivery setting persisted to a seller or order.
- `DeliveryType` contains `instant` and `regular`, but no production path references it.
- `AppConstants` contains a reservation expiry and default delivery radius, but no reservation or radius implementation uses them.

## 4. End-to-end journey traced

### Authentication and roles

1. Firebase Auth signs up/signs in in `auth_repository.dart`.
2. `AuthController.signUp` creates `users/{uid}` with a client-selected role.
3. `appUserProvider` streams that document and falls back to buyer if it is missing.
4. `app_router.dart` gates `/buyer/*` and `/seller/*` by the streamed role.
5. Profile screens can switch the role through `updateUserRole`.

The Firestore rule permits an owner to change `role` to either `buyer` or `seller`; there is no server-side role-transition policy or seller approval gate.

### Buyer and seller profiles/addresses

- `EditProfileScreen` and `BusinessSettingsScreen` update profile fields and a single `users/{uid}.address` map.
- The address can contain postal fields and optional coordinates.
- `BuyerProfileScreen` has profile/support/account actions but no saved-address management or address list.
- Checkout does not read the profile address; it starts with an empty text controller.

### Product creation and listing

1. Seller form validates required text, positive price, non-negative stock and MOQ >= 1 in `add_edit_product_screen.dart`.
2. `ProductFormController` constructs a product using the authenticated UID and writes it through `ProductRepository`.
3. Buyer provider queries `products` where `status == 'active'`, ordered by `createdAt`.
4. Search filters the already-loaded list by name/description and a fixed local category list.
5. Product detail reads only from the active-product stream and constructs a cart snapshot.

There is no repository/domain validation, seller delivery configuration, seller location join, pagination, server-side search, or stock-aware listing query. Active products with `stockQuantity == 0` remain in the buyer feed; only the detail add button is disabled.

### Cart and quantity flow

1. Product detail starts at quantity 1.
2. It clamps the requested quantity to MOQ and current displayed stock before calling `CartRepository.addToCart`.
3. The repository reads the existing cart document and adds the new quantity if the document exists.
4. Cart screen streams and displays items and total, supports deletion, but has no increment/decrement/update operation.

The repository’s existing-item path adds quantities without fetching the current product or checking stock. A stale product detail can also write a stale price/name/seller snapshot.

### Checkout and order creation

1. Cart screen navigates to `/buyer/cart/checkout`.
2. Checkout requires only non-empty free-text `shippingAddress`.
3. `CheckoutController` calculates `cartTotal + fixed deliveryFee`, creates a client UUID and `CustomerOrder(status: 'pending')`.
4. `CheckoutRepository.placeOrder` groups cart snapshots by seller and writes one parent order plus one top-level `sellerOrders` document per seller in a batch.
5. Only after that batch succeeds, the controller separately clears the cart.
6. Buyer order history reads `sellerOrders` filtered by `buyerId`; seller order history reads the same collection filtered by `sellerId`.

No payment fields or payment gateway flow exists. No stock transaction, reservation, product re-read, price recomputation, idempotency key, or delivery coverage check exists.

### Seller order management

- Seller order screens read `sellerOrders` and expose pending -> processing -> shipped -> delivered, with pending -> cancelled.
- `SellerOrderRepository.updateOrderStatus` first updates the seller order, then separately queries sibling seller orders and updates the parent status.
- The parent status is set to the requested seller status unless all packages are delivered.
- The rule and model support different status names from the UI and enum definitions.

## 5. Confirmed bugs and correctness gaps

The following are confirmed from the implementation, not assumptions:

| Severity | Evidence | Finding and impact |
|---|---|---|
| High | `firestore.rules` order create clauses; `checkout_repository.dart` writes client maps | An authenticated buyer can submit arbitrary item prices, totals, seller IDs, quantities, shipping address and initial status. Rules only verify `buyerId`; they do not verify product data, stock or totals. |
| High | `checkout_controller.dart` and `cart_repository.dart` | No stock is reserved or decremented. Two buyers can order the same stock, and a single buyer can order a quantity exceeding current stock through an existing cart item. |
| High | `checkout_repository.dart` followed by `checkout_controller.dart` | Order batch commit and cart clear are not atomic. Retry after a timeout can create duplicate orders; failure during clear leaves the order and cart together. |
| High | `firestore.rules` seller-order create/update clauses | A buyer can create a `sellerOrders` document with any `sellerId`. A seller can update any allowed status on their assigned package without a transition check. |
| High | `firestore.rules` customer-order update clause and `seller_order_repository.dart` | A seller listed in `sellerIds` can update the parent order directly, and the repository updates the child and parent in separate writes/reads, allowing inconsistent aggregate status under concurrency. |
| Medium | `product_repository.dart`, `shopping_providers.dart`, product detail | Buyer query filters only `status == active`; zero-stock products are listed. Detail prevents add only using the current stream snapshot. |
| Medium | `cart_repository.dart` | Existing cart quantities are incremented without product/stock validation. The UI has no quantity update operation, so users cannot correct a quantity except by deleting/re-adding. |
| Medium | `checkout_screen.dart`, `customer_order.dart`, `seller_order.dart` | Checkout accepts any non-empty string rather than a validated/saved address. Orders contain no structured address, delivery type, delivery fee breakdown, payment method/status, or country code. |
| Medium | `delivery_type.dart`, `app_constants.dart`, `firestore_paths.dart` | Delivery enums, radius and reservation constants, inventory paths, and delivery collections are declarations without a connected implementation. |
| Medium | `order_status.dart`, `firestore.rules`, checkout/seller screens | Status vocabularies are inconsistent: enum uses `placed`/`fulfilled` and seller `accepted`/`preparing`; controller/UI use `pending`/`processing`/`shipped`; rules allow `confirmed` and omit several enum values. This can cause invalid transitions, filtering errors and misleading displays. |
| Low | `product_detail_screen.dart` | Add-to-cart uses the active product stream rather than fetching the route product directly. If the product becomes inactive between stream updates, behavior is stale rather than authoritative. |
| Low | `buyer_order_repository.dart` and buyer order screens | Buyer history reads seller packages, not parent `customerOrders`; multi-seller checkout therefore appears as multiple orders/packages and route naming does not distinguish parent versus child order. |

## 6. Missing business rules and security controls

Before delivery/commerce implementation, the system needs explicit decisions and enforcement for:

1. Fast versus regular delivery names, eligibility, SLA, fee, seller cutoff/availability, and whether delivery is selected per cart, seller package, or product.
2. Structured buyer address schema, saved-address ownership, required fields, country/country code, coordinate accuracy, and seller-zone coverage.
3. Authoritative product price, seller identity, active status, MOQ and available stock at checkout.
4. Reservation/decrement/release semantics, expiration, cancellation/restock, and concurrent checkout behavior.
5. Payment method, payment status, amount authority, failed-payment recovery and refund state.
6. Parent-order versus seller-package status transitions and allowed actor for every transition.
7. Idempotent order creation and cart clearing.
8. Firestore rules or callable/server-side functions that prevent clients from writing trusted totals, prices, seller assignments, inventory changes and arbitrary order statuses.
9. Query/index strategy for listing/search/filtering, pagination and delivery-distance filtering.
10. Audit records for inventory and order status changes.

## 7. Proposed minimal implementation sequence

1. **Define canonical commerce contracts:** product availability, delivery types, address/order schema, payment fields, parent/package statuses and transition matrix.
2. **Add authoritative backend order path:** preferably callable Cloud Functions or another trusted server path to re-read products, validate seller/stock/coverage, calculate totals and create an idempotent order.
3. **Implement inventory reservation/decrement:** transaction or server-side atomic operation, reservation expiry/release, cancellation/restock and inventory audit records.
4. **Harden Firestore rules:** restrict direct order/inventory writes, validate immutable fields and actor-specific status transitions, and align collection paths with actual repositories.
5. **Implement buyer addresses and delivery selection:** saved address CRUD, structured validation, country code/coordinates as required, coverage checks, fast/regular options and fee/SLA display.
6. **Repair cart behavior:** authoritative product revalidation, MOQ/stock checks, quantity update controls, stale-price handling and clear-cart behavior after confirmed order creation.
7. **Align product listing/detail/search:** exclude unavailable stock, add required seller/delivery metadata, paginate if needed, and handle inactive/deleted route products.
8. **Align seller and buyer order views:** parent order versus seller package model, canonical status transitions, aggregate status calculation and concurrency-safe updates.
9. **Add focused tests and emulator/rules tests:** repositories/controllers, concurrency/idempotency, address/delivery rules, inventory, order totals, and unauthorized Firestore writes.

## 8. Dependencies and regression risks

### Dependencies

- Address validation and delivery selection depend on the final address/order schema.
- Checkout totals depend on delivery pricing and payment design.
- Stock reservation depends on the authoritative order path and product/inventory schema.
- Seller order management depends on the canonical status transition matrix and parent/package relationship.
- Firestore rules must be updated together with any new collections and trusted write path.
- UI changes should follow schema/backend changes to avoid writing unsupported legacy shapes.

### Regression risks

- Existing documents may contain legacy string addresses; `AddressJsonConverter` and `DetailedAddress` currently provide backward compatibility that must be retained during migration.
- Existing product and order documents use denormalized snapshots; changing price/status fields can break old order rendering.
- Buyer order history currently treats seller packages as orders; switching to parent orders can change counts, routes and detail behavior.
- Changing `pending` to `placed`/`confirmed` or adopting seller-specific statuses requires coordinated updates to rules, filters, dashboards and screens.
- Removing direct client order creation will require auth/error/loading UX for callable/backend failures.
- Tightening rules will expose existing direct writes and any missing indexes/claims.
- Moving from fixed `deliveryFee` to per-package delivery pricing changes displayed totals and seller totals.

## 9. Existing tests and missing coverage

The current test suite covers:

- Basic Firebase Auth repository success/failure/sign-out behavior.
- A fake Firestore connection.
- Geocoding value helpers.
- Generic `Result` and reusable validators.

The audit run executed the existing suite successfully: **15 tests passed**. `flutter analyze` completed with two pre-existing deprecation infos in `lib/app/bootstrap/bootstrap.dart`; no commerce-specific test failures were observed.

Missing tests include:

- Product repository serialization and active/out-of-stock listing behavior.
- Product form boundary cases (zero stock, MOQ greater than stock, invalid/overflow values).
- Cart add/update/remove, duplicate add, stale product, MOQ and stock enforcement.
- Checkout empty cart, validated address, delivery choice/fee, authoritative totals, payment failure and idempotent retry.
- Inventory reservation/decrement/release and concurrent buyers.
- Multi-seller parent/package creation and aggregate status transitions.
- Buyer/seller authorization and Firestore rules tests for forged totals, prices, seller IDs, statuses and cross-user reads/writes.
- Route behavior for deleted/inactive products and missing orders.
- Emulator tests for transactions, indexes and Cloud Function/callable order creation once introduced.

## 10. Exact files likely to change in Task 02

This is the expected Task 02 change surface, subject to the implementation design selected after approval:

- `agro_marketplace_/firestore.rules`
- `agro_marketplace_/lib/core/constants/firestore_paths.dart`
- `agro_marketplace_/lib/core/constants/app_constants.dart`
- `agro_marketplace_/lib/core/enums/delivery_type.dart`
- `agro_marketplace_/lib/core/enums/order_status.dart`
- `agro_marketplace_/lib/shared/models/address.dart`
- `agro_marketplace_/lib/shared/models/detailed_address.dart`
- `agro_marketplace_/lib/shared/models/location.dart`
- `agro_marketplace_/lib/features/auth/domain/entities/app_user.dart`
- `agro_marketplace_/lib/features/auth/data/user_repository.dart`
- `agro_marketplace_/lib/features/seller_inventory/domain/entities/product.dart`
- `agro_marketplace_/lib/features/seller_inventory/data/product_repository.dart`
- `agro_marketplace_/lib/features/seller_inventory/presentation/providers/product_form_controller.dart`
- `agro_marketplace_/lib/features/buyer_shopping/domain/entities/cart_item.dart`
- `agro_marketplace_/lib/features/buyer_shopping/domain/entities/customer_order.dart`
- `agro_marketplace_/lib/features/seller_orders/domain/entities/seller_order.dart`
- `agro_marketplace_/lib/features/buyer_shopping/data/cart_repository.dart`
- `agro_marketplace_/lib/features/buyer_shopping/data/checkout_repository.dart`
- `agro_marketplace_/lib/features/buyer_shopping/data/buyer_order_repository.dart`
- `agro_marketplace_/lib/features/seller_orders/data/seller_order_repository.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/providers/shopping_providers.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/providers/search_providers.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/providers/checkout_controller.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/screens/buyer_home_screen.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/screens/buyer_search_screen.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/screens/product_detail_screen.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/screens/cart_screen.dart`
- `agro_marketplace_/lib/features/buyer_shopping/presentation/screens/checkout_screen.dart`
- `agro_marketplace_/lib/features/buyer_profile/presentation/screens/buyer_profile_screen.dart`
- `agro_marketplace_/lib/features/seller_orders/presentation/providers/order_status_controller.dart`
- `agro_marketplace_/lib/features/seller_orders/presentation/screens/seller_order_detail_screen.dart`
- `agro_marketplace_/lib/app/router/app_router.dart` (only if address/order navigation needs new screens)
- New backend/function files under `agro_marketplace_/functions/` if trusted server-side order processing is approved.
- New focused tests under `agro_marketplace_/test/features/buyer_shopping/`, `test/features/seller_inventory/`, `test/features/seller_orders/`, and Firestore rules/emulator test locations.

No files outside the audit document were modified as part of this audit.

## Task 02 domain design

The approved minimum model changes are:

- `Address.countryCode`: optional in legacy records, normalized to uppercase ISO 3166-1 alpha-2 when present. Missing or malformed values fail Regular Delivery eligibility.
- `Product.supportsFastDelivery` and `Product.supportsRegularDelivery`: explicit opt-in flags defaulting to `false` for backward compatibility. Existing products therefore fail closed for the affected mode until migrated or edited.
- `Product.reservedQuantity` and `Product.soldQuantity`: integer counters defaulting to zero for legacy records. `availableQuantity` is `stockQuantity - reservedQuantity - soldQuantity`; negative counters and quantities are invalid.
- `AppUser.fastDeliveryEnabled`: seller-level explicit Fast Delivery opt-in, defaulting to `false`.
- Fast Delivery uses valid buyer and seller coordinates and a Haversine distance threshold of 60 km. Postal codes/text are not used for distance.
- Regular Delivery requires both normalized country codes to be present and equal, plus the product-level Regular Delivery opt-in. The domain layer does not promise a delivery date; the 1–7 day requirement remains a target policy for later shipping-capability implementation.

Pure rules are implemented in `lib/core/commerce/commerce_rules.dart` and covered by `test/core/commerce/commerce_rules_test.dart`. This task does not wire the rules into checkout, inventory writes, seller settings UI, Firestore rules, or order lifecycle.

### Migration requirements

No destructive migration is required. Existing product documents deserialize missing flags/counters as `false`/`0`, which is safe but intentionally makes delivery modes unavailable until explicit seller/product configuration is persisted. Existing addresses remain readable with a missing country code; they fail Regular Delivery until a normalized code is saved. A later migration may backfill country codes only from a trusted source and must not invent delivery opt-ins, coordinates, reservations, or sold quantities. Reservation/sold counters must be introduced with an authoritative transaction/backend before orders use them.

## Task 04 inventory implementation

Inventory values now fail closed:

- `Product` parsing maps missing, null, malformed, fractional, or nonnumeric stock values to an invalid sentinel rather than unlimited stock. Missing legacy reservation/sold counters remain zero; malformed values are invalid.
- `Product.isAvailableForPurchase` and `availabilityLabel` are used by buyer listing/detail surfaces.
- Seller product submission rejects negative stock, non-positive minimum order quantities, invalid prices, and malformed numeric input.
- Cart add and quantity-update operations use Firestore transactions to re-read the product and reject inactive, invalid, or insufficient inventory. Checkout re-reads every product before creating the existing order batch.
- Checkout retries reuse the pending order ID in the controller, so a retry does not intentionally create a second logical order ID.

The current repository still has no trusted Cloud Function or server-side order endpoint. Firestore rules allow buyers to create orders but do not allow buyers to mutate product inventory. Consequently, the client transaction checks do not provide authoritative concurrent checkout protection and do not decrement stock. The existing rules were intentionally not weakened. Task 05 (or a backend migration) must introduce a callable/server transaction that:

1. Re-reads product status and available inventory in one Firestore transaction.
2. Creates an idempotency record keyed by buyer and checkout request.
3. Reserves or decrements stock atomically before creating seller order documents.
4. Restores reservations on cancellation or failed payment and expires abandoned reservations.

Until that trusted path exists, concurrent purchases can still oversell and inventory restoration is not implemented. Existing product records require no destructive migration; invalid stock records remain visible only as unavailable and should be corrected by sellers or a reviewed data migration. No Firestore rules or Cloud Functions were changed in Task 04.

## Task 05 delivery-mode listing

Buyer home and search now share a Fast Delivery / Regular Delivery selector and a selected saved-address state. Listing eligibility is evaluated in `lib/core/commerce/product_listing_rules.dart` after the existing public active-product query:

- Fast Delivery requires valid available inventory, product support, seller-managed opt-in, valid buyer and seller coordinates, a configured delivery window no later than seven days, and distance at or below 60 km.
- Regular Delivery requires valid available inventory, product support, normalized matching buyer/seller country codes, and a configured delivery window between one and seven days.
- Missing seller capability metadata, missing coordinates, missing country codes, and invalid windows fail closed with an empty result and an explanatory location/listing message.
- Delivery windows are stored as product snapshots so buyers do not need access to private seller user documents. Seller product saves preserve existing delivery metadata and copy seller country/location and seller Fast Delivery opt-in from the configured seller profile when creating a product.

The Firestore query remains the existing `products.status == active` public query. Delivery filtering is client-side over public product capability snapshots; it does not read private seller documents or bypass security rules. Checkout re-evaluates the selected mode and address before creating the existing order batch. As documented for Task 04, authoritative reservation/decrement, cancellation restoration, expiration, and concurrency safety still require a trusted backend transaction.

## Task 06 seller delivery management

Seller delivery settings are stored in the existing owner-controlled `users/{uid}` document. The added fields are:

- `fastDeliveryEnabled` and `regularDeliveryEnabled`.
- `deliveryOrigin` (`GeoLocation`) and normalized two-letter `deliveryCountryCode`.
- Fast and Regular minimum/maximum delivery days, constrained to 1–7.
- Optional non-negative Fast and Regular delivery fees. Fees are persisted for later pricing work but are not yet added to order totals.

`DeliverySettingsScreen` is reachable from the seller dashboard and seller profile. It validates country code, coordinates, delivery windows, and fees before saving. The origin can be captured through the existing location service; unavailable permissions/services are reported without fabricating coordinates. Fast Delivery remains explicitly seller-managed; no courier integration is assumed.

Saving settings updates the seller document, then propagates the public delivery capability snapshot to that seller's products in batches of at most 500 writes. New products inherit the current settings. Existing products are not silently given invented capabilities; missing legacy fields fail closed. Propagation is intentionally non-atomic with the user write, and the UI reports propagation failures rather than hiding them. Checkout revalidates the selected mode against the product snapshot and selected buyer address. Orders now retain the selected delivery mode for seller order detail display.

No Firestore rules or Cloud Functions were changed. Existing rules already restrict `users/{uid}` writes to the owner and product writes to the owning seller. Trusted backend enforcement is still required for concurrent inventory reservation/decrement, durable idempotency, reservation expiration, cancellation/payment-failure restoration, and authoritative delivery-setting consistency.

### Task 06 migration and dependencies

No destructive migration is required. Legacy users/products deserialize the new settings as disabled or absent and therefore fail closed for the affected delivery mode. Sellers must configure a validated origin/country and explicitly enable each mode; a future migration may backfill country codes only from a trusted source. Delivery fees require a later decision before they can affect checkout totals. The seller order screen can display the persisted delivery mode, but complete delivery status transitions remain governed by the existing order lifecycle and backend limitations.

## Task 07 cart and checkout repair

Checkout now re-reads the buyer-owned cart, selected saved address, and every referenced product before creating orders. It rejects invalid or non-owned addresses, missing products, seller-ID mismatches, stale quantities, inactive or unavailable products, price changes that cannot be reconciled, and delivery-mode ineligibility. Cart prices, names, units, and seller IDs are rebuilt from current product documents rather than trusted from client cart snapshots.

The checkout quote is shared by the review UI and order write. It contains an authoritative merchandise subtotal, discount, tax, handling fee, delivery fee, and final total. The current business configuration has no implemented discount, tax, handling, or payment verifier, so those values are explicitly zero; the existing fixed delivery fee is charged once per parent checkout. The parent order stores each component and the final total. Seller orders remain split by seller and contain merchandise subtotals while retaining the parent delivery mode.

Repeated submissions are blocked in the controller and reuse the pending parent order ID. The repository treats an existing parent order for the same buyer as an idempotent success instead of creating duplicate seller packages. After successful order creation, only cart lines matching the pre-checkout snapshot are deleted; newly added or edited lines remain. Failed validation or batch writes leave the cart unchanged. Orders remain `pending` with `paymentStatus: pending`; no order is marked paid because no payment verification flow exists.

No Firestore rules or Cloud Functions were changed. The batch prevents partial parent/seller writes, but it is not a trusted inventory transaction: products are only re-read and not decremented because buyer writes are prohibited by the current rules. Concurrent checkouts can still oversell, and durable cross-device idempotency, stock reservation/restoration, and verified payment remain backend dependencies.

## Task 08 order and delivery lifecycle

The existing order architecture remains one `customerOrders/{orderId}` parent checkout plus one `sellerOrders/{sellerOrderId}` package per seller. Each seller package retains `parentOrderId`, buyer/seller IDs, item snapshots with verified current product prices, seller merchandise total, selected delivery mode, payment state, and a frozen delivery estimate. The parent order additionally stores the delivery-address snapshot and aggregate charge fields. Multi-seller carts therefore produce one customer checkout with related seller packages rather than unrelated customer orders.

Seller delivery status transitions are centralized in `lib/core/commerce/order_lifecycle.dart`:

| Current | Allowed next states | Responsible actor |
|---|---|---|
| `pending` | `accepted`, `rejected`, `cancelled` | Assigned seller |
| `accepted` | `preparing`, `cancelled` | Assigned seller |
| `preparing` | `packed`, `cancelled` | Assigned seller |
| `packed` | `ready` | Assigned seller |
| `ready` | `dispatched` | Assigned seller |
| `dispatched` | `delivered` | Assigned seller |

The seller repository validates the transition again inside a Firestore transaction, preventing two concurrent seller actions from advancing the same package from the same prior state. Parent status is recalculated from all seller-package statuses after the package update. No live tracking is claimed; Fast Delivery remains seller-managed and Regular Delivery remains seller-managed because no shipping integration exists.

Firestore rules now protect trusted order fields after creation and restrict seller status updates to `status` and `updatedAt` with the same lifecycle transitions. Buyer reads remain limited to orders whose `buyerId` matches the authenticated user; seller reads and updates remain limited to packages whose `sellerId` matches the authenticated seller.

Cancellation is currently limited to seller cancellation before dispatch. Stock restoration is not implemented because checkout still does not reserve/decrement inventory and no trusted backend or reservation collection exists. Payment remains `pending`; no client may mark an order paid. Direct client order creation still means Firestore rules cannot independently verify every item price and seller assignment against product documents. A trusted callable function or server-triggered workflow remains required for production-grade authoritative order creation, atomic stock mutation, durable idempotency, payment verification, cancellation restoration, and failed-delivery handling.
