import 'package:chumley_navigator/models/user_model.dart';

String userFirstName(UserModel user) {
  final parts = user.name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  return parts.first;
}

String userInitials(UserModel user) {
  final parts = user.name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String userInitialsFromName(String name) {
  return userInitials(UserModel(name: name));
}

String userFirstNameFromName(String name) {
  return userFirstName(UserModel(name: name));
}
