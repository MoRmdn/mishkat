import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';

/// What `users/{uid}` holds about the person: what their provider shared at
/// sign-in, and which build of the app they last opened. Written on sign-in
/// and once per launch. Never a location or time zone — CLAUDE.md keeps
/// location off the servers, and the store disclosures say so.
@immutable
class UserProfile {
  const UserProfile({
    this.displayName,
    this.email,
    this.emailVerified = false,
    this.photoUrl,
    this.providers = const [],
    this.createdAt,
    this.lastSignInAt,
    this.provider,
    this.appVersion,
    this.platform,
    this.language,
  });

  factory UserProfile.of(
    AppUser user, {
    String? appVersion,
    String? platform,
    String? language,
  }) => UserProfile(
    displayName: user.displayName,
    email: user.email,
    emailVerified: user.emailVerified,
    photoUrl: user.photoUrl,
    providers: user.providers,
    createdAt: user.createdAt,
    lastSignInAt: user.lastSignInAt,
    provider: user.providerProfile,
    appVersion: appVersion,
    platform: platform,
    language: language,
  );

  final String? displayName;
  final String? email;
  final bool emailVerified;
  final String? photoUrl;
  final List<String> providers;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  /// Only on the profile written at sign-in; a launch leaves what the last
  /// sign-in stored.
  final ProviderProfile? provider;

  final String? appVersion;
  final String? platform;

  /// The app's language, `ar` or `en`.
  final String? language;

  /// The `profile` map: identity fields, nulls left out so a later write
  /// without them (Apple withholds the name after the first sign-in) never
  /// erases what an earlier one stored.
  Map<String, Object> get identity => {
    'displayName': ?displayName,
    'email': ?email,
    'emailVerified': emailVerified,
    'photoUrl': ?photoUrl,
    'givenName': ?provider?.givenName,
    'familyName': ?provider?.familyName,
    'locale': ?provider?.locale,
    'hostedDomain': ?provider?.hostedDomain,
    'isPrivateEmail': ?provider?.isPrivateEmail,
  };

  /// The `app` map.
  Map<String, Object> get app => {
    'version': ?appVersion,
    'platform': ?platform,
    'language': ?language,
  };
}
