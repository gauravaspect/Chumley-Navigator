import 'package:chumley_navigator/screens/job/visit_form_widgets.dart';
import 'package:chumley_navigator/screens/job/visit_wizard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    );
  }

  group('VisitWizardScaffold navigation & buttons', () {
    testWidgets('Step 0 shows "Cancel" label in secondary action', (tester) async {
      var cancelCalled = false;
      await tester.pumpWidget(
        buildApp(
          VisitWizardScaffold(
            stepIndex: 0,
            stepCount: 5,
            title: 'Risk assessment',
            subtitle: 'Access, on-site risk assessment and pre-work checks.',
            jobNumber: 'SA-903846',
            onSaveDraft: () {},
            onNext: () {},
            onCancel: () => cancelCalled = true,
            child: const Text('Step 0 Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(find.text('Risk assessment'), findsOneWidget);
      expect(find.text('SA-903846'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cancelCalled, isTrue);
    });

    testWidgets('Step 1..last shows "Back" label in secondary action', (tester) async {
      var backCalled = false;
      await tester.pumpWidget(
        buildApp(
          VisitWizardScaffold(
            stepIndex: 1,
            stepCount: 5,
            title: 'Before & after',
            jobNumber: 'SA-903846',
            onSaveDraft: () {},
            onNext: () {},
            onCancel: () => backCalled = true,
            child: const Text('Step 1 Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(find.text('Before & after'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(backCalled, isTrue);
    });

    testWidgets('Last step shows "Submit report" for next label', (tester) async {
      await tester.pumpWidget(
        buildApp(
          VisitWizardScaffold(
            stepIndex: 4,
            stepCount: 5,
            title: 'Review',
            isLast: true,
            onSaveDraft: () {},
            onNext: () {},
            child: const Text('Review Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Submit report'), findsOneWidget);
      expect(find.text('Step 5 of 5'), findsOneWidget);
    });

    testWidgets('Tapping step pill navigates to selected tab', (tester) async {
      int? tappedStep;
      await tester.pumpWidget(
        buildApp(
          VisitWizardScaffold(
            stepIndex: 0,
            stepCount: 5,
            title: 'Risk assessment',
            onSaveDraft: () {},
            onNext: () {},
            onStepTapped: (step) => tappedStep = step,
            child: const Text('Step 0 Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pills = find.descendant(
        of: find.byType(VisitStepPills),
        matching: find.byType(GestureDetector),
      );
      expect(pills, findsNWidgets(5));

      await tester.tap(pills.at(2));
      await tester.pumpAndSettle();

      expect(tappedStep, 2);
    });
  });
}
