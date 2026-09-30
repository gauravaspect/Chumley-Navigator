import 'dart:developer' as developer;

/// Debug logging — shows as `[Login]` (or custom [name]) in the console.
// ignore: non_constant_identifier_names
void Log(String message, {String name = 'Login'}) {
  developer.log(message, name: name);
}

String maskToken(String? token) {
  if (token == null || token.isEmpty) return '(empty)';
  if (token.length <= 8) return '***';
  final start = token.substring(0, 4);
  final end = token.substring(token.length - 4);
  return '$start...$end (${token.length} chars)';
}
