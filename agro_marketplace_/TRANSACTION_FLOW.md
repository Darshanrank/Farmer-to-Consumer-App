# Transaction Flow

**Baseline:** 2026-10-22. This document describes the current implementation and separates it from the required target design.

The canonical target schema is defined in [`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md). Field names and ownership in this document must follow that contract.

## Current flow

### Product listing to cart

1. Seller writes `products/{productId}` through `ProductRepository`.
2. Buyer receives active products through `streamAllActiveProducts()`.
3. Local listing rules check status, available quantity, delivery mode, country/coordinates, seller capability, and configured window.
4. Buyer adds a cart line to `users/{buyerId}/cartItems/{itemId}`. The client transaction rereads the product and rejects invalid quantity.

### Checkout

1. The buyer selects a saved address and Fast/Regular mode.
2. `CheckoutRepository._buildQuote()` verifies address ownership, rereads cart lines, rereads each product, replaces stale name/price/unit/seller data, validates quantity and delivery eligibility, and sums current prices plus one delivery fee per seller.
3. The active Flutter checkout calls `createTrustedCheckout`; the Function writes `customerOrders/{id}` and one schema-versioned `sellerOrders/{id}` per seller inside a transaction. The old client batch remains only as a temporary migration bridge.
4. Cart cleanup runs in a separate transaction after order creation and removes only unchanged lines.

### Fulfilment

Seller packages transition through:

```text
pending -> accepted | rejected | cancelled
accepted -> preparing | cancelled
preparing -> packed | cancelled
packed -> ready
ready -> dispatched
dispatched -> delivered
```

The seller repository validates the transition in a transaction. Firestore rules restrict seller updates to `status` and `updatedAt`. No status-history subcollection or actor field is written.

## Current consistency gaps

- Product stock is checked but neither reserved nor decremented.
- Legacy client batch creation is not a trusted price, payment, seller-assignment, or inventory boundary and must be removed after migration.
- A batch is atomic for the documents it writes, but it does not include cart deletion or any stock mutation.
- The controller's pending ID is process/provider scoped, not durable idempotency.
- A successful order followed by cleanup failure leaves the cart visible by design; no reconciliation state is recorded.
- Payment remains `pending`; there is no authorized/paid/failed/refunded workflow.
- Cancellation/rejection does not restore stock.
- Parent status aggregation is unavailable to sellers under the current read rules.

## Required target flow

### Quote and request

The client displays a quote calculated from current public product data, but submits only intent plus a unique `checkoutRequestId`. The trusted operation must recompute all prices and fees. Client totals are informational.

### Atomic trusted checkout

Within a trusted Firestore transaction:

1. Read the idempotency record.
2. If already completed, return the stored parent order result without creating anything again.
3. Read the buyer cart, selected buyer address, seller capability snapshots, and every product.
4. Validate seller identity, active status, delivery mode, address ownership, price, quantity, and available inventory.
5. Create reservations or decrement available inventory.
6. Create one immutable parent checkout/order and one seller fulfilment record per seller.
7. Store immutable item snapshots, verified quote fields, delivery address snapshot, delivery mode, delivery estimate, and reservation references.
8. Store the completed idempotency result.

No network calls or external payment side effects belong inside the transaction callback.

### Payment and fulfilment

Use separate fields:

- `paymentStatus`: `pending`, `authorized`, `paid`, `failed`, `refund_pending`, `refunded`.
- `sellerFulfilmentStatus`: current seller package state.
- `deliveryStatus`: only if an actual supported delivery workflow exists.

A payment provider webhook or trusted server operation, not a Flutter client, advances payment state.

### Cancellation/restoration

Only a trusted operation may cancel an order and release a reservation. Restoration must be idempotent and reference the reservation/order ID so a retry cannot restore twice. If stock was not reserved, no restoration is allowed. Expired reservations require a scheduled trusted process or explicit reconciliation job.

### Multi-seller behavior

One buyer checkout has one parent order. Each distinct seller gets exactly one seller package containing only that seller's immutable item snapshots and seller-specific delivery estimate/fee. Parent status is computed by trusted processing from package states, not by a seller reading another seller's package.

## Documents changed by the target workflow

| Step | Documents |
|---|---|
| Quote | No writes |
| Idempotent checkout start | `checkoutRequests/{buyerId}_{requestId}` or equivalent trusted idempotency record |
| Reservation | Product/inventory reservation document(s) and product counters in one transaction |
| Order creation | `customerOrders/{parentId}`, `sellerOrders/{sellerPackageId}` |
| Seller transition | Assigned `sellerOrders/{sellerPackageId}`, status-history record |
| Payment event | Parent/package payment fields and payment event idempotency record |
| Cancellation/expiry | Order state, reservation state, inventory counters, restoration record |

The concrete collection names and security boundary are approved by
[`CANONICAL_COMMERCE_SCHEMA.md`](./CANONICAL_COMMERCE_SCHEMA.md). Backend and rules implementation exists locally. Production deployment, legacy bridge removal, reservation lifecycle, and payment integration remain.
