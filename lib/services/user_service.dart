import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser != null) {
      return await _firestoreService.getUserData(currentUser!.uid);
    }
    return null;
  }

  // Add this new method
  Future<User?> createUser({
    required String email,
    required String password,
    required String fullname,
    required int role,
    required String schoolId,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestoreService.createUser(
          uid: userCredential.user!.uid,
          email: email,
          role: role,
          fullname: fullname,
          schoolId: schoolId,
        );
        notifyListeners();
        return userCredential.user;
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
    return null;
  }
}
