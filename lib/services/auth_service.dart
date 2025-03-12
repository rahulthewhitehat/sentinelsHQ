import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not, create new user doc
      final userExists = await _firestore.collection('users').doc(result.user?.uid).get();
      if (!userExists.exists) {
        await _createUserInFirestore(result.user, {
          'fullName': result.user?.displayName,
          'email': result.user?.email,
          'profilePicture': result.user?.photoURL,
          'role': 'team_member', // Default role
          'isVerified': false, // Default verification status
        },
          'team_member'
        );
      }

      return result.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Create a new user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email,
      String password,
      Map<String, dynamic> userData,
      String? role,
      ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Print out the userData to verify its structure
      print('User Data being stored: $userData');
      print('Role: $role');

      // Create user document in Firestore in the role-specific collection
      await _createUserInFirestore(result.user, userData, role);

      return result.user;
    } catch (e) {
      print('Detailed Error creating user: $e');
      rethrow;
    }
  }

  // Create user document in Firestore in the role-specific collection
  Future<void> _createUserInFirestore(
      User? user,
      Map<String, dynamic> userData,
      String? role,
      ) async {
    if (user != null) {
      // Ensure role is not null, default to 'team_member'
      role ??= 'team_member';

      // Sanitize user data
      userData = {
        ...userData,
        'role': role,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'email': user.email,
        'uid': user.uid,
      };

      // Create document in role-specific members collection
      await _firestore
          .collection('roles')
          .doc(role)
          .collection('members')
          .doc(user.uid)
          .set(userData);

      // Create a more compact user reference in users collection
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': role,
        'name': userData['fullName'] ?? user.displayName,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': user.phoneNumber,
      });
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Error sending verification email: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> userData, String role
      ) async {
    try {
      // Determine the collection based on role
      final userDoc = _firestore.collection('roles').doc(role)
          .collection('members')
          .doc(uid);

      // Update the user document
      await userDoc.update(userData);

      // Optional: Handle profile picture or other specific updates
      if (userData.containsKey('profilePicture')) {
        // Additional logic for profile picture if needed
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user role
  Future<String> getUserRole(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.get('role') as String;
      }
      return 'team_member'; // Default role
    } catch (e) {
      print('Error getting user role: $e');
      return 'team_member';
    }
  }

  Future<bool> getUserVerificationStatus(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.get('isVerified') as bool;
      }
      return false; // Default
    } catch (e) {
      print('Error getting user role: $e');
      return false;
    }
  }
}