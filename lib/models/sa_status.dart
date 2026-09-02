/// Salesforce Service Appointment status picklist values (engineer transitions).
class SaStatus {
  SaStatus._();

  static const inTransit = 'In Transit';
  static const onSite = 'On site';
  static const jobClosure = 'Job Closure';
  static const visitComplete = 'Visit Complete';

  /// Typical forward order (API may allow skipping ahead).
  static const ordered = [inTransit, onSite, jobClosure, visitComplete];

  /// Progress UI includes a pre-transit "Dispatched" step.
  static const progressLabels = [
    'Dispatched',
    inTransit,
    onSite,
    jobClosure,
    visitComplete,
  ];

  static String normalize(String? raw) => (raw ?? '').trim();

  static String normalizedKey(String? raw) =>
      normalize(raw).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static bool matches(String? a, String? b) =>
      normalizedKey(a) == normalizedKey(b);

  /// Returns the API picklist string if [target] is in [allowed].
  static String? pickAllowed(List<String> allowed, String target) {
    for (final s in allowed) {
      if (matches(s, target)) return s;
    }
    return null;
  }

  static int ladderIndex(String? status) {
    final key = normalizedKey(status);
    for (var i = 0; i < ordered.length; i++) {
      if (normalizedKey(ordered[i]) == key) return i;
    }
    if (key == 'dispatched' || key == 'scheduled') return -1;
    if (key == 'complete' || key == 'job completed') {
      return ordered.indexOf(visitComplete);
    }
    return -1;
  }

  /// 0 = Dispatched … 4 = Visit Complete
  static int progressIndex(String? status) {
    final idx = ladderIndex(status);
    if (idx >= 0) return idx + 1;
    if (normalizedKey(status) == 'dispatched' ||
        normalizedKey(status) == 'scheduled') {
      return 0;
    }
    return 0;
  }

  static bool isOnSite(String? status) {
    final key = normalizedKey(status);
    return matches(status, onSite) || key == 'on_site';
  }

  static bool isJobClosure(String? status) => matches(status, jobClosure);

  static bool isOnSiteOrLater(String? status) {
    final idx = ladderIndex(status);
    return idx >= ordered.indexOf(onSite);
  }

  static bool isVisitComplete(String? status) =>
      matches(status, visitComplete) ||
      normalizedKey(status) == 'complete' ||
      normalizedKey(status) == 'job completed';

  static bool isTerminal(String? status, {List<String> allowedNext = const []}) =>
      isVisitComplete(status) && allowedNext.isEmpty;

  static String actionLabel(String status) {
    switch (normalizedKey(status)) {
      case 'in transit':
        return 'Slide to Start Transit';
      case 'on site':
        return 'Slide to Arrive On Site';
      case 'job closure':
        return 'Slide to Job Closure';
      case 'visit complete':
        return 'Slide to Complete Visit';
      default:
        return 'Slide to $status';
    }
  }

  static String displayLabel(String? status) {
    final normalized = normalize(status);
    if (normalized.isEmpty) return 'Dispatched';
    return normalized;
  }
}
