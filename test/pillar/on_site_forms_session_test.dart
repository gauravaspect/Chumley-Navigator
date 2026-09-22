import 'package:chumley_navigator/pillar/on_site_forms_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldShowWizard', () {
    test('hides wizard when engineer cancelled / dismissed forms', () {
      expect(
        OnSiteFormsSession.shouldShowWizard(
          isOnSite: true,
          formsDismissed: true,
        ),
        isFalse,
      );
    });

    test('shows 12-step OnSiteWizard on site when not dismissed', () {
      expect(
        OnSiteFormsSession.shouldShowWizard(
          isOnSite: true,
          formsDismissed: false,
        ),
        isTrue,
      );
    });

    test('never shows wizard when not on site', () {
      expect(
        OnSiteFormsSession.shouldShowWizard(
          isOnSite: false,
          formsDismissed: false,
        ),
        isFalse,
      );
    });
  });

  group('actionLabel / shouldResumeForms', () {
    test('Job Closure becomes Continue to forms when forms incomplete', () {
      expect(
        OnSiteFormsSession.actionLabel(
          isOnSite: true,
          formsCompleted: false,
          primaryNextStatus: 'Job Closure',
          statusActionLabel: (_) => 'Slide to Job Closure',
        ),
        OnSiteFormsSession.continueToForms,
      );
      expect(
        OnSiteFormsSession.shouldResumeForms(
          isOnSite: true,
          formsCompleted: false,
          primaryNextStatus: 'Job Closure',
        ),
        isTrue,
      );
    });

    test('reopen after cancel uses Continue filling forms', () {
      expect(
        OnSiteFormsSession.actionLabel(
          isOnSite: true,
          formsCompleted: false,
          primaryNextStatus: null,
          statusActionLabel: (_) => 'unused',
        ),
        OnSiteFormsSession.continueFillingForms,
      );
    });

    test('completed forms keep normal Job Closure label', () {
      expect(
        OnSiteFormsSession.actionLabel(
          isOnSite: true,
          formsCompleted: true,
          primaryNextStatus: 'Job Closure',
          statusActionLabel: (_) => 'Slide to Job Closure',
        ),
        'Slide to Job Closure',
      );
      expect(
        OnSiteFormsSession.shouldResumeForms(
          isOnSite: true,
          formsCompleted: true,
          primaryNextStatus: 'Job Closure',
        ),
        isFalse,
      );
    });
  });
}
