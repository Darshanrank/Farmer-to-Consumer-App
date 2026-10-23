# Canonical Commerce Schema

**Contract version:** 1.0  
**Defined:** 2026-10-22  
**Scope:** Increment 01 design contract. This document defines the target schema and trusted boundaries; it does not migrate data or change application behavior.

## 1. Decisions

1. Keep one customer checkout parent with one seller fulfilment package per seller.
2. Use Firebase callable/HTTP Cloud Functions with Admin SDK as the trusted checkout, inventory, payment-event, cancellation, expiry, and parent-aggregation boundary.
3. Keep Firestore as the durable store. No service-account credential is ever shipped in Flutter.
4. Treat all client prices, totals, seller IDs, payment states, inventory counters, and fulfilment states as untrusted input.
5. Use integer minor currency units (`amountMinor`, paise for INR) and an explicit `currency` on every financial snapshot. Do not use floating-point values for authoritative totals.
6. Keep current product delivery snapshots for listing, but recalculate eligibility and fees in the trusted checkout operation.

## 2. Canonical collections

### `users/{buyerId}`

Existing profile document. Saved addresses remain under this document for now:

```text
savedAddresses: [{ id, recipientName, phoneNumber, address, location? }]
```

The trusted checkout reads the buyer's document and verifies the selected `addressId` belongs to the authenticated buyer. It stores an immutable address snapshot on the order; later profile edits do not change an order.

### `products/{productId}`

The existing product remains the catalog source. During the inventory migration, these fields become authoritative only when maintained by trusted code:

```text
sellerId
status
priceMinor
currency
stockQuantity
reservedQuantity
soldQuantity
inventoryVersion
```

Existing `price` may remain during compatibility migration, but trusted checkout must normalize it once and reject ambiguous or malformed values. `availableQuantity = stockQuantity - reservedQuantity - soldQuantity` must never be negative.

### `checkoutRequests/{buyerId_requestId}`

Server-owned idempotency record. The client may submit a request ID but cannot create or update this document directly.

```text
requestId
buyerId
cartFingerprint
inputHash
state: processing | completed | rejected
parentOrderId?
errorCode?
createdAt
completedAt?
expiresAt
```

The same `requestId` is valid only for the same buyer and input hash. A reused key with different cart/address/mode input is rejected.

### `customerOrders/{parentOrderId}`

One document per customer checkout:

```text
id
buyerId
sellerIds: [sellerId]
orderStatus: pending | confirmed | partially_fulfilled | fulfilled | cancelled
paymentStatus: pending | authorized | paid | failed | refund_pending | refunded
deliveryMode: fast | regular
currency
subtotalMinor
discountMinor
taxMinor
handlingFeeMinor
deliveryFeeMinor
totalMinor
shippingAddress
deliveryAddressSnapshot
deliveryEstimate
checkoutRequestId
createdAt
updatedAt
paidAt?
cancelledAt?
```

Only the trusted backend may write financial fields, seller IDs, snapshots, payment state, and parent status. Buyers may read their own parent orders. Parent status is a projection maintained by trusted processing from seller packages.

### `sellerOrders/{sellerOrderId}`

One package per distinct seller in the parent:

```text
id
parentOrderId
buyerId
sellerId
fulfilmentStatus: pending | accepted | rejected | preparing | packed | ready | dispatched | delivered | cancelled
paymentStatus
currency
subtotalMinor
deliveryFeeMinor
totalMinor
items: [immutable item snapshot]
shippingAddress
deliveryAddressSnapshot
deliveryMode
deliveryEstimate
createdAt
updatedAt
acceptedAt?
rejectedAt?
deliveredAt?
cancelledAt?
transportAssignment?
deliveryStage: assigned | picked_up | in_transit | delivered | failed | returned
```

Seller package totals are the sum of its immutable item snapshots plus its assigned delivery fee. A seller can read and transition only its own package. A buyer can read packages where `buyerId` matches.

`transportAssignment` is trusted seller-managed metadata:

```text
transportType: seller_managed_fast | seller_managed_regular
driverName
driverPhone?
vehicleType
vehicleNumber
assignedAt
```

It does not represent a courier integration or live GPS location.

### `inventoryReservations/{reservationId}`

One reservation per order item:

```text
id
parentOrderId
sellerOrderId
productId
sellerId
buyerId
quantity
state: active | committed | released | expired
createdAt
expiresAt
releasedAt?
releaseReason?
```

Reservations are created and released only by trusted backend code. The reservation ID is the idempotency key for restoration; releasing an already released/expired reservation is a no-op.

### `orderEvents/{eventId}`

Append-only trusted audit record:

```text
id
parentOrderId
sellerOrderId?
actorType: buyer | seller | system | payment_provider
actorId?
eventType
fromStatus?
toStatus?
paymentStatus?
createdAt
metadata
```

Clients cannot create, update, or delete events.

### `paymentEvents/{providerEventId}`

Trusted payment webhook idempotency record:

```text
providerEventId
parentOrderId
eventType
result: applied | ignored | rejected
createdAt
processedAt
```

This prevents duplicate webhook delivery from applying payment or refund changes twice.

## 3. Immutable item snapshot

Every order item must contain:

```text
productId
sellerId
name
unit
quantity
unitPriceMinor
discountMinor
taxMinor
lineTotalMinor
currency
```

The snapshot is never recomputed from the current product. Product deletion, price edits, name changes, and stock changes cannot alter historical orders.

## 4. Status ownership and transitions

### Order status

Trusted system only:

```text
pending -> confirmed | cancelled
confirmed -> partially_fulfilled | fulfilled | cancelled
partially_fulfilled -> fulfilled | cancelled
```

`fulfilled` means every non-rejected seller package is delivered or the business has explicitly accepted the partial outcome. The exact partial-fulfilment policy must be selected before implementation.

### Payment status

Trusted payment integration only:

```text
pending -> authorized | paid | failed
authorized -> paid | failed
paid -> refund_pending
refund_pending -> refunded
```

Clients and sellers cannot mark an order paid, failed, or refunded.

### Seller fulfilment status

Assigned seller through a trusted authorized operation:

```text
pending -> accepted | rejected | cancelled
accepted -> preparing | cancelled
preparing -> packed | cancelled
packed -> ready
ready -> dispatched
dispatched -> delivered
```

Each transition writes `updatedAt`, the appropriate event timestamp, and an `orderEvents` record. Delivery status is not added until a real delivery actor/integration exists; `dispatched` is not live tracking.

### Delivery stage

Transport stages are separate from seller fulfilment:

```text
assigned -> picked_up | failed
picked_up -> in_transit | failed
in_transit -> delivered | failed
failed -> returned
```

Only the assigned seller may invoke the trusted transport callables. Buyer tracking reads the current stage and assignment snapshot from the seller package. No live location is exposed.

## 5. Trusted checkout contract

### Client request

```text
checkoutRequestId
buyerId              // derived from auth; client value ignored
cartItemIds          // intent only
addressId
deliveryMode
```

The client must not submit authoritative prices, totals, seller IDs, payment state, stock values, or order statuses.

### Server transaction

The trusted function must:

1. Authenticate the buyer and derive `buyerId`.
2. Validate request ID format and load the idempotency record.
3. Return the stored result for a completed identical request.
4. Read the buyer profile/address, cart lines, products, seller snapshots, and current fee configuration.
5. Validate ownership, active status, quantity, delivery eligibility, country/coordinates, and currency.
6. Read all product inventory before writing anything.
7. Atomically increment `reservedQuantity`, create reservations, create the parent order, create seller packages, and mark the request `completed`.
8. Persist the server-calculated minor-unit quote and immutable snapshots.
9. Return only `{parentOrderId, sellerOrderIds, totalMinor, currency, paymentStatus}`.

If any validation fails, no reservation or order document is written. External payment calls occur after the transaction and use a separate idempotent payment flow.

## 6. Reservation and restoration rules

- Reservation decreases available inventory by increasing `reservedQuantity`.
- Successful payment/fulfilment commits the reservation by decreasing `reservedQuantity` and increasing `soldQuantity`.
- Cancellation, rejection before fulfilment, payment failure, and expiry release the reservation exactly once.
- A release must transactionally verify `state == active`; otherwise it performs no counter change.
- Expiry requires a scheduled trusted function. The Flutter client cannot release abandoned reservations.
- Existing orders without reservation IDs are legacy orders and must not trigger automatic stock restoration.

## 7. Firestore authorization target

| Collection | Client read | Client create/update/delete |
|---|---|---|
| `checkoutRequests` | None | None |
| `customerOrders` | Buyer owner only | None |
| `sellerOrders` | Assigned seller or buyer owner | Seller status transition only through a trusted endpoint; direct financial/protected-field writes denied |
| `inventoryReservations` | Buyer owner projection only if needed | None |
| `orderEvents` | Buyer/seller scoped projection if needed | None |
| `paymentEvents` | None | None |
| `products` | Public catalog projection only | Seller edits catalog fields; inventory counters protected |

Rules are a second boundary, not a replacement for backend validation. The current rules must not be weakened to preserve client-side order creation.

## 8. Migration and compatibility

1. Do not rewrite existing orders. Treat current `customerOrders` and `sellerOrders` as legacy-compatible documents.
2. Add nullable `schemaVersion`; new trusted orders use `schemaVersion: 2`.
3. Preserve legacy floating totals for reads, but never use them as inputs to new checkout.
4. Backfill `currency` and minor-unit amounts only from an approved currency/rounding policy; do not infer silently where values are ambiguous.
5. Existing products receive `inventoryVersion` and validated counters through a reviewed migration. Malformed stock is quarantined/unavailable, never treated as unlimited.
6. Deploy the trusted backend and rules before switching the client checkout write path.
7. Run dual-read compatibility during rollout, then disable direct client order creation after verified adoption.
8. Create no reservation for historical orders unless an operator performs a separately audited reconciliation.

## 9. Required implementation gates

Before Increment 02:

- Approve whether Fast/Regular fees are per seller package and confirm currency.
- Approve partial fulfilment semantics.
- Choose payment provider/webhook contract.
- Create Cloud Functions project/deployment configuration.
- Add Firestore emulator tests for protected fields, ownership, idempotency, seller isolation, and inventory concurrency.
