# Remaining Work Register

**Verified:** 2026-10-22

| Task ID | Feature | Problem | Evidence | Root cause | Severity | Status | Dependencies | Acceptance criteria | Tests |
|---|---|---|---|---|---|---|---|---|---|
| REM-001 | Checkout/inventory | Legacy checkout method remains for compatibility, but active Flutter checkout uses trusted reservations | `checkout_controller.dart`, `functions/src/index.ts` | Trusted cutover completed locally | Critical | Verified locally | Deployment | Checkout calls `createTrustedCheckout`; duplicate request returns one result; no active legacy write | Flutter tests, Function contract, emulator rules |
| REM-002 | Delivery/security | Trusted checkout enforces delivery mode, country, coordinates, seller capability, and windows | `functions/src/index.ts:createTrustedCheckout` | Backend eligibility validation added | Critical | Verified locally | Deployment | Fast <=60 km and seller-managed; Regular same country and 1–7 days | Function build/tests |
| REM-003 | Inventory recovery | Reservations require release/commit/expiry lifecycle | `functions/src/index.ts`, `inventoryReservations` | Trusted lifecycle operations added | High | Verified locally | Deployment | Expiry, cancellation, and fulfilment operations are idempotent and transactional | `npm run test:lifecycle`: 3 passed |
| REM-004 | Payment | Payment remains pending with no verified provider boundary | `customerOrders`, `sellerOrders` schemas | Payment provider/webhook is not configured | High | Blocked | Provider credentials | Only trusted payment event changes payment state | Webhook idempotency tests |
| REM-005 | Fulfilment history | Legacy seller status controls remain available for legacy orders | `seller_order_repository.dart`, `functions/src/index.ts` | Active seller repository now calls trusted schema-v2 transition Function | High | Verified locally | Deployment, legacy migration | Schema-v2 transitions append events and enforce seller ownership | Flutter analyzer, Functions build |
| REM-006 | Production security | Functions/rules deployment and App Check are not active | `functions/src/index.ts`, Firebase project | Firebase project is Spark; Cloud Build API requires Blaze | High | Blocked | Firebase Blaze upgrade | Production deployment and staged App Check validation | Deployment smoke tests |
| REM-007 | Documentation | Historical documents needed reconciliation | Recovery and transaction documents | Increment records were stale/out of order | Medium | Verified locally | None | Current state and next task agree with code and tests | Documentation review |

## Classification

- Trusted transport assignment and tracking: **Verified locally**; deployment and live GPS remain intentionally unavailable.
- Trusted checkout foundation: **Verified locally**; deployment and legacy bridge removal remain.
- Inventory concurrency: **Verified locally for reservation creation/release/commit code**; lifecycle integration tests and deployment remain.
- Payment, refunds, and cancellation restoration: **Blocked/Pending** because no provider and lifecycle worker are configured.
