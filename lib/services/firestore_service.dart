
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Get a reference to the root of the Firestore database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Methods ---

  /// Adds a new user document to the 'users' collection.
  /// The document ID will be the user's unique ID (uid) from Firebase Auth.
  Future<void> addUser(String userId, Map<String, dynamic> userData) {
    return _db.collection('users').doc(userId).set(userData);
  }

  /// Retrieves a single user document by their user ID.
  Future<DocumentSnapshot> getUser(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  // --- Scan Methods ---

  /// Adds a new scan document to a 'scans' subcollection within a user's document.
  Future<DocumentReference> addScan(String userId, Map<String, dynamic> scanData) {
    // This creates a new scan with a unique, auto-generated ID.
    return _db.collection('users').doc(userId).collection('scans').add(scanData);
  }

  /// Retrieves a stream of all scans for a specific user, ordered by timestamp.
  /// A Stream is used here so the UI can automatically update if the data changes.
  Stream<QuerySnapshot> getScansForUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}