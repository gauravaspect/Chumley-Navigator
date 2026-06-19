class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://navigator.chumley.ai',
  );
  static const String tomtomApiKey = String.fromEnvironment(
    'TOMTOM_API_KEY',
    defaultValue: 'yiwXMa528qlf1Z4kZR0ocVkDVYCLb4sw',
  );

  static const String tenantId = String.fromEnvironment(
    'AZURE_TENANT_ID',
    defaultValue: '93ce9c27-3bb2-4ef2-b686-1829de4f2584',
  );
  static const String clientId = String.fromEnvironment(
    'AZURE_CLIENT_ID',
    defaultValue: 'd6576bc2-a5e1-4666-99a2-2a6cdce10a85',
  );
  static const String redirectUri = String.fromEnvironment(
    'AZURE_REDIRECT_URI',
    defaultValue: 'msauth.uk.co.aspect.engineerapp://auth',
  );

  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: true,
  );
}
