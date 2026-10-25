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

test("trusted seller inventory contract accepts only a product and stock quantity", () => {
  assert.deepEqual(
    {
      request: ["productId", "stockQuantity"],
      serverChecks: [
        "authenticated seller",
        "seller owns product",
        "non-negative integer stock",
        "stock is not below reserved plus sold",
      ],
      response: ["schemaVersion", "productId", "stockQuantity"],
    },
    {
      request: ["productId", "stockQuantity"],
      serverChecks: [
        "authenticated seller",
        "seller owns product",
        "non-negative integer stock",
        "stock is not below reserved plus sold",
      ],
      response: ["schemaVersion", "productId", "stockQuantity"],
    },
  );
});
