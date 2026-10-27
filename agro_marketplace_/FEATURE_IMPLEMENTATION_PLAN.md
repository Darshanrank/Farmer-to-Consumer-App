# Feature Implementation Plan

**Scope:** Dispatch and delivery actions, in-app notifications, product search,
seller dashboard destinations, seller reports, and product reviews.

## Increment 00 — Audit and dependency map

### Verified architecture

- Flutter UI uses Riverpod and `go_router`.
- Catalog data is stored in `products` and exposed through
  `ProductRepository`/`buyerProductsProvider`.
- Seller packages are stored in `sellerOrders`; the supported fulfilment
  lifecycle is `pending -> accepted -> preparing -> packed -> ready ->
  dispatched -> delivered`.
- Transport assignment and delivery stages are separate from fulfilment status.
- Trusted checkout and fulfilment callables are implemented in
  `functions/src/index.ts`; deployment and payment integration remain
  environment/business dependencies.

### Relevant source files

- Dispatch: `lib/features/seller_orders/`, `firestore.rules`,
  `functions/src/index.ts`
- Search: `lib/features/buyer_shopping/presentation/screens/buyer_search_screen.dart`,
  `lib/features/buyer_shopping/presentation/providers/search_providers.dart`
- Dashboard: `lib/features/seller_dashboard/`,
  `lib/app/router/app_router.dart`
- Catalog and order data: `lib/features/seller_inventory/`,
  `lib/features/buyer_shopping/`, `lib/features/seller_orders/`
- Security and schema: `firestore.rules`, `firestore.indexes.json`,
  `CANONICAL_COMMERCE_SCHEMA.md`, `TRANSACTION_FLOW.md`

### Known constraints and gaps

- Payment/refund reporting is not authoritative because no payment provider is
  configured; reports must not present pending orders as paid revenue.
- Client-side seller mutations are legacy-compatible paths; trusted Functions
  remain the required production boundary.
- Products currently have a broad read rule and no dedicated search index.
- Notifications and reviews now use new user-scoped/trusted collections.
- Dashboard notification and report destinations are now wired.

## Implementation increments

1. [x] Add explicit assigned-order dispatch/delivery actions without conflating
   transport assignment and fulfilment status.
2. [x] Add user-scoped in-app notifications, unread/read state, UI, and rules.
3. [x] Improve buyer search UX and query behavior while preserving catalog
   visibility rules.
4. [x] Wire every seller dashboard card to a distinct existing or new destination.
5. [x] Add seller-scoped sales and stock report calculations over persisted data.
6. [x] Add purchase-eligible product reviews, aggregation, UI, and security.
7. [x] Add focused unit/widget tests, run analyzer/tests, and update this plan with
   actual verification and deployment limitations.

## Acceptance criteria and testing strategy

- Invalid transitions, duplicate submissions, and unauthorized writes are
  rejected by both client validation and Firestore/trusted-operation rules.
- Search has loading, empty, error, retry, clear, filter, and detail navigation
  states and does not add a per-keystroke collection download.
- Notifications are readable only by their owner. With Functions unavailable,
  the client records deterministic notifications for the authenticated actor
  only after successful operations; cross-user event notifications still
  require deployed trusted Functions.
- Reports are seller-scoped, date-filterable, and exclude cancelled/pending
  revenue according to the canonical schema.
- Reviews require a qualifying delivered purchase, are unique per buyer and
  product, and cannot be manipulated through client rating summaries.
- Run `flutter analyze`, focused Flutter tests, and Functions build/tests where
  the local environment supports them. Firebase deployment remains a manual
  step requiring the configured project and Blaze plan.

## Progress

- [x] Increment 00 — audit and plan
- [x] Increment 01 — dispatch and delivery actions
- [x] Increment 02 — in-app notifications
- [x] Increment 03 — product search
- [x] Increment 04 — dashboard navigation
- [x] Increment 05 — sales and stock reports
- [x] Increment 06 — product reviews and ratings
- [x] Increment 07 — regression verification and documentation

## Verification results

- `flutter pub run build_runner build` — passed.
- `flutter analyze` — passed with no issues.
- Focused Flutter commerce and geocoding tests — 21 passed.
- `functions` `npm run build` — passed.
- `functions` `npm test` — 2 passed.
- Full `flutter test` was attempted but cannot currently compile the existing
  `fake_cloud_firestore` test dependency against the installed
  `cloud_firestore_platform_interface` (`maximum`/`minimum` missing). This is
  an environment/dependency compatibility blocker, not a feature test pass.

## Remaining limitations

- Firebase rules and Functions changes still require deployment to the
  configured project; production Functions deployment requires the documented
  Blaze configuration.
- Review submission is intentionally deferred because secure purchase
  eligibility and rating aggregation require a trusted backend operation.
  Reviews remain read-only until an approved trusted operation is available.
- Stock movement history is not present in the existing schema, so the stock
  report shows current/reserved/sold values and a clearly labelled derived
  opening value rather than inventing adjustments or returns.
- Sales reports use delivered seller packages and cannot report authoritative
  paid/refunded/net revenue while payment integration is pending.
- Product search remains a bounded client-side filter over the existing active
  catalog stream; it does not claim a server-side full-text index.
