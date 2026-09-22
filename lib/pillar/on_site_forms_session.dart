/// Decisions for on-site form UX after arrive / cancel / reopen.
class OnSiteFormsSession {
  OnSiteFormsSession._();

  /// Full-screen [OnSiteWizard] when on site and the engineer has not
  /// cancelled/dismissed the session.
  static bool shouldShowWizard({
    required bool isOnSite,
    required bool formsDismissed,
  }) {
    if (!isOnSite) return false;
    if (formsDismissed) return false;
    return true;
  }

  /// Bottom CTA when on site and required forms are not finished.
  static const continueFillingForms = 'Continue filling forms';

  /// Bottom CTA label replacing a disabled Job Closure slide.
  static const continueToForms = 'Continue to forms';

  static String actionLabel({
    required bool isOnSite,
    required bool formsCompleted,
    required String? primaryNextStatus,
    required String Function(String status) statusActionLabel,
  }) {
    if (isOnSite && !formsCompleted) {
      final next = (primaryNextStatus ?? '').trim().toLowerCase();
      if (next == 'job closure') return continueToForms;
      return continueFillingForms;
    }
    if (primaryNextStatus == null || primaryNextStatus.trim().isEmpty) {
      return '';
    }
    return statusActionLabel(primaryNextStatus);
  }

  /// Whether the primary action should resume forms instead of advancing status.
  static bool shouldResumeForms({
    required bool isOnSite,
    required bool formsCompleted,
    required String? primaryNextStatus,
  }) {
    if (!isOnSite || formsCompleted) return false;
    final next = (primaryNextStatus ?? '').trim().toLowerCase();
    return next.isEmpty || next == 'job closure' || next == 'visit complete';
  }
}
