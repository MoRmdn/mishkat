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

  static AppUser? _toAppUser(User? u, [AdditionalUserInfo? info]) {
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
      emailVerified: u.emailVerified,
      photoUrl:
          u.photoURL ??
          u.providerData.map((p) => p.photoURL).nonNulls.firstOrNull,
      providers: providers.toList()..sort(),
      createdAt: u.metadata.creationTime,
      lastSignInAt: u.metadata.lastSignInTime,
      providerProfile: info == null ? null : _providerProfile(info),
    );
  }

  /// Google's ID-token claims and Apple's, as Firebase relays them.
  static ProviderProfile _providerProfile(AdditionalUserInfo info) {
    final p = info.profile ?? const <String, dynamic>{};
    String? text(String key) {
      final v = p[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final private = p['is_private_email'];
    return ProviderProfile(
      givenName: text('given_name'),
      familyName: text('family_name'),
      locale: text('locale'),
      hostedDomain: text('hd'),
      isPrivateEmail: switch (private) {
        bool b => b,
        String s => s == 'true',
        _ => null,
      },
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
    return _toAppUser(result.user, result.additionalUserInfo)!;
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
            AppleAuthProvider()..addScope('email'),
          );
          // Apple's code is single-use and short-lived: keep only this one,
          // never an older code from sign-in.
          _appleAuthorizationCode =
              result.additionalUserInfo?.authorizationCode;
        case AuthProviderKind.google:
          await user.reauthenticateWithCredential(await _googleCredential());
        case null:
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (_isCancel(e.code)) throw const SignInCancelled();
      debugPrint('Re-authentication failed: ${e.code} ${e.message}');
      if (e.code == 'network-request-failed') throw const AuthOffline();
      rethrow;
    }
  }

  @override
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (currentUser?.provider == AuthProviderKind.apple) {
      await _revokeApple();
    }
    try {
      await _deleteOrReauthenticate(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Deleting the user failed: ${e.code} ${e.message}');
      if (e.code == 'network-request-failed') throw const AuthOffline();
      rethrow;
    }
    if (_googleReady != null) {
      try {
        await _google.disconnect();
      } catch (e) {
        debugPrint('Google disconnect failed: $e');
      }
    }
  }

  /// App Store Review Guideline 5.1.1(v): deleting the account must also
  /// revoke the Sign in with Apple token. Firebase can only do that when the
  /// Apple provider in the console carries the Services ID, team ID, key ID
  /// and private key; without them (or with a spent code) the call fails.
  /// That must not leave the person with an account they asked to delete, so
  /// the revocation is best-effort and the deletion goes ahead.
  Future<void> _revokeApple() async {
    final code = _appleAuthorizationCode;
    _appleAuthorizationCode = null;
    if (code == null) {
      debugPrint('Apple token not revoked: no authorization code');
      return;
    }
    try {
      await _auth.revokeTokenWithAuthorizationCode(code);
    } on FirebaseAuthException catch (e) {
      debugPrint('Apple token revocation failed: ${e.code} ${e.message}');
    }
  }

  /// Firebase refuses to delete a user whose sign-in is too old even right
  /// after [reauthenticate] on some platforms; confirm once more and retry.
  Future<void> _deleteOrReauthenticate(User user) async {
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') rethrow;
      await reauthenticate();
      await (_auth.currentUser ?? user).delete();
    }
  }
}
