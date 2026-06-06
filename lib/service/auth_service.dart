import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';

import '../core/app_constants.dart';

/// Microsoft OAuth tokens from aad_oauth — see MOBILE_APP_AUTH_GUIDE_V2.md §7.
class MicrosoftAuthTokens {
  const MicrosoftAuthTokens({
    required this.idToken,
    required this.accessToken,
  });

  final String idToken;
  final String accessToken;
}

class AzureAuthService {
  AzureAuthService({required GlobalKey<NavigatorState> navigatorKey}) {
    final config = Config(
      tenant: AppConstants.tenantId,
      clientId: AppConstants.clientId,
      scope: 'openid profile email User.Read',
      redirectUri: AppConstants.redirectUri,
      navigatorKey: navigatorKey,
    );

    oauth = AadOAuth(config);
  }

  late final AadOAuth oauth;

  Future<void> login({bool forceFresh = false}) async {
    if (forceFresh) {
      await logout();
    }
    final result = await oauth.login();
    result.fold(
      (failure) => throw AzureAuthException(failure.toString()),
      (_) {},
    );
  }

  Future<MicrosoftAuthTokens> getTokens() async {
    final idToken = await oauth.getIdToken();
    final accessToken = await oauth.getAccessToken();

    if (idToken == null || idToken.trim().isEmpty) {
      throw const AzureAuthException(
        'Microsoft sign-in did not return an id token.',
      );
    }
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const AzureAuthException(
        'Microsoft sign-in did not return an access token.',
      );
    }

    return MicrosoftAuthTokens(
      idToken: idToken.trim(),
      accessToken: accessToken.trim(),
    );
  }

  Future<void> logout() async {
    await oauth.logout();
  }
}

class AzureAuthException implements Exception {
  const AzureAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
