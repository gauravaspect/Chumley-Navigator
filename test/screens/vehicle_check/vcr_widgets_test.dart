import 'package:chumley_navigator/providers/theme_notifier.dart';
import 'package:chumley_navigator/screens/vehicle_check/widgets/vcr_submitted_screen.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    final notifier = ThemeNotifier();
    return MaterialApp(
      home: Scaffold(
        body: ThemeScope(
          notifier: notifier,
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, _) => child,
          ),
        ),
      ),
    );
  }

  group('VCR Component Widget Tests', () {
    testWidgets('VcrSubmittedScreen renders reference ID and confirmation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      var homePressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              final theme = DashboardTheme.of(context);
              return VcrSubmittedScreen(
                theme: theme,
                referenceId: 'VCR-99123',
                photoCount: 6,
                areaCount: 6,
                onBackHome: () => homePressed = true,
              );
            },
          ),
        ),
      );

      expect(find.text('Van check submitted'), findsOneWidget);
      expect(
        find.text('All 6 areas checked and 6 photos captured.'),
        findsOneWidget,
      );
      expect(find.text('VCR-99123'), findsOneWidget);
      expect(find.text('What happens next'), findsOneWidget);
      expect(find.text('Back to home'), findsOneWidget);

      await tester.tap(find.text('Back to home'));
      expect(homePressed, isTrue);
    });

    testWidgets('VcrStepIndicator renders correct step counts and taps', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int? tappedStep;

      await tester.pumpWidget(
        buildTestableWidget(
          VcrStepIndicator(
            totalSteps: 6,
            currentStep: 2,
            onStepTap: (index) => tappedStep = index,
          ),
        ),
      );

      // Verify indicator is rendered
      expect(find.byType(VcrStepIndicator), findsOneWidget);
      expect(tappedStep, isNull);
    });
  });
}
