const admin = require('firebase-admin');

process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";
process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
// The functions emulator runs on 5001 but we only need auth and firestore client configs.

admin.initializeApp({
  projectId: "demo-agro-market"
});

async function runTest() {
  console.log("Creating user in Auth...");
  const user = await admin.auth().createUser({
    email: 'testuser@example.com',
    password: 'password123',
    displayName: 'Test User'
  });
  console.log("User created:", user.uid);
  
  console.log("Waiting for Cloud Function onUserCreated to execute (3s)...");
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  const doc = await admin.firestore().collection('users').doc(user.uid).get();
  if (doc.exists) {
    console.log("SUCCESS: Firestore document created for user!");
    console.log(doc.data());
  } else {
    console.log("FAILURE: Firestore document not found.");
  }

  console.log("Deleting user in Auth to trigger onUserDeleted...");
  await admin.auth().deleteUser(user.uid);
  
  console.log("Waiting for Cloud Function onUserDeleted to execute (3s)...");
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  const docAfterDelete = await admin.firestore().collection('users').doc(user.uid).get();
  if (!docAfterDelete.exists) {
    console.log("SUCCESS: Firestore document deleted for user!");
  } else {
    console.log("FAILURE: Firestore document still exists.");
  }
}

runTest().catch(console.error).finally(() => process.exit(0));
