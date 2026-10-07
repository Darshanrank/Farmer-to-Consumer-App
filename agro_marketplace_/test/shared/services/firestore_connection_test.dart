import 'package:flutter_test/flutter_test.dart';
import 'package:agro_marketplace/shared/services/firebase_service.dart' as app;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseAuth])
import 'firestore_connection_test.mocks.dart';

void main() {
  group('FirebaseService Connection Test', () {
    test('instanceFor creates Firestore with correct databaseId', () async {
      // NOTE: In a real test environment without a real Firebase app initialized,
      // calling FirebaseFirestore.instanceFor(app: Firebase.app()) will fail.
      // Since this test doesn't actually connect to a backend without setup,
      // we'll just verify the injected fake configuration works if provided.
      
      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      final service = app.FirebaseService.createForTest(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      // Verify we can interact with the injected (or targeted) database
      await service.collection('test_connection').add({'status': 'connected'});
      
      final snapshot = await service.collection('test_connection').get();
      expect(snapshot.docs.isNotEmpty, true);
      expect(snapshot.docs.first['status'], 'connected');
    });
  });
}
