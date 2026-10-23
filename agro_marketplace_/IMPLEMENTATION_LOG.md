# Implementation Log

## Increment 01 — Canonical commerce schema

**Date:** 2026-10-22  
**Status:** Design complete; implementation pending  
**Scope:** Defined the canonical order, inventory reservation, payment, status, idempotency, trusted checkout, authorization, and migration contract. No application code or Firebase configuration was changed.

### Created

- [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md)

### Decisions

- Firebase callable/HTTP Cloud Functions with Admin SDK are the target trusted checkout boundary.
- One parent customer order and one seller package per seller are retained.
- Authoritative money uses integer minor units and explicit currency.
- Checkout uses durable server-owned idempotency records.
- Inventory uses explicit reservation documents and protected counters.
- Payment, order, seller fulfilment, and delivery concerns have separate ownership and statuses.
- Immutable order item and address snapshots preserve historical accuracy.

### Not implemented

- No Cloud Functions directory was added.
- No Firestore rules, models, checkout repository, UI, or dependencies were changed.
- No schema migration or production deployment was performed.

### Next recommended increment

Implement the trusted checkout foundation and emulator security tests. Keep the existing client checkout path unchanged until the new backend contract is deployed and verified.

## Increment 03 — Buyer self-listing exclusion and delivery tracking UI

**Date:** 2026-10-22  
**Status:** UI/domain integration complete; transport-provider integration pending

### Files changed

- [`lib/features/buyer_shopping/presentation/providers/shopping_providers.dart`](./lib/features/buyer_shopping/presentation/providers/shopping_providers.dart)
- [`lib/features/buyer_shopping/presentation/screens/product_detail_screen.dart`](./lib/features/buyer_shopping/presentation/screens/product_detail_screen.dart)
- [`lib/features/buyer_shopping/presentation/screens/buyer_orders_screen.dart`](./lib/features/buyer_shopping/presentation/screens/buyer_orders_screen.dart)
- [`lib/features/buyer_shopping/presentation/screens/buyer_order_detail_screen.dart`](./lib/features/buyer_shopping/presentation/screens/buyer_order_detail_screen.dart)
- [`lib/features/seller_orders/presentation/screens/seller_order_detail_screen.dart`](./lib/features/seller_orders/presentation/screens/seller_order_detail_screen.dart)
- [`lib/core/widgets/order_status_timeline.dart`](./lib/core/widgets/order_status_timeline.dart)
- [`lib/core/widgets/delivery_details_card.dart`](./lib/core/widgets/delivery_details_card.dart)

### Implemented

- Products whose `sellerId` matches the authenticated user are excluded from buyer listings after role switching.
- Product detail and add-to-cart paths also reject a seller's own product, preventing deep-link bypass.
- Added a shared delivery progress line for pending, accepted, preparing, packed, ready, dispatched, and delivered.
- Added cancellation/rejection visualization.
- Added delivery mode, estimate, current stage, destination, and transport-information presentation.
- Updated buyer order tabs to recognize the current lifecycle statuses.

### Limitations

- The current schema has no transport assignment fields or supported courier integration. The delivery card intentionally says live vehicle tracking is unavailable instead of inventing driver or vehicle data.
- Adding vehicle/driver/tracking details requires a trusted seller delivery-assignment schema and security-rule/backend changes; it is the next delivery-module increment.

### Verification

- Targeted Flutter analyzer: **No issues found**.
- Full Flutter suite: **42 tests passed**.
- `git diff --check`: passed.

## Increment 04 — Trusted transport assignment and delivery stages

**Date:** 2026-10-22  
**Status:** Backend contract, seller UI actions, and tracking projection implemented

### Implemented

- Added `assignSellerTransport` callable Function.
- Added `updateSellerDeliveryStage` callable Function.
- Transport assignment requires seller ownership and an accepted/preparing/packed/ready package.
- Fast orders require `seller_managed_fast` transport.
- Driver name, optional phone, vehicle type, and vehicle number are validated.
- Delivery stages are validated through a trusted transition matrix.
- Every assignment and stage change appends an `orderEvents` record.
- Current `transportAssignment` and `deliveryStage` are stored on `sellerOrders`, allowing buyers to track the authoritative projection.
- Schema-versioned direct client updates are denied in Firestore rules.
- Flutter seller-order model and buyer/seller detail cards now display assignment details and delivery stage without claiming live GPS tracking.
- Added the Flutter `cloud_functions` dependency and wired seller actions to the regional callable Functions.
- Added seller transport assignment dialog and delivery controls for pickup, in-transit, and delivered stages.
- Added emulator authorization coverage for buyer tracking reads, cross-buyer isolation, and direct transport mutation denial.

### Not implemented

- No third-party courier integration.
- No GPS coordinates or live map tracking.
- Existing legacy seller status controls remain separate from the trusted schema-v2 lifecycle and must be migrated before production cutover.
- Reservation release/commit and payment workflows remain separate blockers.

## Increment 05 — Trusted Flutter checkout cutover

**Date:** 2026-10-22  
**Status:** Implemented locally; deployment and legacy bridge removal pending

### Implemented

- Flutter checkout now calls `createTrustedCheckout` instead of creating customer and seller orders directly.
- The request sends only a durable checkout ID, cart item IDs, saved-address index, and delivery mode.
- The backend derives the buyer from auth and validates the selected saved address.
- Trusted checkout now validates:
  - Active products and seller assignment.
  - Available inventory.
  - Regular Delivery seller support, matching country codes, and a 1–7 day window.
  - Fast Delivery seller-managed support, valid coordinates, a maximum 60 km distance, and a valid estimate.
- Existing cart cleanup remains after successful trusted creation and only removes unchanged cart lines.
- Added `REMAINING_WORK_REGISTER.md` and reconciled critical bug statuses.

### Verification

- Flutter analyzer: **No issues found**.
- Flutter tests: **42 passed**.
- Functions TypeScript build and contract tests: **passed**.
- Firestore emulator rules tests: **4 passed**.

### Remaining

- Deploy Functions and rules before production use.
- Remove the legacy client order-create bridge after migration.
- Implement reservation expiry/release/commit and payment webhook processing.

## Increment 02 — Trusted checkout foundation

**Date:** 2026-10-22  
**Status:** Foundation implemented; client cutover and production deployment pending

### Files created or modified

- [`functions/package.json`](./functions/package.json)
- [`functions/package-lock.json`](./functions/package-lock.json)
- [`functions/tsconfig.json`](./functions/tsconfig.json)
- [`functions/src/index.ts`](./functions/src/index.ts)
- [`functions/test/checkout-contract.test.js`](./functions/test/checkout-contract.test.js)
- [`functions/test/firestore-rules.test.js`](./functions/test/firestore-rules.test.js)
- [`firebase.json`](./firebase.json)
- [`firestore.rules`](./firestore.rules)

### Implemented

- Added `createTrustedCheckout` callable Function in region `asia-south1`.
- Derives buyer identity from Firebase Auth rather than request data.
- Requires a validated checkout request ID, cart item IDs, address selector, and delivery mode.
- Re-reads user, cart, and product data inside a Firestore transaction.
- Calculates authoritative paise totals from current product prices and seller delivery fees.
- Creates one schema-versioned parent order and one seller package per seller.
- Creates one active inventory reservation per cart line.
- Atomically increments `reservedQuantity` and `inventoryVersion`.
- Stores a server-owned completed idempotency record.
- Returns only the canonical checkout response fields.
- Denies direct client writes to trusted reservation/event/payment/idempotency collections.
- Denies direct client creation of schema-versioned orders while preserving legacy compatibility during migration.
- Added Firestore emulator tests for trusted collection writes and direct schema-v2 order creation.

### Validation

- `npm run build`: passed.
- `npm test`: passed.
- `npm run test:rules`: passed with the Firestore emulator.
- Node 24 was used although Functions declares Node 20; npm reported an engine warning.
- `npm audit` reports dependency vulnerabilities; no automatic remediation was applied.

### Deliberate limitations

- Flutter checkout is not yet switched to the callable Function.
- Delivery-distance/country eligibility is not duplicated in the Function foundation yet; it remains a required cutover validation.
- Reservation release/commit, expiry scheduler, payment webhooks, and status-event writes are not implemented.
- Product inventory counter writes are not yet restricted from legacy seller updates; that requires the client migration.
- App Check is currently not enforced on the callable during staged rollout.

## Increment 00 — Repository audit and baseline

**Date:** 2026-10-22  
**Status:** Complete  
**Scope:** Audit and documentation only. No Dart, generated Dart, Firestore rules, Firebase configuration, dependency, or application behavior files were changed.

### Files inspected

- [`README.md`](./README.md)
- [`pubspec.yaml`](./pubspec.yaml)
- [`firebase.json`](./firebase.json)
- [`firestore.rules`](./firestore.rules)
- [`lib/core/constants/firestore_paths.dart`](./lib/core/constants/firestore_paths.dart)
- [`lib/core/commerce/commerce_rules.dart`](./lib/core/commerce/commerce_rules.dart)
- [`lib/core/commerce/order_lifecycle.dart`](./lib/core/commerce/order_lifecycle.dart)
- [`lib/features/auth/data/user_repository.dart`](./lib/features/auth/data/user_repository.dart)
- [`lib/features/auth/presentation/providers/auth_provider.dart`](./lib/features/auth/presentation/providers/auth_provider.dart)
- [`lib/features/seller_inventory/domain/entities/product.dart`](./lib/features/seller_inventory/domain/entities/product.dart)
- [`lib/features/seller_inventory/data/product_repository.dart`](./lib/features/seller_inventory/data/product_repository.dart)
- [`lib/features/buyer_shopping/data/cart_repository.dart`](./lib/features/buyer_shopping/data/cart_repository.dart)
- [`lib/features/buyer_shopping/data/checkout_repository.dart`](./lib/features/buyer_shopping/data/checkout_repository.dart)
- [`lib/features/buyer_shopping/domain/entities/customer_order.dart`](./lib/features/buyer_shopping/domain/entities/customer_order.dart)
- [`lib/features/seller_orders/domain/entities/seller_order.dart`](./lib/features/seller_orders/domain/entities/seller_order.dart)
- [`lib/features/seller_orders/data/seller_order_repository.dart`](./lib/features/seller_orders/data/seller_order_repository.dart)
- Existing tests under [`test/`](./test/)

### Changes implemented

- Created [`PROJECT_RECOVERY_MASTER.md`](./PROJECT_RECOVERY_MASTER.md) as the current baseline and roadmap.
- Created [`TRANSACTION_FLOW.md`](./TRANSACTION_FLOW.md) documenting current and target transaction behavior.
- Created [`BUG_REGISTER.md`](./BUG_REGISTER.md) with confirmed bugs, evidence, dependencies, and tests.
- Created this log.
- Did not modify the read-only attachment supplied by the user.

### Verification

- `flutter test` was executed from the Flutter project root: **42 tests passed**.
- `flutter analyze` was executed from the Flutter project root: **No issues found**.
- No Firestore emulator tests were found or run.
- No production Firebase deployment was performed.

### Remaining issues

- Atomic inventory and durable idempotency are not implemented.
- Client-created order data is not a trusted commerce boundary.
- Payment, reservation expiry, cancellation restoration, refunds, and delivery integration are unresolved.
- Security-rule emulator coverage is absent.

### Next recommended increment

Increment 01: define the canonical order/inventory/payment schema and select the trusted checkout backend. Do not start broad UI changes until that contract is approved and documented.

## Increment 06 — Trusted reservation and fulfilment lifecycle

**Date:** 2026-10-22  
**Status:** Implemented and locally verified; deployment blocked by Firebase billing plan

### Implemented

- Added idempotent `releaseInventoryReservation`.
- Added idempotent `commitInventoryReservation`.
- Added scheduled `expireInventoryReservations` every 15 minutes.
- Added atomic `cancelTrustedOrder` with reservation restoration and seller-package cancellation.
- Added trusted `updateTrustedSellerFulfilment` with seller ownership, schema-version checks, lifecycle validation, and append-only events.
- Updated the seller repository to use the trusted fulfilment callable instead of direct legacy status writes.

### Deployment result

- Firestore rules compiled successfully.
- Deployment to `academic-atlas-491309-s4` was attempted.
- Firebase blocked deployment because the project is on the Spark plan and required Cloud Build/Artifact Registry APIs require Blaze.
- No production deployment is claimed.

### Remaining

- Upgrade the Firebase project to Blaze and redeploy.
- Add emulator transaction tests for reservation release, commit, expiry, and cancellation.
- Configure a real payment provider before implementing payment webhooks.
- Remove legacy order creation after deployed trusted checkout verification.

### Lifecycle test verification

- Added [`functions/test/lifecycle.test.js`](./functions/test/lifecycle.test.js).
- Release is idempotent and restores reserved inventory once.
- Commit is idempotent and moves reserved inventory to sold once.
- Cancellation restores active reservations and cancels seller packages.
- `npm run test:lifecycle`: **3 tests passed**.
