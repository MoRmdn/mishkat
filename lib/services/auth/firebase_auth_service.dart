import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

/// [AuthService] on Firebase Auth.
///
/// Apple goes through Firebase's own provider, which uses the native sheet on
/// iOS and the web flow on Android, and hands back the authorization code
/// Apple requires us to revoke when the account is deleted. Google uses the
/// native account picker from google_sign_in.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? google})
    : _auth = auth ?? FirebaseAuth.instance,
      _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  Future<void>? _googleReady;

  /// From the latest Apple sign-in or re-authentication; spent on revocation.
  String? _appleAuthorizationCode;

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  static AppUser? _toAppUser(User? u) {
    if (u == null) return null;
    final providers = u.providerData.map((p) => p.providerId).toSet();
    return AppUser(
      uid: u.uid,
      isAnonymous: u.isAnonymous,
      displayName: u.displayName,
      email: u.email ?? u.providerData.map((p) => p.email).nonNulls.firstOrNull,
      provider: providers.contains('apple.com')
          ? AuthProviderKind.apple
          : providers.contains('google.com')
          ? AuthProviderKind.google
          : null,
    );
  }

  @override
  Future<AppUser> signIn(AuthProviderKind provider) async {
    final current = _auth.currentUser;
    final UserCredential result;
    try {
      result = switch (provider) {
        AuthProviderKind.apple => await _withApple(current),
        AuthProviderKind.google => await _withGoogle(current),
      };
    } on FirebaseAuthException catch (e) {
      if (_isCancel(e.code)) throw const SignInCancelled();
      rethrow;
    }
    _appleAuthorizationCode =
        result.additionalUserInfo?.authorizationCode ?? _appleAuthorizationCode;
    return _toAppUser(result.user)!;
  }

  Future<UserCredential> _withApple(User? current) async {
    final apple = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    if (current != null && current.isAnonymous) {
      try {
        return await current.linkWithProvider(apple);
      } on FirebaseAuthException catch (e) {
        // This Apple ID already has an account: sign into that one. The
        // anonymous user's feedback stays under its old uid.
        if (e.code != 'credential-already-in-use') rethrow;
      }
    }
    return _auth.signInWithProvider(apple);
  }

  Future<UserCredential> _withGoogle(User? current) async {
    final credential = await _googleCredential();
    if (current != null && current.isAnonymous) {
      try {
        return await current.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'credential-already-in-use') rethrow;
        return _auth.signInWithCredential(e.credential ?? credential);
      }
    }
    return _auth.signInWithCredential(credential);
  }

  Future<AuthCredential> _googleCredential() async {
    await (_googleReady ??= _google.initialize());
    final GoogleSignInAccount account;
    try {
      account = await _google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const SignInCancelled();
      }
      rethrow;
    }
    return GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
  }

  static bool _isCancel(String code) =>
      code == 'canceled' ||
      code == 'cancelled' ||
      code == 'web-context-canceled' ||
      code == 'user-cancelled';

  @override
  Future<String> ensureAnonymous() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    try {
      final result = await _auth.signInAnonymously();
      return result.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') throw const AuthOffline();
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleReady != null) {
      try {
        await _google.signOut();
      } catch (e) {
        debugPrint('Google sign-out failed: $e');
      }
    }
  }

  @override
  Future<void> reauthenticate() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      switch (currentUser?.provider) {
        case AuthProviderKind.apple:
          final result = await user.reauthenticateWithProvider(
            AppleAuthProvider(),
          );
          _appleAuthorizationCode =
              result.additionalUserInfo?.authorizationCode;
        case AuthProviderKind.google:
          await user.reauthenticateWithCredential(await _googleCredential());
        case null:
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (_isCancel(e.code)) throw const SignInCancelled();
      rethrow;
    }
  }

  @override
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final code = _appleAuthorizationCode;
    if (currentUser?.provider == AuthProviderKind.apple && code != null) {
      // App Store Review Guideline 5.1.1(v): deleting the account must also
      // revoke the Sign in with Apple token.
      await _auth.revokeTokenWithAuthorizationCode(code);
      _appleAuthorizationCode = null;
    }
    await user.delete();
    if (_googleReady != null) {
      try {
        await _google.disconnect();
      } catch (e) {
        debugPrint('Google disconnect failed: $e');
      }
    }
  }
}
