# Implementation Progress

**Verified:** 2026-10-23

## Completed in this increment

- Audited the current repository against the production-completion report.
- Added project inventory, feature matrix, production gaps, roadmap, and decision log.
- Closed client role escalation:
  - Firestore role updates must match the existing role.
  - Removed the direct role-update repository method and controller operation.
  - Profile messaging now explains that roles are fixed after registration.
- Added trusted seller inventory updates:
  - Stock changes use the `updateSellerInventory` callable and a Firestore transaction.
  - Sellers cannot set stock below reserved plus sold quantities.
  - Firestore rules reject direct client changes to stock, reserved, or sold counters.
  - Existing product editing preserves the trusted inventory counters.

## Validation

- Firestore rules deployment: succeeded.
- Functions build: passed.
- Lifecycle emulator tests: 3 passed.
- Rules emulator tests: 5 passed.
- Checkout contract tests: 2 passed.
- Flutter analyzer: passed.
- Flutter tests: 46 passed.

## Next task

Upgrade `academic-atlas-491309-s4` to Blaze, deploy Functions, and run trusted checkout/lifecycle smoke verification. Do not configure payment until a provider is selected.
