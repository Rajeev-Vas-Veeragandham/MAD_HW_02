import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // REGISTER USER
  static Future<String?> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      print('Starting registration for: $email');
      
      // Validate inputs
      if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
        return 'All fields are required';
      }
      
      if (password.length < 6) {
        return 'Password must be at least 6 characters';
      }

      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User created with UID: ${userCred.user!.uid}');

      String uid = userCred.user!.uid;

      // Save user data to Firestore
      await _db.collection("users").doc(uid).set({
        "uid": uid,
        "email": email.trim(),
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "role": "user",
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      print('User data saved to Firestore');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return 'Registration failed: ${e.message}';
      }
    } catch (e) {
      print('Unexpected error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // LOGIN USER
  static Future<String?> login(String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return 'Please enter both email and password';
      }

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        default:
          return 'Login failed: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  // GET USER DATA
  static Future<Map<String, dynamic>?> getUserData() async {
    if (_auth.currentUser == null) {
      print('No current user found');
      return null;
    }
    
    try {
      var doc = await _db.collection("users").doc(_auth.currentUser!.uid).get();
      if (doc.exists && doc.data() != null) {
        print('User data retrieved successfully: ${doc.data()}');
        return doc.data();
      } else {
        print('No user data found in Firestore for UID: ${_auth.currentUser!.uid}');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;
}