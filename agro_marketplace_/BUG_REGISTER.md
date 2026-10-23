# Bug Register

**Baseline date:** 2026-10-22  
**Status vocabulary:** Open, In Progress, Blocked, Verified. A bug is not Verified merely because the app compiles.

The target resolution contract for the commerce bugs below is [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md). Increment 01 is design-complete; implementation remains pending.

| ID | Severity | Description/root cause | Affected files/functions | Required fix | Dependencies | Regression test | Status |
|---|---|---|---|---|---|---|---|
| COM-001 | Critical | Legacy checkout path validates stock but never reserves/decrements it; it remains available only for compatibility. | `features/buyer_shopping/data/checkout_repository.dart:placeOrder`, `functions/src/index.ts:createTrustedCheckout` | Keep client path unused and migrate/remove after legacy data transition. | Backend deployment, client migration | Trusted checkout reserves atomically; no negative available quantity | In Progress |
| COM-002 | Critical | Legacy client-created orders remain temporarily permitted, but active Flutter checkout now uses the trusted Function. | `checkout_controller.dart`, `functions/src/index.ts`, `firestore.rules` | Deploy trusted Function/rules, then remove legacy create bridge. | COM-001, deployment | Tampered protected fields cannot create schema-v2 orders; trusted checkout succeeds | In Progress |
| COM-003 | High | Durable idempotency is implemented in the trusted Function; legacy path has no durable idempotency. | `functions/src/index.ts`, `checkout_controller.dart` | Complete deployment and verify retry behavior against production emulator/project. | COM-002 | Same request ID returns one parent and one package set | In Progress |
| COM-004 | High | No payment verification; orders remain `paymentStatus: pending`, and no payment failure/refund restoration workflow exists. | `customer_order.dart`, `seller_order.dart`, `checkout_repository.dart` | Add payment state machine and verified provider/webhook boundary. | COM-002, payment decision | Payment failure leaves no paid order and restores only recorded reservation | Blocked |
| COM-005 | High | Cancellation, expiry, rejection, and failed delivery do not restore inventory because no reservation lifecycle exists. | `order_lifecycle.dart`, seller order repository, product model | Record reservation and release exactly once through trusted cancellation/expiry operation. | COM-001, COM-004 | Cancellation and expiry restore reserved units once | Blocked |
| COM-006 | High | Parent order status is not updated from seller package states; client cannot safely read sibling sellers under rules. | `seller_order_repository.dart`, `order_lifecycle.dart`, buyer order providers | Trusted aggregation or a buyer-readable parent projection updated by trusted code. | COM-002, rules design | Multi-seller package changes produce correct parent projection | Open |
| COM-007 | Medium | Current lifecycle stores only current status and `updatedAt`; no actor, transition timestamp, or audit history. | `seller_order_repository.dart`, `firestore.rules`, order models | Add immutable transition history and actor authorization. | Increment 01, COM-006 | Invalid actor/transition denied; history is append-only | Open |
| COM-008 | Medium | Product rule permits reads from unauthenticated clients for all product documents, despite comments describing active-only public reads. | `firestore.rules` products match | Decide public catalog policy; restrict private/unpublished data or separate public projection. | Listing requirements, migration review | Hidden/private product cannot be read publicly | Open |
| COM-009 | Medium | User-owned role can be switched by the client without trusted seller approval policy. | `firestore.rules`, `user_repository.dart`, `auth_provider.dart` | Define and enforce role transition/approval policy if required by business. | Product decision | Unauthorized role escalation denied | Open |
| COM-010 | Medium | Declared Firestore paths for inventory, delivery profiles/zones, audit logs, etc. are unused while operational data is denormalized elsewhere. | `firestore_paths.dart`, product/user repositories | Choose canonical schema and document/migrate without deleting historical data. | Increment 01 | Reads/writes use one documented schema | Open |
| COM-011 | Low | Historical order snapshots are present, but model comments and status vocabulary still describe older states than the lifecycle implementation. | `customer_order.dart`, `seller_order.dart`, enums/lifecycle | Normalize names and separate order/payment/fulfilment/delivery status fields. | Increment 01 | Serialization and transition tests cover all states | Open |
| COM-012 | Low | Emulator suite now covers trusted collection/order denial and transport projection access, but full checkout authorization remains incomplete. | `functions/test/firestore-rules.test.js`, `firestore.rules` | Add complete positive trusted-operation and lifecycle matrix. | Rules design, emulator availability | Positive/negative rules matrix passes | In Progress |

## Verified existing protections

- Cart add and quantity update reread the product in a client transaction.
- Checkout rereads address/cart/products and recalculates current prices and configured delivery fees.
- Saved addresses remain under the buyer's own `users/{uid}` document.
- Seller package status updates use a transaction and a defined lifecycle matrix.
- The current test suite contains domain tests for pricing, listing, validation, and lifecycle, but not the required concurrency/security emulator coverage.
