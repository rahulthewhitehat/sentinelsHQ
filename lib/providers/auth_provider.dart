import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  String _userRole = 'team_member';
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserRole();
    }
  }

  User? get user => _user;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Updated admin roles check
  bool get isAdmin => _userRole == 'admin' || _userRole == 'lead' || _userRole == 'founder' || _userRole == 'superadmin';
  bool get isTeamMember => _userRole == 'team_member';

  Future<void> _loadUserRole() async {
    if (_user != null) {
      _userRole = await _authService.getUserRole(_user!.uid);
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      await _loadUserRole();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseFirebaseAuthError(e.toString()));
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      await _loadUserRole();
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError(_parseFirebaseAuthError(e.toString()));
      return false;
    }
  }

  Future<bool> createAccount(
      String email,
      String password,
      Map<String, dynamic> userData,
      {required String role}
      ) async {
    _setLoading(true);
    try {
      _user = await _authService.createUserWithEmailAndPassword(email, password, userData, role);
      await _loadUserRole();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseFirebaseAuthError(e.toString()));
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userRole = 'team_member';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to convert Firebase error messages to user-friendly format
  String _parseFirebaseAuthError(String errorMessage) {
    if (errorMessage.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorMessage.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    } else if (errorMessage.contains('weak-password')) {
      return 'Password is too weak';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'Network connection error. Check your internet';
    } else {
      return 'Authentication failed: $errorMessage';
    }
  }
}