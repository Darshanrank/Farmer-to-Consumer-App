const test = require("node:test");
const assert = require("node:assert/strict");
const admin = require("firebase-admin");

const projectId = "demo-lifecycle";
const {
  cancelTrustedOrder,
  commitInventoryReservation,
  releaseInventoryReservation,
} = require("../lib/index.js");
const firestore = admin.app().firestore();

async function seedReservation({
  reservationId,
  productId,
  buyerId,
  parentOrderId,
  quantity,
  expiresAt,
}) {
  await firestore.collection("products").doc(productId).set({
    stockQuantity: 10,
    reservedQuantity: quantity,
    soldQuantity: 0,
    inventoryVersion: 1,
  });
  await firestore.collection("inventoryReservations").doc(reservationId).set({
    schemaVersion: 2,
    parentOrderId,
    productId,
    sellerId: "seller-1",
    buyerId,
    quantity,
    state: "active",
    expiresAt,
  });
}

test.after(async () => {
  await admin.app().delete();
});

test("release reservation restores available inventory once", async () => {
  await seedReservation({
    reservationId: "release-1",
    productId: "product-release",
    buyerId: "buyer-release",
    parentOrderId: "order-release",
    quantity: 2,
    expiresAt: new Date(Date.now() + 60_000),
  });
  await releaseInventoryReservation.run({
    data: { reservationId: "release-1" },
    auth: { uid: "buyer-release" },
  });
  await releaseInventoryReservation.run({
    data: { reservationId: "release-1" },
    auth: { uid: "buyer-release" },
  });
  const product = (await firestore.collection("products").doc("product-release").get()).data();
  const reservation = (await firestore.collection("inventoryReservations").doc("release-1").get()).data();
  assert.equal(product.reservedQuantity, 0);
  assert.equal(product.soldQuantity, 0);
  assert.equal(reservation.state, "released");
});

test("commit reservation moves units from reserved to sold once", async () => {
  await seedReservation({
    reservationId: "commit-1",
    productId: "product-commit",
    buyerId: "buyer-commit",
    parentOrderId: "order-commit",
    quantity: 3,
    expiresAt: new Date(Date.now() + 60_000),
  });
  await commitInventoryReservation.run({
    data: { reservationId: "commit-1" },
    auth: { uid: "seller-1" },
  });
  await commitInventoryReservation.run({
    data: { reservationId: "commit-1" },
    auth: { uid: "seller-1" },
  });
  const product = (await firestore.collection("products").doc("product-commit").get()).data();
  const reservation = (await firestore.collection("inventoryReservations").doc("commit-1").get()).data();
  assert.equal(product.reservedQuantity, 0);
  assert.equal(product.soldQuantity, 3);
  assert.equal(reservation.state, "committed");
});

test("cancellation restores active reservations and cancels packages", async () => {
  await firestore.collection("products").doc("product-cancel").set({
    stockQuantity: 10,
    reservedQuantity: 4,
    soldQuantity: 0,
    inventoryVersion: 1,
  });
  await firestore.collection("inventoryReservations").doc("cancel-reservation").set({
    schemaVersion: 2,
    parentOrderId: "order-cancel",
    productId: "product-cancel",
    sellerId: "seller-1",
    buyerId: "buyer-cancel",
    quantity: 4,
    state: "active",
    expiresAt: new Date(Date.now() + 60_000),
  });
  await firestore.collection("customerOrders").doc("order-cancel").set({
    schemaVersion: 2,
    buyerId: "buyer-cancel",
    orderStatus: "pending",
  });
  await firestore.collection("sellerOrders").doc("seller-order-cancel").set({
    schemaVersion: 2,
    parentOrderId: "order-cancel",
    buyerId: "buyer-cancel",
    sellerId: "seller-1",
    fulfilmentStatus: "pending",
  });
  await cancelTrustedOrder.run({
    data: { parentOrderId: "order-cancel" },
    auth: { uid: "buyer-cancel" },
  });
  const product = (await firestore.collection("products").doc("product-cancel").get()).data();
  const order = (await firestore.collection("customerOrders").doc("order-cancel").get()).data();
  const sellerOrder = (await firestore.collection("sellerOrders").doc("seller-order-cancel").get()).data();
  assert.equal(product.reservedQuantity, 0);
  assert.equal(order.orderStatus, "cancelled");
  assert.equal(sellerOrder.fulfilmentStatus, "cancelled");
});
