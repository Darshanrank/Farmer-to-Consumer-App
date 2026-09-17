import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

admin.initializeApp();
const db = admin.firestore();

// Triggered when a new user signs up in Firebase Auth
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName, photoURL } = user;
  
  await db.collection("users").doc(uid).set({
    userId: uid,
    email: email || "",
    displayName: displayName || "",
    photoUrl: photoURL || null,
    // We no longer default everyone to 'seller'.
    // A separate onboarding flow/function will set their actual role.
    role: "unassigned",
    isEmailVerified: user.emailVerified,
    status: "active",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
  
  functions.logger.info(`User profile created for ${uid}`);
});

// Triggered when a user is deleted from Firebase Auth
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const { uid } = user;
  
  await db.collection("users").doc(uid).delete();
  
  functions.logger.info(`User profile deleted for ${uid}`);
});

// Callable function to assign a role to a newly registered user
export const assignRole = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to assign a role."
    );
  }

  const uid = context.auth.uid;
  const requestedRole = data.role;

  if (requestedRole !== "buyer" && requestedRole !== "seller") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Role must be either 'buyer' or 'seller'."
    );
  }

  const userRef = db.collection("users").doc(uid);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "User profile not found."
    );
  }

  const userData = userDoc.data();
  if (userData?.role === "buyer" || userData?.role === "seller") {
    throw new functions.https.HttpsError(
      "already-exists",
      "User role has already been assigned."
    );
  }

  await userRef.update({
    role: requestedRole,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true, role: requestedRole };
});
