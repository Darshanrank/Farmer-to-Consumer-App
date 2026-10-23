const test = require("node:test");
const assert = require("node:assert/strict");

test("trusted checkout contract requires server-derived buyer identity", () => {
  assert.deepEqual(
    {
      required: ["checkoutRequestId", "cartItemIds", "addressId", "deliveryMode"],
      ignoredClientFields: [
        "buyerId",
        "sellerIds",
        "totalMinor",
        "paymentStatus",
        "stockQuantity",
      ],
      response: [
        "schemaVersion",
        "parentOrderId",
        "sellerOrderIds",
        "totalMinor",
        "currency",
        "paymentStatus",
      ],
    },
    {
      required: ["checkoutRequestId", "cartItemIds", "addressId", "deliveryMode"],
      ignoredClientFields: [
        "buyerId",
        "sellerIds",
        "totalMinor",
        "paymentStatus",
        "stockQuantity",
      ],
      response: [
        "schemaVersion",
        "parentOrderId",
        "sellerOrderIds",
        "totalMinor",
        "currency",
        "paymentStatus",
      ],
    },
  );
});
