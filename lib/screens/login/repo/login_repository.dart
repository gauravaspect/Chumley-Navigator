import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/core/utils/id_token_helper.dart';
import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/screens/login/service/login_api_service.dart';
import 'package:chumley_navigator/service/auth_service.dart';

/// Login orchestration — see MOBILE_APP_AUTH_GUIDE_V2.md §1, §7.
class LoginRepository {
  LoginRepository({
    required AzureAuthService azureAuthService,
    required LoginApiService loginApiService,
  }) : _azureAuthService = azureAuthService,
       _loginApiService = loginApiService;

  final AzureAuthService _azureAuthService;
  final LoginApiService _loginApiService;

  Future<AuthUser> login() async {
    try {
      await Prefs.clearAuth();

      await _azureAuthService.login(forceFresh: true);
      final microsoftTokens = await _azureAuthService.getTokens();

      if (IdTokenHelper.isExpired(microsoftTokens.idToken)) {
        await _azureAuthService.logout();
        throw const LoginException(
          'Your Microsoft sign-in expired. Please sign in again.',
        );
      }

      final exchange = await _loginApiService.exchangeTokens(microsoftTokens);
      await Prefs.saveSessionToken(exchange.sessionToken);
      await Prefs.saveAuthUser(exchange.user);

      Log('Login successful — stored session and auth user');
      Log('authUser: ${exchange.user.toJson()}');
      Log('sessionToken: ${maskToken(exchange.sessionToken)}');
      Log('expiresAt: ${exchange.expiresAt?.toIso8601String() ?? '(none)'}');
      Log(
        'microsoft: idTokenAud=${IdTokenHelper.readAudience(microsoftTokens.idToken)}, '
        'idToken=${maskToken(microsoftTokens.idToken)}, '
        'accessToken=${maskToken(microsoftTokens.accessToken)}',
      );

      return exchange.user;
    } on LoginApiException catch (e) {
      await Prefs.clearAuth();
      await _azureAuthService.logout();
      throw LoginException(e.message);
    } on LoginException {
      await Prefs.clearAuth();
      rethrow;
    } on AzureAuthException catch (e) {
      await Prefs.clearAuth();
      throw LoginException(e.message);
    } catch (_) {
      await Prefs.clearAuth();
      await _azureAuthService.logout();
      throw const LoginException('Unable to sign in. Please try again.');
    }
  }

  Future<AuthUser?> checkAuth() async {
    final token = await Prefs.getSessionToken();
    final user = await Prefs.getAuthUser();

    if (token == null || token.trim().isEmpty || user == null) {
      return null;
    }

    if (user.role != 'engineer') {
      await logout();
      return null;
    }

    return user;
  }

  Future<void> logout() async {
    await _loginApiService.signOut();
    await Prefs.clearAuth();
    await _azureAuthService.logout();
  }
}

class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
