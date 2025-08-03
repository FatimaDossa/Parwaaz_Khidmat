import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final User? user;
  final String? error;

  AuthResult({this.user, this.error});
}


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<User?> signUp(String email, String password, String userType, String username) async {
  //   try {
  //     UserCredential result = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     await _firestore.collection('users').doc(result.user!.uid).set({
  //       'email': email,
  //       'userType': userType,
  //       'username': username, // ✅ Save username
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });

  //     return result.user;
  //   } catch (e) {
  //     print('Signup Error: $e');
  //     rethrow;
  //   }
  // }

  Future<AuthResult> signUp(String email, String password, String userType, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'userType': userType,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthResult(user: result.user); // ✅ Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return AuthResult(error: 'This email is already registered.');
        case 'invalid-email':
          return AuthResult(error: 'Please enter a valid email address.');
        case 'weak-password':
          return AuthResult(error: 'Password should be at least 6 characters.');
        default:
          return AuthResult(error: 'Signup failed. Please try again.');
      }
    } catch (e) {
      return AuthResult(error: 'Something went wrong. Please try again later.');
    }
  }



  // Future<User?> signIn(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result.user;
  //   } catch (e) {
  //     print('Login Error: $e');
  //     rethrow;
  //   }
  // }

  Future<AuthResult> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult(user: result.user); // ✅ Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return AuthResult(error: 'No account found for this email.');
        case 'wrong-password':
          return AuthResult(error: 'Incorrect password. Please try again.');
        case 'invalid-email':
          return AuthResult(error: 'Invalid email format.');
        default:
          return AuthResult(error: 'Login failed. Please try again.');
      }
    } catch (e) {
      return AuthResult(error: 'Something went wrong. Please try again later.');
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
