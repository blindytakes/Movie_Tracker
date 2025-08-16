import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/viewing_entry.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection reference for user's viewing entries
  CollectionReference get _viewingEntriesCollection {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('viewing_entries');
  }

  // Add a new viewing entry
  Future<void> addViewingEntry(ViewingEntry entry) async {
    try {
      await _viewingEntriesCollection.doc(entry.id).set(entry.toMap());
    } catch (e) {
      throw Exception('Failed to add viewing entry: $e');
    }
  }

  // Update an existing viewing entry
  Future<void> updateViewingEntry(ViewingEntry entry) async {
    try {
      await _viewingEntriesCollection.doc(entry.id).update(entry.toMap());
    } catch (e) {
      throw Exception('Failed to update viewing entry: $e');
    }
  }

  // Delete a viewing entry
  Future<void> deleteViewingEntry(String entryId) async {
    try {
      await _viewingEntriesCollection.doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete viewing entry: $e');
    }
  }

  // Get all viewing entries for the current user
  Stream<List<ViewingEntry>> getViewingEntries() {
    return _viewingEntriesCollection
        .orderBy('dateWatched', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ViewingEntry.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get viewing entries by type (movie/tv)
  Stream<List<ViewingEntry>> getViewingEntriesByType(String type) {
    return _viewingEntriesCollection
        .where('type', isEqualTo: type)
        .orderBy('dateWatched', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ViewingEntry.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Search viewing entries by title
  Stream<List<ViewingEntry>> searchViewingEntries(String searchTerm) {
    return _viewingEntriesCollection
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ViewingEntry.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Sign in anonymously (for demo purposes)
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}