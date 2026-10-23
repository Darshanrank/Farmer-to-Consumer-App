# Project Recovery Master

**Baseline date:** 2026-10-22  
**Scope:** Recovery baseline through Increment 05. Current state is verified against code and tests; compatibility bridges and deployment blockers are explicit.

## 1. Verified project overview

The project is a Flutter application using Firebase Authentication, Cloud Firestore, Riverpod, Freezed/JSON serialization, Geolocator, geocoding, and fake-cloud-firestore/unit tests. The Flutter project is [`agro_marketplace_`](./). The repository now contains a trusted Functions backend under [`functions/`](./functions/), but it has not been deployed to the active Firebase project.

Relevant top-level files:

- [`pubspec.yaml`](./pubspec.yaml) — runtime and test dependencies.
- [`firebase.json`](./firebase.json) — Firestore rules deployment configuration and Firebase project metadata.
- [`firestore.rules`](./firestore.rules) — current authorization policy.
- [`README.md`](./README.md) — current feature/run documentation.
- [`DELIVERY_COMMERCE_AUDIT.md`](./DELIVERY_COMMERCE_AUDIT.md) — earlier delivery/commerce audit; this recovery document supersedes it where current code differs.
- [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md) — approved target schema and trusted-boundary contract for Increment 01.

## 2. Actual architecture

- `lib/app`: bootstrap, routing, theme.
- `lib/core`: commerce rules, validation, lifecycle, constants, errors, widgets.
- `lib/features/auth`: Firebase Auth, user document, buyer/seller role and profile state.
- `lib/features/buyer_profile`: saved-address UI and buyer profile.
- `lib/features/buyer_shopping`: product feed/search/detail, cart, quote, checkout, customer orders.
- `lib/features/seller_inventory`: product model, product CRUD, stock fields, public delivery snapshots.
- `lib/features/seller_profile`: seller profile/business/delivery settings.
- `lib/features/seller_orders`: seller package queries, seller lifecycle transitions, seller UI.
- `lib/shared`: address/location models, geocoding, Firebase service.

State is Riverpod. Repositories directly access `FirebaseFirestore`. Domain rules are pure Dart helpers, but order creation and inventory authority remain client-side.

## 3. Firestore collections and relationships

| Path | Current purpose | Authority/relationship |
|---|---|---|
| `users/{uid}` | `AppUser`, role/profile, saved addresses, seller delivery settings | Owner-controlled |
| `users/{uid}/cartItems/{itemId}` | Denormalized cart line | Buyer owner-controlled |
| `products/{productId}` | Product, seller ID, price, status, stock counters, public delivery snapshot | Seller writes; public reads |
| `customerOrders/{orderId}` | Parent customer checkout, item snapshots, quote fields, seller IDs, address/delivery snapshot | Buyer creates/reads own order |
| `sellerOrders/{orderId}` | One seller fulfilment package per seller in a checkout | Buyer creates; buyer and assigned seller read; seller updates lifecycle |
| `supportRequests/{id}` | Support request | Authenticated user creates; no client read |

`FirestorePaths` also declares inventory, seller profile, delivery profile, zones, notifications, discounts, and audit-log paths, but the inspected commerce implementation does not read or write those collections.

## 4. Current verified business flow

1. Firebase Auth identifies a user.
2. `users/{uid}` supplies role and profile state. The router gates buyer/seller screens using that state.
3. Sellers create/update `products/{productId}`. Product records include `stockQuantity`, `reservedQuantity`, `soldQuantity`, `status`, and delivery capability snapshots.
4. Buyers receive `products.status == active` through `ProductRepository.streamAllActiveProducts()`. Delivery eligibility is then evaluated locally using the selected saved address and public seller snapshot.
5. Product detail/cart writes a denormalized cart line under the buyer's user document.
6. Cart add and quantity update use client Firestore transactions to reread the product and validate quantity.
7. Checkout rereads the buyer address, cart, and each product, recalculates current item prices and delivery fees, validates delivery eligibility, and writes one parent order plus one seller package per seller in a batch.
8. Cart cleanup runs after the batch and deletes only unchanged cart lines.
9. Sellers query only their assigned seller packages and transition package status through the client transaction and rules matrix.
10. Buyer tracking reads seller packages by `buyerId`; the client does not safely aggregate parent status across sellers.

## 5. Confirmed bug register summary

The detailed register is in [`BUG_REGISTER.md`](./BUG_REGISTER.md).

### Critical/highest priority

1. **No authoritative inventory reservation/decrement.** Checkout only checks stock and does not decrement or reserve it. Concurrent buyers can both purchase the last unit.
2. **Order creation is buyer-authorized and client-supplied.** Firestore rules permit buyer-created totals, item snapshots, seller IDs, payment status, and delivery data. No trusted backend recomputes or protects these values.
3. **No durable idempotency record.** The controller prevents concurrent submissions only within one provider instance. A crash, reinstall, second device, or retry after a partial write is not durably deduplicated.
4. **No payment verification or stock restoration workflow.** Orders remain `paymentStatus: pending`; cancellation, expiry, payment failure, and failed delivery do not restore inventory because no reservation exists.

### Medium/low

5. Parent-order status aggregation is not performed by the client because sellers cannot read sibling seller packages. Parent status can become stale.
6. Order status history, actor ID, and transition timestamps are not stored as an audit trail; only `updatedAt` and current status exist.
7. Product reads are permitted to unauthenticated clients despite comments saying only active products are public; the rule allows all product documents to be read.
8. The role update rule allows an authenticated owner to switch their role; there is no trusted seller approval/role transition policy.
9. Legacy/declared collection paths are not aligned with the collections actually used, increasing migration and maintenance risk.

## 6. Required target data flow

The first implementation sequence should preserve the existing parent checkout/seller-package model but move sensitive creation to a trusted operation:

1. Buyer obtains a quote from current product and seller settings.
2. Client submits a unique checkout request ID, selected address/mode, and cart intent.
3. Trusted backend transaction rereads cart/products/settings and validates prices, delivery, and available stock.
4. The transaction creates an idempotency record, atomically reserves or deducts inventory, creates the parent checkout and seller packages, and records verified quote snapshots.
5. Payment state advances only from a verified payment integration.
6. Seller package transitions are authorized by seller ownership and written with actor/timestamp history.
7. Cancellation/expiry/payment failure releases a recorded reservation exactly once.
8. Trusted processing updates parent status from seller package states; the buyer reads the resulting authoritative records.

## 7. Roadmap and dependencies

| Increment | Scope | Depends on | State |
|---|---|---|---|
| 00 | Audit and baseline documents | None | **Complete** |
| 01 | Normalize models/statuses and schema contract | 00 | **Complete as design; implementation pending** |
| 02 | Listing/availability/inventory integrity | 01 | **Foundation complete; client cutover and release workflow pending** |
| 03 | Cart/checkout quote contract | 01, 02 | **Trusted Flutter cutover implemented; deployment pending** |
| 04 | Atomic multi-seller order/idempotency | 02, 03 | **Trusted foundation and lifecycle implemented locally; deployment pending** |
| 05 | Payment lifecycle/recovery | 04 and payment provider | **Blocked: no payment provider configured** |
| 06 | Seller fulfilment workflow/audit history | 04 | Partially present |
| 07 | Delivery tracking/status synchronization | 06 and supported delivery capability | Pending |
| 08 | Cancellation/returns/refunds/restoration | 04, 05 | Blocked |
| 09 | Rules and concurrency hardening | 04-08 | Pending |
| 10 | Emulator/integration/regression verification | 01-09 | Pending |

## 8. Increment 01 contract

The canonical target is defined in [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md). It selects Firebase callable/HTTP Cloud Functions with Admin SDK as the trusted checkout boundary, keeps one parent order plus one seller package per seller, uses minor currency units, durable checkout idempotency, immutable item snapshots, explicit reservations, separate payment/fulfilment/order states, and append-only order events.

This is a design completion only. No backend, rules, models, or migrations have been implemented yet.

## 9. Baseline verification

- `flutter test` was run during this audit; the final result must be retained in [`IMPLEMENTATION_LOG.md`](./IMPLEMENTATION_LOG.md) after the command completes.
- `flutter analyze` was run during this audit; informational/deprecation findings must be recorded rather than treated as commerce verification.
- No Firestore emulator security-rule suite was found.
- No Cloud Functions or trusted order endpoint was found.

## 10. Exact next task

**Next: integrate the Flutter checkout with `createTrustedCheckout`, then implement reservation release/commit, expiry, payment events, and complete delivery eligibility validation in the trusted boundary. After that, add a trusted transport-assignment schema before exposing driver, vehicle, or tracking data. Do not remove legacy order compatibility until production rules and callable monitoring are verified.

This project must not be called production-ready until atomic inventory, durable idempotency, payment verification, restoration, trusted order creation, and emulator security tests exist.
