import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How a signed-in account was created.
enum AuthProviderKind { apple, google }

/// The signed-in Firebase user, reduced to what the app shows or needs.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.provider,
    this.emailVerified = false,
    this.photoUrl,
    this.providers = const [],
    this.createdAt,
    this.lastSignInAt,
    this.providerProfile,
  });

  final String uid;

  /// Created silently when someone first sends feedback while signed out, so
  /// the team's reply has somewhere to go. Never shown as "signed in".
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final AuthProviderKind? provider;
  final bool emailVerified;

  /// Google's profile picture. Apple has none.
  final String? photoUrl;

  /// Firebase provider ids linked to the user: `apple.com`, `google.com`.
  final List<String> providers;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  /// What the provider said about the person at this sign-in. Only present on
  /// the user returned by [AuthService.signIn]; never on [AuthService.currentUser].
  final ProviderProfile? providerProfile;
}

/// The extra claims a provider hands over at sign-in, beyond what Firebase
/// keeps on the user. Apple's name arrives only on the first authorization
/// (Firebase then stores it as the display name); Google's on every one.
@immutable
class ProviderProfile {
  const ProviderProfile({
    this.givenName,
    this.familyName,
    this.locale,
    this.hostedDomain,
    this.isPrivateEmail,
  });

  final String? givenName;
  final String? familyName;

  /// Google's account language, `ar` or `en-GB`.
  final String? locale;

  /// A Google Workspace domain, for a work or school account.
  final String? hostedDomain;

  /// Apple: the email is a relay address.
  final bool? isPrivateEmail;
}

/// Where the account stands, as the UI sees it.
sealed class Account {
  const Account();

  /// The uid to read and write under, or null when signed out.
  String? get uid => null;

  /// True only for a real Apple or Google account — the only kind that syncs.
  bool get canSync => false;
}

class SignedOut extends Account {
  const SignedOut();
}

/// An anonymous user that exists only to receive feedback replies.
class AnonymousAccount extends Account {
  const AnonymousAccount(this.uid);

  @override
  final String uid;
}

class SignedIn extends Account {
  const SignedIn(this.user);

  final AppUser user;

  @override
  String get uid => user.uid;

  @override
  bool get canSync => true;

  /// The name, or the email when the provider withheld the name (Apple does
  /// after the first sign-in). Empty when all there is is an Apple relay
  /// address, which reads as noise: the screens then say «حساب Apple».
  String get label {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email;
    if (email == null || isAppleRelayEmail(email)) return '';
    return email;
  }
}

/// «…@privaterelay.appleid.com»: the forwarding address Apple hands out when
/// someone hides their email.
bool isAppleRelayEmail(String email) =>
    email.toLowerCase().endsWith('@privaterelay.appleid.com');

/// What the Account screen and the Settings card call a signed-in account.
String accountTitle(SignedIn account, {required String appleAccount}) {
  final label = account.label;
  if (label.isNotEmpty) return label;
  return account.user.provider == AuthProviderKind.apple
      ? appleAccount
      : account.user.email ?? '';
}

Account accountOf(AppUser? user) => switch (user) {
  null => const SignedOut(),
  AppUser(isAnonymous: true) => AnonymousAccount(user.uid),
  _ => SignedIn(user),
};

/// The user closed the provider's sheet. Not an error worth showing.
class SignInCancelled implements Exception {
  const SignInCancelled();
}

/// Auth needed the network and had none.
class AuthOffline implements Exception {
  const AuthOffline();
}

/// Signing in, the anonymous feedback identity, and account deletion.
///
/// Sign-in is always optional: nothing in the app waits on this, and the
/// default implementation used when Firebase could not start simply reports
/// no user.
abstract class AuthService {
  Stream<AppUser?> userChanges();

  AppUser? get currentUser;

  /// Signs in, keeping the uid of an anonymous feedback user when there is
  /// one so their conversations stay theirs.
  Future<AppUser> signIn(AuthProviderKind provider);

  /// Returns the current uid, creating an anonymous user if there is none.
  /// Needs the network the first time.
  Future<String> ensureAnonymous();

  Future<void> signOut();

  /// Asks the provider to confirm it is really this person. Apple and
  /// Firebase both require a recent sign-in before deleting an account.
  Future<void> reauthenticate();

  /// Deletes the Firebase user (and revokes Apple's token). Call
  /// [reauthenticate] first and remove the user's data in between.
  Future<void> deleteUser();
}

/// Used when Firebase did not start (no config, or no Google Play services):
/// the app runs exactly as it did before accounts existed.
class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  Stream<AppUser?> userChanges() => Stream.value(null);

  @override
  AppUser? get currentUser => null;

  @override
  Future<AppUser> signIn(AuthProviderKind provider) =>
      Future.error(StateError('Accounts are unavailable'));

  @override
  Future<String> ensureAnonymous() => Future.error(const AuthOffline());

  @override
  Future<void> signOut() async {}

  @override
  Future<void> reauthenticate() async {}

  @override
  Future<void> deleteUser() async {}
}

/// Whether Firebase started. Overridden in `main()`; false keeps every
/// account and feedback surface hidden.
final cloudAvailableProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>(
  (ref) => const UnavailableAuthService(),
);

final authUserProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authServiceProvider).userChanges(),
);

final accountProvider = Provider<Account>((ref) {
  final auth = ref.watch(authServiceProvider);
  final user = ref.watch(authUserProvider).value ?? auth.currentUser;
  return accountOf(user);
});
