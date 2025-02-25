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
      String role, // Pass the selected role
      ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore in the role-specific collection
      await _createUserInFirestore(result.user, userData, role);

      return result.user;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Create user document in Firestore in the role-specific collection
  Future<void> _createUserInFirestore(
      User? user,
      Map<String, dynamic> userData,
      String role, // Pass the selected role
      ) async {
    if (user != null) {
      // Add the role and isVerified fields to the user data
      userData['role'] = role;
      userData['isVerified'] = false;

      // Store user data in the role-specific collection
      await _firestore.collection(role.toLowerCase()).doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        ...userData,
      });

      /*  // Also store a reference in the 'users' collection for easy lookup
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': role,
        'isVerified': false,
      }); */
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return await _auth.signOut();
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
}