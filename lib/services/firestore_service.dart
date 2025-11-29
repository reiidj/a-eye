/*
 * Program Title: firestore_service.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is located in `lib/services/` and serves as the persistent
 *   data layer for the application. It acts as the interface between the
 *   Flutter frontend and the Cloud Firestore NoSQL database. It handles user
 *   profile management (Onboarding Flow) and the storage/retrieval of
 *   analysis results (Analysis Flow), ensuring data availability across
 *   app restarts and devices.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To encapsulate all database operations (CRUD), ensuring consistent
 *   data schema application, atomic ID generation, and efficient real-time
 *   data synchronization.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * DocumentSnapshot: Represents a single record (e.g., User Profile).
 *     * QuerySnapshot: Represents a list of records (e.g., Scan History).
 *     * Map<String, dynamic>: Standard JSON-like format for Firestore data.
 *
 *   Algorithms:
 *     * Atomic Transactions: Used in `getNextLocalId` to ensure unique
 *       user IDs are generated safely even with concurrent sign-ups.
 *     * Stream Subscription: `getScansForUser` uses persistent listeners
 *       to push updates to the UI instantly when new scans are added.
 *
 *   Control:
 *     * Asynchronous Execution: All DB calls return `Future` or `Stream` to
 *       prevent UI thread blocking during network latency.
 */


import 'package:cloud_firestore/cloud_firestore.dart';

/// Class: FirestoreService
/// Purpose: Singleton-like service for handling all Firestore DB interactions.
class FirestoreService {
  // Get a reference to the root of the Firestore database singleton
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Methods ---

  /// Adds or Updates a user document in the 'users' collection.
  /// The document ID is strictly set to the Firebase Auth UID for security.
  Future<void> addUser(String userId, Map<String, dynamic> userData) {
    // Control: .set() with Merge is implied or acts as upsert
    return _db.collection('users').doc(userId).set(userData);
  }

  /*
   * Function: getNextLocalId
   * Purpose: Generates a sequential integer ID for internal use.
   * Algorithm: Transactional Increment (Read-Modify-Write atomicity).
   */
  Future<int> getNextLocalId() async {
    // Reference to a global counter document
    final counterRef = _db.collection('counters').doc('userCounter');

    // -- ALGORITHM: ATOMIC TRANSACTION --
    // Ensures that if two users sign up exactly at the same time,
    // they do not get the same ID. The DB locks the document during update.
    return _db.runTransaction((transaction) async {
      // 1. Read
      final snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        // Edge Case: First user ever initializes the counter
        transaction.set(counterRef, {'currentId': 1});
        return 1;
      }

      // 2. Modify
      final currentId = snapshot.data()!['currentId'] as int;
      final newId = currentId + 1;

      // 3. Write
      transaction.update(counterRef, {'currentId': newId});

      return newId;
    });
  }

  /// Retrieves a single user document to populate the Profile or Welcome screen.
  Future<DocumentSnapshot> getUser(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  // --- Scan Methods ---

  /*
   * Function: addScan
   * Purpose: Saves an analysis result to the user's private history.
   * Structure: /users/{uid}/scans/{scanId} (Subcollection Pattern)
   */
  Future<DocumentReference> addScan(String userId, Map<String, dynamic> scanData) {
    // Algorithm: .add() automatically generates a unique, random ID for the scan
    return _db.collection('users').doc(userId).collection('scans').add(scanData);
  }

  /*
   * Function: getScansForUser
   * Purpose: Provides a live feed of the user's history.
   * Returns: Stream<QuerySnapshot> that emits new data whenever the DB changes.
   */
  Stream<QuerySnapshot> getScansForUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('scans')
    // Algorithm: Sorting
    // Orders results so the newest scan appears at the top of the list
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}