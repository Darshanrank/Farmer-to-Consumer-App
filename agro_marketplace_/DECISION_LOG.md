# Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-22 | Keep one parent order plus one seller package per seller | Preserves existing multi-seller model while allowing seller isolation |
| 2026-10-22 | Use callable Functions/Admin SDK for trusted checkout and lifecycle | Client rules cannot safely enforce price, inventory, payment, or sibling-package consistency |
| 2026-10-22 | Keep inventory reservations explicit and idempotent | Supports expiry, cancellation, commit, and concurrency safety |
| 2026-10-22 | Do not invent payment or courier integrations | No provider credentials or supported courier contract exists |
| 2026-10-23 | Make account role immutable after registration | Prevents client role escalation; seller/buyer accounts must be created through the intended onboarding path |
| 2026-10-23 | Do not remove the legacy order bridge until deployed smoke verification | Avoids breaking existing production data before trusted checkout is confirmed |
