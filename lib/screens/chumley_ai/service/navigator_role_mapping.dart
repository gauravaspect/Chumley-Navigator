/// Dashboard / app role → Navigator Copilot API role.
class NavigatorRoleMapping {
  NavigatorRoleMapping._();

  static const allowedAppRoles = {
    'admin',
    'senior_stakeholder',
    'operations_manager',
    'ooh_manager',
    'rise',
    'tgm',
    'trade_manager',
    'engineer',
  };

  static const _map = {
    'admin': 'senior_leadership',
    'rise': 'senior_leadership',
    'tgm': 'trade_manager',
    'trade_manager': 'account_manager',
  };

  static const scopedRoles = {'tgm', 'trade_manager'};

  /// Returns mapped Navigator role, or null if app role is not allowed.
  static String? mapRole(String? appRole) {
    final raw = (appRole ?? '').trim().toLowerCase();
    if (raw.isEmpty || !allowedAppRoles.contains(raw)) return null;
    return _map[raw] ?? raw;
  }

  static String? validateForQuery({
    required String? appRole,
    required String? engineerId,
    required List<String> tradeGroups,
  }) {
    final raw = (appRole ?? '').trim().toLowerCase();
    if (!allowedAppRoles.contains(raw)) {
      return 'Your role ($appRole) is not supported by the chatbot.';
    }
    if (scopedRoles.contains(raw) && tradeGroups.isEmpty) {
      return 'You must have at least one trade group assigned to use the chatbot.';
    }
    final mapped = mapRole(raw);
    if (mapped == 'engineer' &&
        (engineerId == null || engineerId.trim().isEmpty)) {
      return 'Your engineer profile is missing required info (engineer ID).';
    }
    return null;
  }
}
