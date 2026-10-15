# Agro Marketplace

Agro Marketplace is a Flutter application connecting farmers and consumers
through buyer shopping, seller inventory management, delivery-aware listings,
cart checkout, and order tracking.

## Features

- Firebase Authentication with buyer and seller roles
- Buyer product browsing, search, filters, cart, checkout, saved addresses,
  and order tracking
- Seller onboarding, profile and delivery settings
- Seller product CRUD with inventory and availability controls
- Seller order workflow with status transitions
- Fast and regular delivery eligibility rules
- Localized Flutter UI with Material 3 styling

## Run locally

From this directory:

```bash
flutter pub get
flutter run
```

The Firebase project configuration must be available for the selected platform.
Use the existing development entry points when running against a development
Firebase environment.

## Validate changes

```bash
flutter analyze
flutter test
```

Commerce and validation tests are under `test/core`.

## Project structure

- `lib/app` - routing, theme, and application bootstrap
- `lib/core` - commerce rules, validation, errors, and shared widgets
- `lib/features/auth` - authentication and user profiles
- `lib/features/buyer_shopping` - buyer catalog, cart, checkout, and orders
- `lib/features/seller_inventory` - seller products and inventory
- `lib/features/seller_orders` - seller order management
- `lib/features/seller_profile` - seller settings and delivery configuration
- `test` - unit and domain tests

## Order flow

Checkout revalidates the selected saved address, cart, product availability,
seller assignment, inventory, and delivery eligibility before creating the
customer order and seller packages in a Firestore batch. Cart cleanup is
performed only for unchanged cart lines so items added during checkout are not
removed.
