import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }

      // Get or create user profile in Firestore
      final appUser = await _getOrCreateUserProfile(user, 'email');
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign up with email and password
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign up failed');
      }

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();
      final updatedUser = _auth.currentUser!;

      // Send email verification
      await sendEmailVerification();

      // Create user profile in Firestore
      final appUser = await _getOrCreateUserProfile(updatedUser, 'email');
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with Google
  Future<AppUser> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google sign in failed');
      }

      // Get or create user profile in Firestore with retry logic
      AppUser appUser;
      try {
        appUser = await _getOrCreateUserProfile(user, 'google');
      } catch (e) {
        // Retry once if Firestore operation fails
        await Future.delayed(const Duration(milliseconds: 500));
        appUser = await _getOrCreateUserProfile(user, 'google');
      }
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign in with Facebook
  Future<AppUser> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        throw Exception('Facebook sign in was cancelled or failed');
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      // Sign in to Firebase with the Facebook credential
      final userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Facebook sign in failed');
      }

      // Get or create user profile in Firestore
      final appUser = await _getOrCreateUserProfile(user, 'facebook');
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      if (user.email == null || user.email!.isEmpty) {
        throw Exception('User email is not available');
      }
      if (user.emailVerified) {
        // Don't throw error, just return silently if already verified
        return;
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'too-many-requests') {
        throw Exception('Too many verification emails sent. Please wait a few minutes and try again.');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Failed to send verification email: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (e.toString().contains('already verified')) {
        return; // Silently return if already verified
      }
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    await sendEmailVerification();
  }

  // Get or create user profile in Firestore
  Future<AppUser> _getOrCreateUserProfile(User user, String provider) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // User profile exists, update if needed
        final data = userSnapshot.data();
        if (data == null) {
          // If data is null, create new profile
          final appUser = AppUser.fromFirebaseAuth(
            user.uid,
            user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
            provider: provider,
          );
          await userDoc.set(appUser.toFirestore());
          return appUser;
        }
        return AppUser.fromFirestore(data, user.uid);
      } else {
        // Create new user profile
        final appUser = AppUser.fromFirebaseAuth(
          user.uid,
          user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
          provider: provider,
        );

        await userDoc.set(appUser.toFirestore());
        return appUser;
      }
    } on FirebaseException catch (e) {
      // If Firestore operation fails, return user from Firebase Auth as fallback
      if (user.email != null) {
        return AppUser.fromFirebaseAuth(
          user.uid,
          user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          provider: provider,
        );
      }
      throw Exception('Failed to create user profile: ${e.message ?? e.code}');
    } catch (e) {
      // If any other error occurs, return user from Firebase Auth as fallback
      if (user.email != null) {
        return AppUser.fromFirebaseAuth(
          user.uid,
          user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          provider: provider,
        );
      }
      throw Exception('Failed to get or create user profile: $e');
    }
  }

  // Update user profile
  Future<AppUser> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();
      final updatedUser = _auth.currentUser!;

      // Update Firestore profile
      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user
      return AppUser.fromFirebaseAuth(
        updatedUser.uid,
        updatedUser.email ?? '',
        displayName: updatedUser.displayName,
        photoUrl: updatedUser.photoURL,
        provider: _getProviderFromUser(updatedUser),
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload photo to Firebase Storage
  Future<String> uploadPhoto(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // For email/password users, re-authenticate before changing password
      if (user.providerData.first.providerId == 'password') {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount({String? password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // For email/password users, re-authenticate before deleting
      if (user.providerData.first.providerId == 'password' && password != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final userId = user.uid;

      // Delete reviews by user first
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();
      final batch = _firestore.batch();
      for (final doc in reviewsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document (subcollections will be deleted via Cloud Function or manually)
      final userDoc = _firestore.collection('users').doc(userId);
      
      // Delete saved places subcollection
      final savedPlacesSnapshot = await userDoc.collection('saved_places').get();
      for (final doc in savedPlacesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete trips subcollection
      final tripsSnapshot = await userDoc.collection('trips').get();
      for (final doc in tripsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(userDoc);

      // Commit all deletions
      await batch.commit();

      // Delete photos from Storage
      final photosRef = _storage.ref().child('users/$userId');
      try {
        final listResult = await photosRef.listAll();
        for (final item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        // Ignore if folder doesn't exist
      }

      // Delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
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

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}
