# Production Gap Register

| ID | Severity | Gap | Status | Required evidence |
|---|---|---|---|---|
| GAP-001 | Critical | Functions are not deployed because Firebase project is on Spark | BLOCKED | Blaze upgrade and deployment log |
| GAP-002 | Critical | Legacy schema-less order bridge remains in repository/rules | IN_PROGRESS | Production trusted-checkout smoke test, then remove bridge |
| GAP-003 | High | Payment provider/webhooks are not configured | BLOCKED | Provider contract, signature verification, idempotency tests |
| GAP-004 | High | App Check is not enforced by callable Functions | BLOCKED | Staged Android App Check validation |
| GAP-005 | High | Product seller inventory writes are not fully trusted | RESOLVED_LOCALLY | Deploy `updateSellerInventory`, verify production behavior, then remove any migration compatibility path |
| GAP-006 | Medium | Parent-order aggregation is incomplete | NOT_STARTED | Trusted projection test for multi-seller package states |
| GAP-007 | Medium | No admin seller approval/suspension workflow | NOT_STARTED | Product decision and admin authorization model |
| GAP-008 | Low | Emulator connection code is currently commented out | IN_PROGRESS | Development flavor smoke test |
