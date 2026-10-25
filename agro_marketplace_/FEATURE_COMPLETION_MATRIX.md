# Feature Completion Matrix

| Feature | Status | Evidence/limitation |
|---|---|---|
| Authentication and profiles | TESTED | Flutter suite passes; profile recovery and role immutability need staging verification |
| Buyer saved addresses | TESTED | Validation tests and ownership checks exist |
| Seller products/inventory | IMPLEMENTED | Fail-closed stock parsing; seller writes remain a migration security concern |
| Product listing/search | TESTED | Fast/Regular rules and seller self-listing exclusion covered |
| Cart | TESTED | Quantity revalidation and race-safe cleanup |
| Trusted checkout | IMPLEMENTED | Callable, idempotency, delivery validation, and reservations; production deployment pending |
| Reservation release/commit/cancel | TESTED | Three lifecycle emulator tests pass; scheduled expiry needs deployed smoke test |
| Seller fulfilment | IMPLEMENTED | Trusted schema-v2 callable and event history |
| Transport assignment | TESTED | Ownership/rules tests pass; no courier/GPS integration |
| Payment/refunds | BLOCKED | No provider or merchant credentials configured |
| Admin moderation/approval | NOT_STARTED | No admin role/workflow exists |
