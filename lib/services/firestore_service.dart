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

  Future<int> getNextLocalId() async {
    // Get a reference to the document that holds our counter
    final counterRef = _db.collection('counters').doc('userCounter');

    // Run a transaction to safely get and increment the counter
    return _db.runTransaction((transaction) async {
      // Get the current counter document
      final snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        // If the counter doesn't exist, this is the first user.
        // Create the counter document with an initial value.
        transaction.set(counterRef, {'currentId': 1});
        return 1;
      }

      // If the counter exists, get the current ID and increment it
      final currentId = snapshot.data()!['currentId'] as int;
      final newId = currentId + 1;
      transaction.update(counterRef, {'currentId': newId});

      return newId;
    });
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