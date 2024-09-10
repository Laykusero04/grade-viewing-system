import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> createUser({
    required String uid,
    required String email,
    required int role,
    required String fullname,
    required String schoolId,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'fullname': fullname,
        'schoolId': schoolId,
      });
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> updateUserRole(String uid, int newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('subjects').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting subjects: $e');
      return [];
    }
  }

  Future<void> addSubject(Map<String, dynamic> subjectData) async {
    try {
      await _firestore.collection('subjects').add(subjectData);
    } catch (e) {
      print('Error adding subject: $e');
      throw e;
    }
  }

  Future<void> updateSubject(
      String subjectId, Map<String, dynamic> subjectData) async {
    try {
      await _firestore
          .collection('subjects')
          .doc(subjectId)
          .update(subjectData);
    } catch (e) {
      print('Error updating subject: $e');
      throw e;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).delete();
    } catch (e) {
      print('Error deleting subject: $e');
      throw e;
    }
  }
}
