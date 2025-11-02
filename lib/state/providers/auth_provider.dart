import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
      _isInitialized = true;
      notifyListeners();
    });

    // Check if user is already signed in
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadUserProfile(currentUser.uid);
      _isInitialized = true;
      notifyListeners();
    } else {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get user profile from Firestore via auth service
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _user = AppUser.fromFirebaseAuth(
          firebaseUser.uid,
          firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          provider: _getProviderFromUser(firebaseUser),
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getProviderFromUser(User user) {
    if (user.providerData.isNotEmpty) {
      final providerId = user.providerData.first.providerId;
      if (providerId.contains('google')) return 'google';
      if (providerId.contains('facebook')) return 'facebook';
    }
    return 'email';
  }

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _error = null;
      return _user;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser?> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      _error = null;
      return _user;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithGoogle();
      _error = null;
      return _user;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser?> signInWithFacebook() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithFacebook();
      _error = null;
      return _user;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.sendPasswordReset(email: email);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
