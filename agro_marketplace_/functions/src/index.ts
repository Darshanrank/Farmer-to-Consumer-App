import { initializeApp } from "firebase-admin/app";
import { getFirestore, type DocumentReference } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";

initializeApp();
const db = getFirestore();
const schemaVersion = 2;
const reservationMinutes = 30;
const deliveryStages = [
  "assigned",
  "picked_up",
  "in_transit",
  "delivered",
  "failed",
  "returned",
] as const;

type CheckoutRequest = {
  checkoutRequestId?: unknown;
  cartItemIds?: unknown;
  addressId?: unknown;
  deliveryMode?: unknown;
};

type CheckoutResponse = {
  schemaVersion: number;
  parentOrderId: string;
  sellerOrderIds: string[];
  totalMinor: number;
  currency: string;
  paymentStatus: "pending";
};

function stringValue(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim() === "") {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return value.trim();
}

function stringList(value: unknown, field: string): string[] {
  if (!Array.isArray(value) || value.length === 0 ||
      value.some((item) => typeof item !== "string" || item.trim() === "")) {
    throw new HttpsError("invalid-argument", `${field} must contain strings.`);
  }
  return value.map((item) => (item as string).trim());
}

function positiveInteger(value: unknown, field: string): number {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value <= 0) {
    throw new HttpsError("failed-precondition", `${field} is invalid.`);
  }
  return value;
}

function priceMinor(product: Record<string, unknown>): number {
  if (typeof product.priceMinor === "number" &&
      Number.isSafeInteger(product.priceMinor) && product.priceMinor >= 0) {
    return product.priceMinor;
  }
  if (typeof product.price !== "number" ||
      !Number.isFinite(product.price) || product.price < 0) {
    throw new HttpsError("failed-precondition", "Product price is invalid.");
  }
  return Math.round(product.price * 100);
}

function available(product: Record<string, unknown>): number {
  const stock = product.stockQuantity;
  const reserved = product.reservedQuantity ?? 0;
  const sold = product.soldQuantity ?? 0;
  if (![stock, reserved, sold].every((value) =>
    typeof value === "number" && Number.isSafeInteger(value) && value >= 0)) {
    throw new HttpsError("failed-precondition", "Product inventory is invalid.");
  }
  const result = (stock as number) - (reserved as number) - (sold as number);
  if (result < 0) {
    throw new HttpsError("failed-precondition", "Product inventory is invalid.");
  }
  return result;
}

function addressFromUser(
  user: Record<string, unknown>,
  addressId: string,
): Record<string, unknown> {
  const addresses = user.savedAddresses;
  if (!Array.isArray(addresses)) {
    throw new HttpsError("failed-precondition", "Saved delivery address not found.");
  }
  const index = Number(addressId);
  const candidate = Number.isSafeInteger(index) && String(index) === addressId
    ? addresses[index]
    : addresses.find((item) =>
      typeof item === "object" && item !== null &&
      (item as Record<string, unknown>).id === addressId);
  if (typeof candidate !== "object" || candidate === null) {
    throw new HttpsError("failed-precondition", "Saved delivery address not found.");
  }
  return candidate as Record<string, unknown>;
}

function deliveryFeeMinor(product: Record<string, unknown>, mode: string): number {
  const fee = mode === "fast" ? product.fastDeliveryFee : product.regularDeliveryFee;
  return typeof fee === "number" && Number.isFinite(fee) && fee >= 0
    ? Math.round(fee * 100)
    : 5000;
}

function countryCode(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const normalized = value.trim().toUpperCase();
  return /^[A-Z]{2}$/.test(normalized) ? normalized : null;
}

function coordinates(value: unknown): { latitude: number; longitude: number } | null {
  if (typeof value !== "object" || value === null) return null;
  const data = value as Record<string, unknown>;
  const latitude = data.latitude;
  const longitude = data.longitude;
  if (typeof latitude !== "number" || typeof longitude !== "number" ||
      !Number.isFinite(latitude) || !Number.isFinite(longitude) ||
      latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return null;
  }
  return { latitude, longitude };
}

function distanceKm(
  first: { latitude: number; longitude: number },
  second: { latitude: number; longitude: number },
): number {
  const radians = (value: number) => value * Math.PI / 180;
  const latitudeDelta = radians(second.latitude - first.latitude);
  const longitudeDelta = radians(second.longitude - first.longitude);
  const a = Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(radians(first.latitude)) *
    Math.cos(radians(second.latitude)) *
    Math.sin(longitudeDelta / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function validPhone(value: unknown): boolean {
  return typeof value === "string" && /^[+0-9 ()-]{7,20}$/.test(value.trim());
}

function transportAssignment(data: Record<string, unknown>): Record<string, unknown> {
  const transportType = stringValue(data.transportType, "transportType");
  if (!["seller_managed_fast", "seller_managed_regular"].includes(transportType)) {
    throw new HttpsError("invalid-argument", "transportType is invalid.");
  }
  const driverName = stringValue(data.driverName, "driverName");
  const vehicleType = stringValue(data.vehicleType, "vehicleType");
  const vehicleNumber = stringValue(data.vehicleNumber, "vehicleNumber");
  if (driverName.length > 120 || vehicleType.length > 80 ||
      vehicleNumber.length > 40) {
    throw new HttpsError("invalid-argument", "Transport details are too long.");
  }
  if (data.driverPhone !== undefined && !validPhone(data.driverPhone)) {
    throw new HttpsError("invalid-argument", "driverPhone is invalid.");
  }
  return {
    transportType,
    driverName,
    driverPhone: data.driverPhone?.toString().trim() ?? null,
    vehicleType,
    vehicleNumber,
    assignedAt: new Date(),
  };
}

function deliveryStageTransition(from: string, to: string): boolean {
  const transitions: Record<string, string[]> = {
    assigned: ["picked_up", "failed"],
    picked_up: ["in_transit", "failed"],
    in_transit: ["delivered", "failed"],
    delivered: [],
    failed: ["returned"],
    returned: [],
  };
  return transitions[from]?.includes(to) ?? false;
}

type ReservationAction = "released" | "committed";

async function applyReservationAction(
  reservationId: string,
  action: ReservationAction,
  actorId: string,
): Promise<{ parentOrderId: string; state: ReservationAction }> {
  const reservationRef = db.collection("inventoryReservations").doc(reservationId);
  return db.runTransaction(async (transaction) => {
    const reservationSnapshot = await transaction.get(reservationRef);
    const reservation = reservationSnapshot.data() as Record<string, unknown> | undefined;
    if (!reservationSnapshot.exists || !reservation) {
      throw new HttpsError("not-found", "Inventory reservation was not found.");
    }
    if (!actorId.startsWith("system:") &&
        reservation.buyerId !== actorId && reservation.sellerId !== actorId) {
      throw new HttpsError("permission-denied", "You cannot change this reservation.");
    }
    const currentState = reservation.state;
    if (currentState === action) {
      return {
        parentOrderId: stringValue(reservation.parentOrderId, "parentOrderId"),
        state: action,
      };
    }
    if (currentState !== "active") {
      throw new HttpsError(
        "failed-precondition",
        `Reservation is already ${String(currentState)}.`,
      );
    }
    const productRef = db.collection("products").doc(
      stringValue(reservation.productId, "productId"),
    );
    const productSnapshot = await transaction.get(productRef);
    const product = productSnapshot.data() as Record<string, unknown> | undefined;
    if (!productSnapshot.exists || !product) {
      throw new HttpsError("failed-precondition", "Reserved product was not found.");
    }
    const reserved = product.reservedQuantity;
    const sold = product.soldQuantity;
    const quantity = reservation.quantity;
    if (![reserved, sold, quantity].every((value) =>
      typeof value === "number" && Number.isSafeInteger(value) && value >= 0)) {
      throw new HttpsError("failed-precondition", "Product inventory is invalid.");
    }
    if ((reserved as number) < (quantity as number)) {
      throw new HttpsError("failed-precondition", "Reserved inventory is inconsistent.");
    }
    transaction.update(productRef, {
      reservedQuantity: (reserved as number) - (quantity as number),
      ...(action === "committed"
        ? { soldQuantity: (sold as number) + (quantity as number) }
        : {}),
      inventoryVersion: (product.inventoryVersion as number | undefined ?? 0) + 1,
      updatedAt: new Date(),
    });
    transaction.update(reservationRef, {
      state: action,
      ...(action === "released" ? { releaseReason: "order_cancelled" } : {}),
      processedBy: actorId,
      processedAt: new Date(),
    });
    return {
      parentOrderId: stringValue(reservation.parentOrderId, "parentOrderId"),
      state: action,
    };
  });
}

type ReservationActionRequest = {
  reservationId?: unknown;
};

export const releaseInventoryReservation = onCall<ReservationActionRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const actorId = request.auth?.uid;
    if (!actorId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const reservationId = stringValue(request.data.reservationId, "reservationId");
    return applyReservationAction(reservationId, "released", actorId);
  },
);

export const commitInventoryReservation = onCall<ReservationActionRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const actorId = request.auth?.uid;
    if (!actorId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const reservationId = stringValue(request.data.reservationId, "reservationId");
    return applyReservationAction(reservationId, "committed", actorId);
  },
);

export const expireInventoryReservations = onSchedule(
  { schedule: "every 15 minutes", region: "asia-south1" },
  async () => {
    const now = new Date();
    const snapshot = await db.collection("inventoryReservations")
      .where("state", "==", "active")
      .where("expiresAt", "<=", now)
      .limit(100)
      .get();
    for (const reservation of snapshot.docs) {
      try {
        await applyReservationAction(
          reservation.id,
          "released",
          "system:reservation-expiry",
        );
      } catch (error) {
        console.error("Failed to expire inventory reservation", {
          reservationId: reservation.id,
          error,
        });
      }
    }
  },
);

const fulfilmentTransitions: Record<string, string[]> = {
  pending: ["accepted", "rejected", "cancelled"],
  accepted: ["preparing", "cancelled"],
  preparing: ["packed", "cancelled"],
  packed: ["ready"],
  ready: ["dispatched"],
  dispatched: ["delivered"],
};

type SellerFulfilmentRequest = {
  sellerOrderId?: unknown;
  status?: unknown;
};

type SellerInventoryRequest = {
  productId?: unknown;
  stockQuantity?: unknown;
};

export const updateSellerInventory = onCall<SellerInventoryRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const sellerId = request.auth?.uid;
    if (!sellerId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const productId = stringValue(request.data.productId, "productId");
    const stockQuantity = request.data.stockQuantity;
    if (typeof stockQuantity !== "number" ||
        !Number.isSafeInteger(stockQuantity) || stockQuantity < 0) {
      throw new HttpsError("invalid-argument", "stockQuantity must be a non-negative integer.");
    }

    const productRef = db.collection("products").doc(productId);
    const now = new Date();
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(productRef);
      const product = snapshot.data() as Record<string, unknown> | undefined;
      if (!snapshot.exists || !product) {
        throw new HttpsError("not-found", "Product was not found.");
      }
      if (product.sellerId !== sellerId) {
        throw new HttpsError("permission-denied", "Product is not owned by you.");
      }
      const reserved = product.reservedQuantity;
      const sold = product.soldQuantity;
      if (![reserved, sold].every((value) =>
        typeof value === "number" && Number.isSafeInteger(value) && value >= 0)) {
        throw new HttpsError("failed-precondition", "Product inventory is invalid.");
      }
      if (stockQuantity < (reserved as number) + (sold as number)) {
        throw new HttpsError(
          "failed-precondition",
          "Stock cannot be lower than reserved and sold quantities.",
        );
      }
      transaction.update(productRef, {
        stockQuantity,
        updatedAt: now,
      });
    });
    return { schemaVersion, productId, stockQuantity };
  },
);

export const updateTrustedSellerFulfilment = onCall<SellerFulfilmentRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const sellerId = request.auth?.uid;
    if (!sellerId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const sellerOrderId = stringValue(request.data.sellerOrderId, "sellerOrderId");
    const nextStatus = stringValue(request.data.status, "status");
    const orderRef = db.collection("sellerOrders").doc(sellerOrderId);
    const eventRef = db.collection("orderEvents").doc();
    const now = new Date();
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(orderRef);
      const order = snapshot.data() as Record<string, unknown> | undefined;
      if (!snapshot.exists || !order || order.sellerId !== sellerId) {
        throw new HttpsError("permission-denied", "Seller order is not assigned to you.");
      }
      if (order.schemaVersion !== schemaVersion) {
        throw new HttpsError("failed-precondition", "Legacy orders require migration.");
      }
      const currentStatus = stringValue(
        order.fulfilmentStatus ?? order.status,
        "fulfilmentStatus",
      );

      if (!fulfilmentTransitions[currentStatus]?.includes(nextStatus)) {
        throw new HttpsError(
          "failed-precondition",
          `Cannot move fulfilment from ${currentStatus} to ${nextStatus}.`,
        );
      }
      transaction.update(orderRef, {
        fulfilmentStatus: nextStatus,
        updatedAt: now,
        ...(nextStatus === "delivered" ? { deliveredAt: now } : {}),
      });
      transaction.create(eventRef, {
        schemaVersion,
        parentOrderId: order.parentOrderId,
        sellerOrderId,
        actorType: "seller",
        actorId: sellerId,
        eventType: "fulfilment_status_changed",
        fromStatus: currentStatus,
        toStatus: nextStatus,
        createdAt: now,
      });
    });
    return { schemaVersion, sellerOrderId, status: nextStatus };
  },
);

type CancelOrderRequest = { parentOrderId?: unknown };

export const cancelTrustedOrder = onCall<CancelOrderRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const buyerId = request.auth?.uid;
    if (!buyerId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const parentOrderId = stringValue(request.data.parentOrderId, "parentOrderId");
    const parentRef = db.collection("customerOrders").doc(parentOrderId);
    const eventRef = db.collection("orderEvents").doc();
    const now = new Date();
    await db.runTransaction(async (transaction) => {
      const parentSnapshot = await transaction.get(parentRef);
      const parent = parentSnapshot.data() as Record<string, unknown> | undefined;
      if (!parentSnapshot.exists || !parent || parent.buyerId !== buyerId) {
        throw new HttpsError("permission-denied", "Order is not owned by you.");
      }
      if (parent.schemaVersion !== schemaVersion ||
          ["cancelled", "fulfilled"].includes(String(parent.orderStatus))) {
        throw new HttpsError("failed-precondition", "Order cannot be cancelled.");
      }
      const reservationsSnapshot = await transaction.get(
        db.collection("inventoryReservations")
          .where("parentOrderId", "==", parentOrderId)
          .where("state", "==", "active"),
      );
      const sellerOrdersSnapshot = await transaction.get(
        db.collection("sellerOrders").where("parentOrderId", "==", parentOrderId),
      );
      const productSnapshots = new Map<string, Record<string, unknown>>();
      const reservationUpdates: Array<{
        ref: DocumentReference;
        data: Record<string, unknown>;
      }> = [];
      const quantities = new Map<string, number>();
      for (const reservationSnapshot of reservationsSnapshot.docs) {
        const reservation = reservationSnapshot.data() as Record<string, unknown>;
        const productId = stringValue(reservation.productId, "productId");
        const quantity = reservation.quantity;
        if (typeof quantity !== "number" || !Number.isSafeInteger(quantity) || quantity <= 0) {
          throw new HttpsError("failed-precondition", "Reservation quantity is invalid.");
        }
        quantities.set(productId, (quantities.get(productId) ?? 0) + quantity);
        reservationUpdates.push({
          ref: reservationSnapshot.ref,
          data: {
            state: "released",
            releaseReason: "order_cancelled",
            processedBy: buyerId,
            processedAt: now,
          },
        });
        if (!productSnapshots.has(productId)) {
          const productSnapshot = await transaction.get(
            db.collection("products").doc(productId),
          );
          const product = productSnapshot.data() as Record<string, unknown> | undefined;
          if (!productSnapshot.exists || !product) {
            throw new HttpsError("failed-precondition", "Reserved product was not found.");
          }
          productSnapshots.set(productId, product);
        }
      }
      for (const reservationUpdate of reservationUpdates) {
        transaction.update(reservationUpdate.ref, reservationUpdate.data);
      }
      for (const [productId, quantity] of quantities) {
        const product = productSnapshots.get(productId)!;
        const reserved = product.reservedQuantity;
        if (typeof reserved !== "number" || !Number.isSafeInteger(reserved) ||
            reserved < quantity) {
          throw new HttpsError("failed-precondition", "Product inventory is inconsistent.");
        }
        transaction.update(db.collection("products").doc(productId), {
          reservedQuantity: reserved - quantity,
          inventoryVersion: (product.inventoryVersion as number | undefined ?? 0) + 1,
          updatedAt: now,
        });
      }
      transaction.update(parentRef, {
        orderStatus: "cancelled",
        cancelledAt: now,
        updatedAt: now,
      });
      for (const sellerOrder of sellerOrdersSnapshot.docs) {
        const data = sellerOrder.data() as Record<string, unknown>;
        if (!["delivered", "cancelled", "rejected"].includes(
          String(data.fulfilmentStatus ?? data.status),
        )) {
          transaction.update(sellerOrder.ref, {
            fulfilmentStatus: "cancelled",
            status: "cancelled",
            cancelledAt: now,
            updatedAt: now,
          });
        }
      }
      transaction.create(eventRef, {
        schemaVersion,
        parentOrderId,
        actorType: "buyer",
        actorId: buyerId,
        eventType: "order_cancelled",
        toStatus: "cancelled",
        createdAt: now,
        metadata: { releasedReservationCount: reservationsSnapshot.size },
      });
    });
    return { schemaVersion, parentOrderId, status: "cancelled" };
  },
);

type AssignTransportRequest = {
  sellerOrderId?: unknown;
  transport?: unknown;
};

export const assignSellerTransport = onCall<AssignTransportRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const sellerId = request.auth?.uid;
    if (!sellerId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const sellerOrderId = stringValue(request.data.sellerOrderId, "sellerOrderId");
    if (typeof request.data.transport !== "object" || request.data.transport === null) {
      throw new HttpsError("invalid-argument", "transport is required.");
    }
    const orderRef = db.collection("sellerOrders").doc(sellerOrderId);
    const eventRef = db.collection("orderEvents").doc();
    const now = new Date();
    const assignment = transportAssignment(request.data.transport as Record<string, unknown>);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(orderRef);
      const order = snapshot.data() as Record<string, unknown> | undefined;
      if (!snapshot.exists || !order || order.sellerId !== sellerId) {
        throw new HttpsError("permission-denied", "Seller order is not assigned to you.");
      }
      const fulfilmentStatus = order.fulfilmentStatus ?? order.status;
      if (!["accepted", "preparing", "packed", "ready"].includes(fulfilmentStatus as string)) {
        throw new HttpsError("failed-precondition", "Transport can be assigned after the order is accepted.");
      }
      if (order.deliveryMode === "fast" &&
          assignment.transportType !== "seller_managed_fast") {
        throw new HttpsError("failed-precondition", "Fast Delivery requires seller-managed fast transport.");
      }
      transaction.update(orderRef, {
        transportAssignment: assignment,
        deliveryStage: "assigned",
        updatedAt: now,
      });
      transaction.create(eventRef, {
        schemaVersion,
        parentOrderId: order.parentOrderId,
        sellerOrderId,
        actorType: "seller",
        actorId: sellerId,
        eventType: "transport_assigned",
        toStatus: "assigned",
        metadata: assignment,
        createdAt: now,
      });
    });
    return { schemaVersion, sellerOrderId, deliveryStage: "assigned" };
  },
);

type UpdateDeliveryStageRequest = {
  sellerOrderId?: unknown;
  deliveryStage?: unknown;
};

export const updateSellerDeliveryStage = onCall<UpdateDeliveryStageRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request) => {
    const sellerId = request.auth?.uid;
    if (!sellerId) throw new HttpsError("unauthenticated", "Authentication is required.");
    const sellerOrderId = stringValue(request.data.sellerOrderId, "sellerOrderId");
    const nextStage = stringValue(request.data.deliveryStage, "deliveryStage");
    if (!deliveryStages.includes(nextStage as typeof deliveryStages[number])) {
      throw new HttpsError("invalid-argument", "deliveryStage is invalid.");
    }
    const orderRef = db.collection("sellerOrders").doc(sellerOrderId);
    const eventRef = db.collection("orderEvents").doc();
    const now = new Date();
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(orderRef);
      const order = snapshot.data() as Record<string, unknown> | undefined;
      if (!snapshot.exists || !order || order.sellerId !== sellerId) {
        throw new HttpsError("permission-denied", "Seller order is not assigned to you.");
      }
      const currentStage = (order.deliveryStage as string | undefined) ?? "assigned";
      if (!deliveryStageTransition(currentStage, nextStage)) {
        throw new HttpsError("failed-precondition", `Cannot move delivery from ${currentStage} to ${nextStage}.`);
      }
      if (nextStage === "delivered") {
        const reservationsSnapshot = await transaction.get(
          db.collection("inventoryReservations")
            .where("parentOrderId", "==", order.parentOrderId)
            .where("sellerId", "==", sellerId)
            .where("state", "==", "active"),
        );
        const reservationData: Array<{
          ref: DocumentReference;
          productRef: DocumentReference;
          quantity: number;
          product: Record<string, unknown>;
        }> = [];
        for (const reservationSnapshot of reservationsSnapshot.docs) {
          const reservation = reservationSnapshot.data() as Record<string, unknown>;
          const quantity = reservation.quantity;
          if (typeof quantity !== "number" ||
              !Number.isSafeInteger(quantity) || quantity <= 0) {
            throw new HttpsError("failed-precondition", "Reservation quantity is invalid.");
          }
          const productRef = db.collection("products").doc(
            stringValue(reservation.productId, "productId"),
          );
          const productSnapshot = await transaction.get(productRef);
          const product = productSnapshot.data() as Record<string, unknown> | undefined;
          if (!productSnapshot.exists || !product) {
            throw new HttpsError("failed-precondition", "Reserved product was not found.");
          }
          reservationData.push({
            ref: reservationSnapshot.ref,
            productRef,
            quantity,
            product,
          });
        }
        for (const reservation of reservationData) {
          const reserved = reservation.product.reservedQuantity;
          const sold = reservation.product.soldQuantity;
          if (typeof reserved !== "number" || !Number.isSafeInteger(reserved) ||
              typeof sold !== "number" || !Number.isSafeInteger(sold) ||
              reserved < reservation.quantity) {
            throw new HttpsError("failed-precondition", "Product inventory is inconsistent.");
          }
          transaction.update(reservation.productRef, {
            reservedQuantity: reserved - reservation.quantity,
            soldQuantity: sold + reservation.quantity,
            inventoryVersion: (reservation.product.inventoryVersion as number | undefined ?? 0) + 1,
            updatedAt: now,
          });
          transaction.update(reservation.ref, {
            state: "committed",
            processedBy: sellerId,
            processedAt: now,
          });
        }
      }
      const update: Record<string, unknown> = {
        deliveryStage: nextStage,
        updatedAt: now,
      };
      if (nextStage === "delivered") {
        update.fulfilmentStatus = "delivered";
        update.status = "delivered";
        update.deliveredAt = now;
      }
      transaction.update(orderRef, update);
      transaction.create(eventRef, {
        schemaVersion,
        parentOrderId: order.parentOrderId,
        sellerOrderId,
        actorType: "seller",
        actorId: sellerId,
        eventType: "delivery_stage_changed",
        fromStatus: currentStage,
        toStatus: nextStage,
        createdAt: now,
      });
    });
    return { schemaVersion, sellerOrderId, deliveryStage: nextStage };
  },
);

export const createTrustedCheckout = onCall<CheckoutRequest>(
  { region: "asia-south1", enforceAppCheck: false },
  async (request): Promise<CheckoutResponse> => {
    const buyerId = request.auth?.uid;
    if (!buyerId) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }
    const checkoutRequestId = stringValue(
      request.data.checkoutRequestId,
      "checkoutRequestId",
    );

    if (!/^[A-Za-z0-9_-]{8,128}$/.test(checkoutRequestId)) {
      throw new HttpsError("invalid-argument", "checkoutRequestId is invalid.");
    }
    const cartItemIds = stringList(request.data.cartItemIds, "cartItemIds");
    const addressId = stringValue(request.data.addressId, "addressId");
    const deliveryMode = stringValue(request.data.deliveryMode, "deliveryMode");
    if (!["fast", "regular"].includes(deliveryMode)) {
      throw new HttpsError("invalid-argument", "deliveryMode is invalid.");
    }

    const userRef = db.collection("users").doc(buyerId);
    const requestRef = db.collection("checkoutRequests")
      .doc(`${buyerId}_${checkoutRequestId}`);
    const cartRefs = cartItemIds.map((id) =>
      userRef.collection("cartItems").doc(id));
    const parentRef = db.collection("customerOrders").doc();
    const now = new Date();
    const expiresAt = new Date(now.getTime() + reservationMinutes * 60_000);

    return db.runTransaction(async (transaction) => {
      const requestSnapshot = await transaction.get(requestRef);
      if (requestSnapshot.exists) {
        const previous = requestSnapshot.data() as Record<string, unknown>;
        if (previous.state === "completed" &&
            typeof previous.parentOrderId === "string") {
          return {
            schemaVersion,
            parentOrderId: previous.parentOrderId,
            sellerOrderIds: (previous.sellerOrderIds as string[]) ?? [],
            totalMinor: previous.totalMinor as number,
            currency: previous.currency as string,
            paymentStatus: "pending",
          };
        }
        throw new HttpsError("already-exists", "Checkout request is already processed.");
      }
      const userSnapshot = await transaction.get(userRef);
      const cartSnapshots = await Promise.all(
        cartRefs.map((ref) => transaction.get(ref)),
      );
      const productRefs: DocumentReference[] = cartSnapshots.map((snapshot) => {
        const line = snapshot.data() as Record<string, unknown> | undefined;
        if (!snapshot.exists || !line) {
          throw new HttpsError("failed-precondition", "Cart item is unavailable.");
        }
        return db.collection("products").doc(stringValue(line.productId, "productId"));
      });
      const productSnapshots = await Promise.all(
        productRefs.map((ref) => transaction.get(ref)),
      );
      const user = userSnapshot.data() as Record<string, unknown> | undefined;
      if (!userSnapshot.exists || !user) {
        throw new HttpsError("failed-precondition", "Buyer profile was not found.");
      }
      const address = addressFromUser(user, addressId);
      const sellerItems = new Map<string, Array<Record<string, unknown>>>();
      const sellerFees = new Map<string, number>();
      const reservations: Array<{
        ref: DocumentReference;
        productRef: DocumentReference;
        product: Record<string, unknown>;
        quantity: number;
        data: Record<string, unknown>;
      }> = [];
      let subtotalMinor = 0;

      for (let i = 0; i < cartSnapshots.length; i += 1) {
        const line = cartSnapshots[i].data() as Record<string, unknown>;
        const product = productSnapshots[i].data() as Record<string, unknown> | undefined;
        if (!productSnapshots[i].exists || !product) {
          throw new HttpsError("failed-precondition", "Product is unavailable.");
        }
        const productId = stringValue(line.productId, "productId");
        const sellerId = stringValue(product.sellerId, "sellerId");
        if (line.sellerId !== sellerId || product.status !== "active") {
          throw new HttpsError("failed-precondition", "Cart product is invalid.");
        }
        const buyerCountry = countryCode(address.countryCode);
        const sellerCountry = countryCode(product.sellerCountryCode);
        if (deliveryMode === "regular") {
          const minDays = product.regularDeliveryMinDays;
          const maxDays = product.regularDeliveryMaxDays;
          if (product.supportsRegularDelivery !== true ||
              !buyerCountry || buyerCountry !== sellerCountry ||
              typeof minDays !== "number" || typeof maxDays !== "number" ||
              !Number.isInteger(minDays) || !Number.isInteger(maxDays) ||
              minDays < 1 || maxDays < minDays || maxDays > 7) {
            throw new HttpsError(
              "failed-precondition",
              "Regular Delivery is unavailable for this product.",
            );
          }
        } else {
          const buyerLocation = coordinates(address.location);
          const sellerLocation = coordinates(product.sellerServiceLocation);
          const minDays = product.fastDeliveryMinDays;
          const maxDays = product.fastDeliveryMaxDays;
          if (product.supportsFastDelivery !== true ||
              product.sellerManagedFastDelivery !== true ||
              !buyerLocation || !sellerLocation ||
              distanceKm(buyerLocation, sellerLocation) > 60 ||
              typeof minDays !== "number" || typeof maxDays !== "number" ||
              !Number.isInteger(minDays) || !Number.isInteger(maxDays) ||
              minDays < 1 || maxDays < minDays) {
            throw new HttpsError(
              "failed-precondition",
              "Fast Delivery is unavailable for this product.",
            );
          }
        }
        const quantity = positiveInteger(line.quantity, "quantity");
        if (quantity > available(product)) {
          throw new HttpsError("failed-precondition", "Insufficient inventory.");
        }
        const unitPriceMinor = priceMinor(product);
        const item = {
          productId,
          sellerId,
          name: product.name,
          unit: product.unit,
          quantity,
          unitPriceMinor,
          discountMinor: 0,
          taxMinor: 0,
          lineTotalMinor: unitPriceMinor * quantity,
          currency: product.currency ?? "INR",
        };
        subtotalMinor += item.lineTotalMinor;
        sellerItems.set(sellerId, [...(sellerItems.get(sellerId) ?? []), item]);
        sellerFees.set(
          sellerId,
          (sellerFees.get(sellerId) ?? 0) + deliveryFeeMinor(product, deliveryMode),
        );
        reservations.push({
          ref: db.collection("inventoryReservations").doc(),
          productRef: productRefs[i],
          product,
          quantity,
          data: {
            schemaVersion,
            parentOrderId: parentRef.id,
            productId,
            sellerId,
            buyerId,
            quantity,
            state: "active",
            createdAt: now,
            expiresAt,
          },
        });
      }
      const deliveryFeeMinorTotal = [...sellerFees.values()]
        .reduce((total, value) => total + value, 0);
      const totalMinor = subtotalMinor + deliveryFeeMinorTotal;
      const sellerOrderIds: string[] = [];
      for (const [sellerId, items] of sellerItems.entries()) {
        const sellerRef = db.collection("sellerOrders")
          .doc(`${parentRef.id}_${sellerId}`);
        sellerOrderIds.push(sellerRef.id);
        const sellerSubtotal = items.reduce(
          (total, item) => total + (item.lineTotalMinor as number),
          0,
        );
        const sellerFee = sellerFees.get(sellerId) ?? 0;
        transaction.create(sellerRef, {
          schemaVersion,
          id: sellerRef.id,
          parentOrderId: parentRef.id,
          buyerId,
          sellerId,
          items,
          subtotalMinor: sellerSubtotal,
          deliveryFeeMinor: sellerFee,
          totalMinor: sellerSubtotal + sellerFee,
          currency: "INR",
          fulfilmentStatus: "pending",
          paymentStatus: "pending",
          deliveryMode,
          shippingAddress: address,
          deliveryAddressSnapshot: address,
          createdAt: now,
          updatedAt: now,
        });
      }
      for (const reservation of reservations) {
        const reserved = reservation.product.reservedQuantity as number | undefined ?? 0;
        const version = reservation.product.inventoryVersion as number | undefined ?? 0;
        transaction.update(reservation.productRef, {
          reservedQuantity: reserved + reservation.quantity,
          inventoryVersion: version + 1,
          updatedAt: now,
        });
        transaction.create(reservation.ref, reservation.data);
      }
      transaction.create(parentRef, {
        schemaVersion,
        id: parentRef.id,
        buyerId,
        sellerIds: [...sellerItems.keys()],
        orderStatus: "pending",
        paymentStatus: "pending",
        deliveryMode,
        currency: "INR",
        subtotalMinor,
        discountMinor: 0,
        taxMinor: 0,
        handlingFeeMinor: 0,
        deliveryFeeMinor: deliveryFeeMinorTotal,
        totalMinor,
        shippingAddress: address,
        deliveryAddressSnapshot: address,
        checkoutRequestId,
        createdAt: now,
        updatedAt: now,
      });
      transaction.create(requestRef, {
        schemaVersion,
        requestId: checkoutRequestId,
        buyerId,
        state: "completed",
        parentOrderId: parentRef.id,
        sellerOrderIds,
        totalMinor,
        currency: "INR",
        createdAt: now,
        completedAt: now,
        expiresAt,
      });
      return {
        schemaVersion,
        parentOrderId: parentRef.id,
        sellerOrderIds,
        totalMinor,
        currency: "INR",
        paymentStatus: "pending",
      };
    });
  },
);
