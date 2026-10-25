# Project Inventory

**Verified:** 2026-10-23

| Area | Entry points | Storage/backend | Current state |
|---|---|---|---|
| Authentication/profile | `lib/features/auth`, `lib/app/router` | Firebase Auth, `users/{uid}` | Implemented; role is now immutable after registration |
| Buyer catalog/cart | `lib/features/buyer_shopping`, `lib/features/seller_inventory` | `products`, `users/{uid}/cartItems` | Implemented with local eligibility and stock checks |
| Trusted checkout | `lib/features/buyer_shopping/data/checkout_repository.dart`, `functions/src/index.ts` | Callable Functions, orders, reservations | Active Flutter path uses trusted callable; deployment pending |
| Seller fulfilment | `lib/features/seller_orders` | Trusted fulfilment callable and `orderEvents` | Implemented locally for schema v2 |
| Transport tracking | `functions/src/index.ts`, shared delivery widgets | `sellerOrders`, `orderEvents` | Seller-managed assignment/stages; no GPS |
| Payments | None | `paymentEvents` reserved by schema | Not configured; blocked on provider |

## Integrations

- Firebase project: `academic-atlas-491309-s4`
- Functions region: `asia-south1`
- Firestore rules/indexes: deployed
- Cloud Functions: local build/tests pass; deployment requires Blaze
- Flutter state: Riverpod
- Serialization: Freezed and JSON serializable
