# Agro Marketplace - Full Project Audit

**Audit date:** 2026-10-23  
**Repository:** `Darshanrank/Farmer-to-Consumer-App`  
**Audited workspace:** `agro_marketplace_`  
**Scope:** Flutter application, Firebase client integration, Firestore rules, Cloud Functions, tests, configuration, documentation, and current worktree state.

## 1. Executive summary

The project has a credible marketplace foundation:

- Flutter application with Riverpod state management.
- Firebase Authentication and Firestore integration.
- Buyer shopping, cart, checkout, addresses, and order tracking.
- Seller onboarding, profile/settings, inventory, products, and order fulfilment.
- Trusted Cloud Functions for checkout, inventory reservation lifecycle, fulfilment, transport assignment, delivery stages, and cancellation.
- Material 3 theme and English/Hindi/Gujarati localization.
- Generated Freezed, JSON serialization, and Riverpod code.
- Firestore default-deny rules and emulator security tests.

The strongest part is the commerce direction: the repository has moved from a client-created order flow toward server-derived checkout and protected inventory reservations. The primary risk is not a missing UI feature; it is that the application is in a **local verification / migration state**, not yet a production-ready state.

The most important work is:

1. Deploy and smoke-test the trusted Functions and rules in a staging Firebase environment.
2. Remove or lock down the legacy client checkout bridge.
3. Fix role escalation and product visibility rules.
4. Complete payment, reservation expiry/release/commit, and parent-order aggregation.
5. Expand positive and negative emulator coverage.
6. Repair the Functions lint toolchain and add CI checks.

## 2. Audit evidence and validation

### Repository inventory

- 143 Dart files under `lib`.
- 13 test files under `test`.
- `functions/src/index.ts` is the primary Functions implementation.
- Generated Dart files exist beside their source files.
- Existing architecture and commerce documents include [`README.md`](./README.md), [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md), [`TRANSACTION_FLOW.md`](./TRANSACTION_FLOW.md), [`BUG_REGISTER.md`](./BUG_REGISTER.md), and [`REMAINING_WORK_REGISTER.md`](./REMAINING_WORK_REGISTER.md).

### Validation performed

| Check | Result | Details |
|---|---|---|
| `flutter analyze` | Passed | No analyzer issues reported. |
| `flutter test` | Passed | Full configured Flutter suite passed. |
| `flutter test test/core/errors/app_exception_test.dart` | Passed | 4 exception metadata tests passed. |
| `npm test` in `functions` | Passed | TypeScript build and trusted checkout contract test passed. |
| `npm run test:rules` in `functions` | Passed | 4 Firestore rules tests passed. Emulator logs expected denied operations. |
| `npm run lint` in `functions` | Failed | `eslint` is not installed or not declared, although a lint script exists. |
| `git diff --check` | Previously passed | The workspace contains pre-existing and current modifications; do not revert them blindly. |

## 3. Current worktree state

The worktree is not clean. At audit time it contained:

- Modified `lib/core/errors/app_exception.dart` from the current exception metadata improvement.
- A staged deletion of `scratch_prompt.txt`.
- Many modified generated/source files and several untracked commerce/documentation files from earlier work.

This matters because a future commit or review must separate:

- The current exception metadata change.
- Earlier delivery/commerce implementation work.
- Generated-file updates.
- Documentation additions.
- The staged deletion.

Do not use `git reset --hard`, broad checkout commands, or mass cleanup without first deciding which of these changes belong to the intended change set.

## 4. Architecture assessment

### Application bootstrap

[`lib/main.dart`](./lib/main.dart) initializes `Bootstrap` with production configuration and then runs the app inside `ProviderScope`.

[`lib/app/bootstrap/bootstrap.dart`](./lib/app/bootstrap/bootstrap.dart) performs:

- Flutter binding initialization.
- Portrait orientation lock.
- System UI configuration.
- Logger initialization.
- Firebase initialization.
- Optional emulator setup.
- App Check activation.

#### Findings

1. **Emulator connection is currently a no-op.**  
   The Firestore, Auth, and Storage emulator calls are commented out, but the method still logs that the app connected. This can cause a developer to believe local emulators are being used while the app is talking to a real Firebase project.

2. **Production entry point always selects production configuration.**  
   [`lib/main.dart`](./lib/main.dart) uses `EnvironmentConfig.production`; staging/development require a separate entry point or build flavor. This is safe from accidental development configuration in production, but the project needs explicit flavor/build documentation and runtime verification.

3. **App Check failure is intentionally non-fatal, while Functions have `enforceAppCheck: false`.**  
   This is appropriate during local rollout but is a production security gap until staged App Check enforcement is enabled.

4. **Bootstrap catches an intentionally broad initialization failure.**  
   The Firebase initialization catch is acceptable because it rethrows after logging. The App Check catch is intentionally non-fatal, but should expose a visible diagnostic in development and be monitored in staging.

### Routing and application shell

[`lib/app/router/app_router.dart`](./lib/app/router/app_router.dart) uses Riverpod and `go_router` with public routes, authentication routes, buyer navigation, seller navigation, and nested detail/settings routes.

[`lib/app/app.dart`](./lib/app/app.dart) configures:

- Material 3 light and dark themes.
- Router configuration.
- English, Hindi, and Gujarati delegates.

#### Findings

1. `ThemeMode.light` is hard-coded, so the dark theme exists but is not user-selectable.
2. `locale: const Locale('en')` is hard-coded, so supported locales are declared but a user cannot select or persist Hindi/Gujarati.
3. Routing depends on asynchronous auth/profile state; redirect behavior should be tested for cold start, email-unverified, missing profile, role switch, and sign-out during navigation.
4. No route-level authorization can replace Firestore authorization. Screens must remain protected by backend rules and callable ownership checks.

### State management

Riverpod generated providers are used consistently across feature modules. Controllers generally expose `AsyncValue` state and repositories return [`Result`](./lib/core/result/result.dart).

#### Findings

1. `Result.guard` maps all errors through the global handler, which is useful but can hide operation-specific recovery choices unless callers inspect the structured exception metadata.
2. Some controllers protect duplicate submissions, such as checkout, but [`order_status_controller.dart`](./lib/features/seller_orders/presentation/providers/order_status_controller.dart) does not prevent repeated status taps.
3. Controllers sometimes write `AsyncError` directly while UI code also displays snackbars, producing two parallel error channels. Standardize whether errors are rendered from provider state, returned `Result`, or both.
4. Provider invalidation/refetch policy is not consistently visible in the audited controllers. After mutations, affected list/detail providers should be refreshed deterministically.

## 5. Feature-by-feature audit

## 5.1 Authentication and user profiles

Relevant modules:

- [`auth_repository.dart`](./lib/features/auth/data/auth_repository.dart)
- [`user_repository.dart`](./lib/features/auth/data/user_repository.dart)
- [`auth_provider.dart`](./lib/features/auth/presentation/providers/auth_provider.dart)
- [`app_user.dart`](./lib/features/auth/domain/entities/app_user.dart)
- Authentication screens under [`lib/features/auth/presentation/screens/`](./lib/features/auth/presentation/screens/)

### Implemented

- Email/password authentication.
- Email verification flow.
- Sign-in, sign-up, sign-out, password reset, and reload/check verification paths.
- Firestore user profile stream.
- Buyer/seller role persisted on registration.
- Profile update path strips protected fields.

### Findings

**High - Client role escalation remains possible.**  
[`user_repository.dart`](./lib/features/auth/data/user_repository.dart) contains `updateUserRole`, which writes `role` from the client. [`firestore.rules`](./firestore.rules) also permits an authenticated owner to update the role to `buyer` or `seller`. A user can therefore promote their own account to seller without a trusted approval process. The project documentation already records this as `COM-009`.

**Medium - Sign-up profile creation failure is logged but not surfaced.**  
[`auth_provider.dart`](./lib/features/auth/presentation/providers/auth_provider.dart) catches failure while creating the user document, logs it, and continues to send verification email. This can leave an authenticated account without a profile while the UI reports success.

**Medium - Missing profile silently becomes a buyer fallback.**  
[`auth_provider.dart`](./lib/features/auth/presentation/providers/auth_provider.dart) creates an in-memory buyer fallback when the Firestore profile is missing. This avoids a crash but can mask data corruption and prevent a seller from reaching the correct navigation.

**Low - Sensitive identifiers are logged.**  
Sign-in and sign-up log email addresses. Email is not a credential, but production logs should minimize personal data and use a redacted identifier or correlation ID.

### Recommended changes

- Remove direct client role updates.
- Add `sellerApplicationStatus` and trusted approval if seller approval is required.
- Make profile creation failure a visible failure with a recovery action.
- Represent missing profile as a distinct `profileMissing` state rather than silently assigning buyer.
- Add auth redirect tests.

## 5.2 Buyer catalog, product detail, and cart

Relevant modules:

- [`product_repository.dart`](./lib/features/seller_inventory/data/product_repository.dart)
- [`shopping_providers.dart`](./lib/features/buyer_shopping/presentation/providers/shopping_providers.dart)
- [`cart_repository.dart`](./lib/features/buyer_shopping/data/cart_repository.dart)
- Buyer screens under [`lib/features/buyer_shopping/presentation/screens/`](./lib/features/buyer_shopping/presentation/screens/)

### Implemented

- Active product streaming.
- Seller self-listing exclusion in buyer-facing logic.
- Product detail and cart operations.
- Product reread during cart mutations.
- Delivery-mode eligibility evaluation.
- Seller grouping and checkout quote preparation.

### Findings

**High - Product reads are public for every product document.**  
The `products` rule in [`firestore.rules`](./firestore.rules) uses `allow read: if true`. The comment says active products are public, but the rule does not check `status == 'active'`. Draft, paused, private, or internal product fields can be read by unauthenticated clients. This is `COM-008`.

**Medium - Product data ownership and field validation are incomplete in rules.**  
Create checks `sellerId`; update/delete check the existing owner, but rules do not constrain protected fields such as inventory counters, status, currency, prices, or seller delivery snapshots. Legacy client sellers may mutate fields that trusted Functions assume are authoritative.

**Medium - Cart item path is hard-coded in places.**  
The project has [`firestore_paths.dart`](./lib/core/constants/firestore_paths.dart), but cart operations use the literal `cartItems` subcollection in multiple locations. This weakens the stated path-centralization guarantee.

**Low - Stream parsing can fail the entire stream on one malformed document.**  
`Product.fromJson` is mapped directly over snapshots. One malformed product can terminate the stream instead of being logged and isolated. Decide whether malformed data should fail fast or be skipped with telemetry.

### Recommended changes

- Restrict public reads to active/public fields or create a public catalog projection.
- Lock protected product fields in rules and move inventory changes to trusted operations.
- Add cart path constants.
- Add a typed Firestore converter or explicit malformed-document handling.

## 5.3 Checkout and commerce

Relevant modules:

- [`checkout_repository.dart`](./lib/features/buyer_shopping/data/checkout_repository.dart)
- [`checkout_controller.dart`](./lib/features/buyer_shopping/presentation/providers/checkout_controller.dart)
- [`functions/src/index.ts`](./functions/src/index.ts)
- [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md)

### Implemented

- Client quote validation rereads cart and products.
- Trusted `createTrustedCheckout` callable Function.
- Server-derived buyer identity.
- Durable checkout request identifier.
- Server-side authoritative pricing in minor units.
- One parent order and one seller package per seller.
- Inventory reservation records and reserved counters.
- Delivery mode, country, coordinates, seller capability, and delivery-window checks.
- Cart cleanup that avoids removing changed cart lines.

### Findings

**Critical - Legacy client checkout remains present.**  
[`checkout_repository.dart`](./lib/features/buyer_shopping/data/checkout_repository.dart) still contains `placeOrder`, which can directly create customer and seller order documents under legacy rules. The active controller calls the trusted Function, but the unused path is a future regression and remains a security boundary risk until removed or explicitly disabled. This is `COM-001` and `COM-002`.

**High - Payment is not implemented.**  
Orders are created with `paymentStatus: pending`; there is no verified payment provider boundary, payment transition state machine, webhook idempotency, failure handling, or refund workflow. This is `COM-004`.

**High - Reservation lifecycle is incomplete in the end-to-end order flow.**  
Functions for release/commit/expiry exist, but payment and fulfilment transitions are not yet shown as fully connected to those operations. Cancellation has a release path, but rejection, payment failure, failed delivery, and all expiry reconciliation paths need complete integration and tests. This is `COM-005`.

**High - Parent status aggregation is not wired as a trusted projection.**  
[`order_lifecycle.dart`](./lib/core/commerce/order_lifecycle.dart) contains a local aggregation helper, but the backend does not consistently update the parent order from seller package transitions. Buyers may see stale parent status for multi-seller orders. This is `COM-006`.

**Medium - Money model is duplicated during migration.**  
The trusted Function uses minor units such as `totalMinor`, while the legacy Dart model uses fields such as `totalAmount`, `subtotal`, `deliveryFee`, and `currency`. Until the legacy path is removed, both schemas can be accidentally mixed.

**Medium - Checkout retry semantics need a durable UI contract.**  
The controller stores `_pendingOrderId` only in provider process state. The Function has durable idempotency, but the client resets the ID after any failed call. A network timeout after server success can cause the client to create a new request on retry unless the original request ID survives the user-visible retry flow.

### Recommended changes

- Remove `placeOrder` after staging migration verification, or make it throw a clear unsupported exception.
- Make checkout request ID persistent for the entire user checkout attempt, including network retry.
- Connect payment and order lifecycle transitions to reservation state changes.
- Recompute and persist parent status in trusted backend code.
- Make one canonical integer-minor-unit model and migrate legacy readers.

## 5.4 Seller inventory and products

Relevant modules:

- [`product_repository.dart`](./lib/features/seller_inventory/data/product_repository.dart)
- [`product_form_controller.dart`](./lib/features/seller_inventory/presentation/providers/product_form_controller.dart)
- Product entities and seller inventory screens.

### Implemented

- Seller product CRUD.
- Active/seller product streams.
- Image serialization.
- Seller delivery settings propagated to product snapshots in batches.
- Product validation in form controller.

### Findings

**High - Client product writes are broader than the trusted inventory contract.**  
Seller-owned products can be updated directly by the client under current rules. The rule checks ownership but does not protect inventory counters, reservation counters, sold quantity, inventory version, or trusted delivery fields. A seller can potentially change values used by checkout.

**Medium - Delivery snapshot propagation is a large client-side write operation.**  
`updateSellerDeliverySnapshot` reads all seller products and writes batches from the client. It is split at 500 writes, which is good for batch limits, but partial failure can leave products with mixed delivery settings. A trusted version or versioned seller profile projection would be safer.

**Medium - Timestamp representations are inconsistent.**  
Products and users use `DateTime`, ISO strings, server timestamps, and Firestore `Timestamp` values in different paths. This increases parsing and ordering risk.

**Low - Product deletion has no archival strategy.**  
Hard delete can break historical order references, analytics, or product image references. Prefer `archived`/`inactive` for products that appear in order snapshots.

## 5.5 Seller orders, transport, and delivery

Relevant modules:

- [`seller_order_repository.dart`](./lib/features/seller_orders/data/seller_order_repository.dart)
- [`seller_order_detail_screen.dart`](./lib/features/seller_orders/presentation/screens/seller_order_detail_screen.dart)
- [`order_lifecycle.dart`](./lib/core/commerce/order_lifecycle.dart)
- Delivery widgets under [`lib/core/widgets/`](./lib/core/widgets/)

### Implemented

- Seller order list and detail screens.
- Trusted transport assignment Function.
- Trusted delivery stage Function.
- Ownership checks.
- Fast delivery transport-type check.
- Transport field length/phone validation.
- Event records in `orderEvents`.
- Buyer-readable transport projection.
- Shared delivery details card and timeline.

### Findings

**High - Two fulfilment paths remain.**  
The repository still contains direct `updateOrderStatus`, while schema-v2 trusted Functions use `updateTrustedSellerFulfilment`. The documentation recognizes the legacy path, but the UI must ensure no active control can call the legacy direct update for schema-v2 orders.

**Medium - Transport assignment is replaceable without an explicit reassignment policy.**  
The Function permits assignment whenever the order is in an eligible fulfilment state. It does not explicitly distinguish first assignment from reassignment, preserve the prior assignment in the current projection, or require a reassignment reason.

**Medium - Delivery completion writes legacy and trusted status fields together.**  
`updateSellerDeliveryStage` writes `deliveryStage`, `fulfilmentStatus`, and `status` on delivery. This is compatible with migration but increases the number of fields that must remain synchronized.

**Low - Live tracking is correctly not claimed.**  
The UI displays current assignment/stage and does not invent GPS tracking. This is a positive design decision; future live tracking requires a separate trusted schema.

## 5.6 Firestore rules and data security

Rules are in [`firestore.rules`](./firestore.rules).

### Positive controls

- Default deny rule exists.
- Trusted commerce collections deny client reads/writes.
- Seller and buyer order reads check ownership.
- Schema-versioned direct client order creation is denied.
- Direct schema-v2 transport mutation is denied by tests.
- Buyer transport projection isolation is covered by emulator tests.

### Findings

1. **Role self-escalation:** user owners may change role between buyer and seller.
2. **Public product over-read:** all product documents are publicly readable.
3. **Legacy order creates remain allowed:** non-schema-versioned direct order creation is still allowed as a migration bridge.
4. **Rule field validation is incomplete:** ownership checks do not fully protect trusted business fields for products/users.
5. **No explicit rules for many declared canonical collections:** `firestore_paths.dart` declares collections such as seller profiles, inventory, notifications, audit logs, and discounts, but the rules file does not contain corresponding matches. Default deny applies, which is safe but indicates schema drift.
6. **Rules tests are mostly denial tests:** positive seller fulfilment, positive buyer reads, valid profile operations, and legacy migration behavior need a complete matrix.

## 5.7 Error handling and logging

Relevant modules:

- [`app_exception.dart`](./lib/core/errors/app_exception.dart)
- [`firebase_error_mapper.dart`](./lib/core/errors/firebase_error_mapper.dart)
- [`error_handler.dart`](./lib/core/errors/error_handler.dart)
- [`app_logger.dart`](./lib/core/logging/app_logger.dart)

### Implemented

- Sealed exception hierarchy.
- Firebase Auth/Firestore/Functions mapping.
- Structured logger with environment log levels.
- Current exception metadata improvement adds `ExceptionCategory` and `isRetryable`.
- Sensitive logging guidance is documented in the logger.

### Findings

**Medium - User-facing messages are not fully localized.**  
Repositories, controllers, and error classes contain English strings. The app has generated localization files, but many operation messages are not represented as localization keys.

**Medium - `debugPrint` remains in geocoding.**  
[`geocoding_service.dart`](./lib/shared/services/geocoding_service.dart) logs raw exception text and resolved address objects. Replace with `AppLogger` and avoid logging detailed address data in production.

**Medium - Error mapping uses server messages directly for several callable errors.**  
The mapper uses `FirebaseFunctionsException.message` for permission and failed-precondition messages. These messages are currently safe, but server text should be mapped by stable error code where possible to prevent accidental internal details reaching users.

**Low - `ErrorHandler.getUserMessage` maps without a stack trace.**  
This is acceptable for display, but if mapping itself ever requires context, callers lose the original operation metadata.

## 5.8 Offline and networking behavior

[`connectivity_service.dart`](./lib/core/network/connectivity_service.dart) exposes a connectivity boolean stream.

### Findings

- The service is not visibly wired into checkout/action gating in the audited paths.
- Connectivity means network interface availability, not Firebase reachability.
- Read retries can be automatic; checkout/status writes need idempotency-aware retries.
- Firestore offline cache behavior is not documented as part of the UX.
- Geocoding fallback uses Nominatim directly from the app, but the audit found no visible user-agent/rate-limit policy in the inspected section. This should be reviewed before high-volume use.

## 5.9 Localization, accessibility, and UX

### Implemented

- Material 3 theme.
- Shared buttons, fields, loading, error, empty-state, badges, delivery cards, and timeline widgets.
- English, Hindi, and Gujarati generated localization classes.

### Findings

1. Locale selection is hard-coded to English.
2. Dark theme is defined but not selectable.
3. Many screens use hard-coded English labels and snackbars.
4. Loading/error/empty patterns are not yet demonstrably uniform across all screens.
5. Accessibility semantics, text scaling, touch targets, and localized overflow need widget tests.
6. Order status should communicate with text/icon as well as color.
7. Confirmation flows for rejection, cancellation, and delivery completion should be reviewed for destructive-action clarity.

## 5.10 Cloud Functions

Primary file: [`functions/src/index.ts`](./functions/src/index.ts).

### Implemented Functions

- `createTrustedCheckout`
- `releaseInventoryReservation`
- `commitInventoryReservation`
- `expireInventoryReservations`
- `updateTrustedSellerFulfilment`
- `cancelTrustedOrder`
- `assignSellerTransport`
- `updateSellerDeliveryStage`

### Strengths

- Auth identity is derived from `request.auth`.
- Input helpers validate strings, lists, integers, coordinates, country codes, and phone numbers.
- Transactions are used for inventory/order mutation.
- Checkout has durable request idempotency.
- Events are recorded for several trusted transitions.
- Function region is consistently `asia-south1`.

### Findings

**High - App Check enforcement is disabled on every callable.**  
All inspected callables use `enforceAppCheck: false`. Enable after staging validation and client App Check rollout.

**High - Scheduled expiry has a fixed batch limit and no continuation strategy.**  
`expireInventoryReservations` processes up to 100 active expired reservations per run. If backlog exceeds 100 repeatedly, the next run eventually catches up, but there is no explicit monitoring, pagination, or failure queue.

**Medium - Scheduled expiry catches and logs errors without a durable retry record.**  
One failed reservation does not fail the scheduled invocation or record a recovery task. Add an operation status/event or ensure the next query reliably retries it.

**Medium - Event creation is not consistently idempotent across all operations.**  
Checkout idempotency is durable, but assignment, delivery transitions, and cancellation use new random event documents. A client retry after an unknown response can produce duplicate events unless the operation itself has an idempotency key.

**Medium - Cancellation queries seller orders by parent order inside a transaction.**  
This requires an index and transaction read limits to remain healthy as order size grows. Keep package counts bounded or model package IDs on the parent.

**Low - A single large `index.ts` concentrates unrelated operations.**  
Splitting validators, inventory, checkout, order lifecycle, and transport into modules would make test coverage and review easier without adding external services.

## 5.11 Tests and quality gates

### Existing coverage

- Domain tests for pricing, listing, validation, and lifecycle.
- Trusted checkout contract test.
- Firestore rules tests.
- Exception metadata tests added during this audit session.

### Gaps

- No broad widget test coverage for buyer/seller workflows.
- No positive trusted callable integration tests against the Functions emulator.
- No concurrency test for two checkout requests competing for final inventory.
- No payment state tests.
- No role escalation regression test.
- No public/private product read regression test.
- No parent-order aggregation tests.
- No migration test proving legacy orders cannot use schema-v2 transitions.
- No CI workflow was found in the repository inventory.
- Functions lint script is currently unusable because ESLint is not installed/declared.

## 6. Prioritized risk register

| ID | Severity | Finding | Evidence | Recommended action |
|---|---|---|---|---|
| AUD-001 | Critical | Legacy client checkout still exists | [`checkout_repository.dart`](./lib/features/buyer_shopping/data/checkout_repository.dart) | Remove after staging cutover or make unavailable. |
| AUD-002 | Critical | Payment is not verified | [`REMAINING_WORK_REGISTER.md`](./REMAINING_WORK_REGISTER.md) | Define payment state machine and trusted transition boundary. |
| AUD-003 | High | Client can promote itself to seller | [`firestore.rules`](./firestore.rules), [`user_repository.dart`](./lib/features/auth/data/user_repository.dart) | Remove client role write; use trusted approval. |
| AUD-004 | High | All product documents are public | [`firestore.rules`](./firestore.rules) | Restrict reads to public active data. |
| AUD-005 | High | App Check disabled for callables | [`functions/src/index.ts`](./functions/src/index.ts) | Stage and enable enforcement. |
| AUD-006 | High | Reservation recovery not fully connected | [`functions/src/index.ts`](./functions/src/index.ts) | Integrate release/commit/expiry with payment and fulfilment. |
| AUD-007 | High | Parent order status can become stale | [`order_lifecycle.dart`](./lib/core/commerce/order_lifecycle.dart) | Update parent projection from trusted package transitions. |
| AUD-008 | Medium | Legacy/trusted fulfilment paths coexist | [`seller_order_repository.dart`](./lib/features/seller_orders/data/seller_order_repository.dart) | Complete schema migration and remove direct legacy path. |
| AUD-009 | Medium | Callable retries can duplicate events | [`functions/src/index.ts`](./functions/src/index.ts) | Add operation idempotency keys to mutating callables. |
| AUD-010 | Medium | Emulator setup logs success without connecting | [`bootstrap.dart`](./lib/app/bootstrap/bootstrap.dart) | Implement emulator connections or change the log. |
| AUD-011 | Medium | Hard-coded English UI/error messages | [`assets/l10n/`](./assets/l10n/) and feature screens | Move visible strings to localization. |
| AUD-012 | Medium | Functions lint command is broken | [`functions/package.json`](./functions/package.json) | Add ESLint dependency/config or remove the script. |
| AUD-013 | Low | Locale/theme settings are hard-coded | [`app.dart`](./lib/app/app.dart) | Add persisted user preferences. |
| AUD-014 | Low | Raw geocoding debug logs | [`geocoding_service.dart`](./lib/shared/services/geocoding_service.dart) | Use structured redacted logging. |

## 7. Recommended implementation sequence

### Phase 1 - Secure the current architecture

1. Add regression tests for role escalation and public inactive-product reads.
2. Restrict product rules and protect trusted product fields.
3. Remove `updateUserRole` from normal client flows.
4. Implement real emulator connections or clearly separate emulator and production entry points.
5. Fix the Functions lint toolchain.

### Phase 2 - Finish trusted commerce cutover

1. Deploy Functions/rules/indexes to staging.
2. Run real-device checkout, cart cleanup, transport, delivery, and cancellation smoke tests.
3. Remove the legacy `CheckoutRepository.placeOrder` bridge.
4. Remove or gate direct legacy seller status updates for schema-v2 orders.
5. Add positive callable emulator tests.

### Phase 3 - Complete commerce consistency

1. Connect payment state transitions to reservation commit/release.
2. Add idempotency to cancellation, transport assignment, delivery stage, and fulfilment operations.
3. Update parent order status from package events.
4. Add immutable event history assertions and migration tests.
5. Add reconciliation for failed cart cleanup and reservation processing.

### Phase 4 - Improve user-facing quality

1. Localize all visible messages.
2. Add consistent loading, retry, empty, and offline states.
3. Add locale/theme preferences.
4. Add accessibility and text-overflow tests.
5. Improve seller order confirmations and buyer checkout review.

### Phase 5 - Maintainability

1. Split `functions/src/index.ts` into domain modules.
2. Centralize Firestore converters and timestamp handling.
3. Add typed operation/request models.
4. Add CI gates for `flutter analyze`, `flutter test`, Functions build, lint, and rules tests.
5. Track migration completion explicitly in the project register.

## 8. Final assessment

**Current maturity:** strong prototype / local commerce foundation, not production-ready.

**What is already good:**

- Default-deny Firestore posture.
- Server-derived checkout identity and pricing.
- Inventory reservation direction.
- Transactional trusted mutations.
- Explicit delivery constraints.
- Shared error and UI primitives.
- Documentation that records migration limitations.

**What blocks production:**

- Legacy client write paths.
- Unverified payment state.
- Incomplete reservation lifecycle integration.
- Role escalation.
- Public access to inactive product documents.
- Disabled App Check.
- Limited positive integration/concurrency coverage.
- Broken Functions lint quality gate.

The project should proceed incrementally, but the next implementation increment should be **security regression tests plus removal/containment of the legacy client write paths**, not a new feature.
