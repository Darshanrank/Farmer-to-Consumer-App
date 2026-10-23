const test = require("node:test");
const assert = require("node:assert/strict");
const {
  assertFails,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const { doc, setDoc, getDoc, updateDoc } = require("firebase/firestore");
const fs = require("node:fs");
const path = require("node:path");

let testEnvironment;

test.before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId: "academic-atlas-491309-s4",
    firestore: {
      rules: fs.readFileSync(
        path.join(__dirname, "..", "..", "firestore.rules"),
        "utf8",
      ),
    },
  });
});

test.after(async () => {
  await testEnvironment.cleanup();
});

test("clients cannot write trusted checkout collections", async () => {
  assert.ok(testEnvironment);
  const context = testEnvironment.authenticatedContext("buyer-1");
  const firestore = context.firestore();
  for (const collection of [
    "checkoutRequests",
    "inventoryReservations",
    "orderEvents",
    "paymentEvents",
  ]) {
    await assertFails(setDoc(doc(firestore, collection, "test"), {
      buyerId: "buyer-1",
    }));
  }
});

test("clients cannot create schema version 2 orders directly", async () => {
  const context = testEnvironment.authenticatedContext("buyer-1");
  const firestore = context.firestore();
  await assertFails(setDoc(doc(firestore, "customerOrders", "v2"), {
    schemaVersion: 2,
    buyerId: "buyer-1",
  }));
  await assertFails(setDoc(doc(firestore, "sellerOrders", "v2"), {
    schemaVersion: 2,
    buyerId: "buyer-1",
  }));
});

test("buyers read only their own transport projection and cannot change it", async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "sellerOrders", "tracking-1"), {
      schemaVersion: 2,
      sellerId: "seller-1",
      buyerId: "buyer-1",
      deliveryStage: "assigned",
      transportAssignment: {
        transportType: "seller_managed_regular",
        driverName: "Driver",
        vehicleType: "Van",
        vehicleNumber: "KA01AA1234",
      },
    });
  });

  const buyer = testEnvironment.authenticatedContext("buyer-1").firestore();
  const unrelatedBuyer = testEnvironment.authenticatedContext("buyer-2").firestore();
  assert.equal((await getDoc(doc(buyer, "sellerOrders", "tracking-1"))).exists(), true);
  await assertFails(getDoc(doc(unrelatedBuyer, "sellerOrders", "tracking-1")));
  await assertFails(updateDoc(doc(buyer, "sellerOrders", "tracking-1"), {
    deliveryStage: "delivered",
  }));
});

test("seller can read but cannot directly write trusted transport fields", async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "sellerOrders", "tracking-2"), {
      schemaVersion: 2,
      sellerId: "seller-1",
      buyerId: "buyer-1",
      deliveryStage: "assigned",
    });
  });

  const seller = testEnvironment.authenticatedContext("seller-1").firestore();
  assert.equal((await getDoc(doc(seller, "sellerOrders", "tracking-2"))).exists(), true);
  await assertFails(updateDoc(doc(seller, "sellerOrders", "tracking-2"), {
    transportAssignment: { driverName: "Changed" },
  }));
});
