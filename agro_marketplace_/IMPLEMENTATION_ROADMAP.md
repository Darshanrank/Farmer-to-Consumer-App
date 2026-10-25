# Implementation Roadmap

1. **Deploy trusted backend**
   - Upgrade Firebase project to Blaze.
   - Deploy Functions and verify callable checkout, lifecycle, and scheduler.
2. **Remove migration bridge**
   - Confirm production trusted checkout.
   - Deny schema-less client order creation.
   - Delete the unused client `placeOrder` implementation.
3. **Complete inventory lifecycle**
   - Add deployed expiry smoke test.
   - Add trusted seller inventory mutation and migration tooling.
4. **Payment boundary**
   - Select provider and configure server secrets.
   - Add signed webhook verification and payment idempotency.
5. **Order projections**
   - Add trusted parent-order aggregation and buyer-facing status projection.
6. **Security hardening**
   - Enable App Check after staged validation.
   - Add seller approval/admin authorization.

Each increment requires Flutter analyzer/tests, Functions build/tests, emulator rules tests, and deployment evidence where applicable.
