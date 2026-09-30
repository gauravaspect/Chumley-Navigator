/// Salesforce Service Appointment status picklist values (engineer transitions).
class SaStatus {
  SaStatus._();

  static const dispatched = 'Dispatched';
  static const received = 'Received';
  static const inTransit = 'In Transit';
  static const onSite = 'On site';
  static const jobClosure = 'Job Closure';
  static const visitComplete = 'Visit Complete';

  /// Typical forward order for engineer API transitions (may allow skipping).
  static const ordered = [inTransit, onSite, jobClosure, visitComplete];

  /// Progress timeline shown on job detail / post-submit screens.
  /// Order: Dispatched → Received → In Transit → On site → Job Closure → Visit Complete
  static const progressLabels = [
    dispatched,
    received,
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
    if (key == 'complete' || key == 'job completed') {
      return ordered.indexOf(visitComplete);
    }
    return -1;
  }

  /// 0 = Dispatched … 5 = Visit Complete.
  /// Scheduled is mapped to Dispatched (not shown as its own step).
  static int progressIndex(String? status) {
    final key = normalizedKey(status);
    switch (key) {
      case 'dispatched':
      case 'scheduled':
      case '':
        return 0;
      case 'received':
        return 1;
      case 'in transit':
      case 'in_transit':
        return 2;
      case 'on site':
      case 'on_site':
      case 'in progress':
        return 3;
      case 'job closure':
        return 4;
      case 'visit complete':
      case 'complete':
      case 'job completed':
        return 5;
      default:
        final idx = ladderIndex(status);
        if (idx >= 0) return idx + 2; // ordered starts at In Transit
        return 0;
    }
  }

  static bool isOnSite(String? status) {
    final key = normalizedKey(status);
    return matches(status, onSite) || key == 'on_site';
  }

  static bool isJobClosure(String? status) => matches(status, jobClosure);

  static bool isOnSiteOrLater(String? status) {
    return progressIndex(status) >= progressIndex(onSite);
  }

  static bool isVisitComplete(String? status) =>
      matches(status, visitComplete) ||
      normalizedKey(status) == 'complete' ||
      normalizedKey(status) == 'job completed';

  static bool isTerminal(
    String? status, {
    List<String> allowedNext = const [],
  }) => isVisitComplete(status) && allowedNext.isEmpty;

  static String actionLabel(String status) {
    switch (normalizedKey(status)) {
      case 'received':
        return 'Slide to Mark Received';
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
    final key = normalizedKey(status);
    if (key.isEmpty || key == 'scheduled') return dispatched;
    final normalized = normalize(status);
    if (normalized.isEmpty) return dispatched;
    return normalized;
  }
}
