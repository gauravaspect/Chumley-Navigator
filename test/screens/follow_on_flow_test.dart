import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/follow_on_page.dart';
import 'package:chumley_navigator/screens/job/work_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (context, _) => MaterialApp(home: child),
  );
}

void main() {
  final testJob = VisitJob(
    id: 'demo-rx-101',
    saId: 'sa-demo-101',
    jobNumber: 'SA-818687',
    status: 'COMPLETE',
    trade: 'Leak Detection',
    jobType: 'REACTIVE',
    customerName: 'Simone Zacchi',
    siteAddress: '123 Baker Street, London',
    scheduledStart: DateTime(2026, 8, 24, 10),
  );

  group('WorkOrderPage & FollowOnFlow', () {
    testWidgets('WorkOrderPage complete phase shows "Slide to close job"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          WorkOrderPage(
            job: testJob,
            kind: FormKind.leak,
            phase: ResumePhase.complete,
            onOpenFollowOn: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Slide to close job'), findsOneWidget);
      expect(find.text('Job completed - all forms submitted'), findsOneWidget);
    });

    testWidgets(
      'FollowOnPhase.raise renders follow-on options and No enquiry required button',
      (tester) async {
        await tester.pumpWidget(
          _wrap(FollowOnPage(job: testJob, phase: FollowOnPhase.raise)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Follow-on work'), findsOneWidget);
        expect(find.text('Anything else for this site?'), findsOneWidget);
        expect(find.text('Raise a Fixed Price Job'), findsOneWidget);
        expect(find.text('Raise a reactive job'), findsOneWidget);
        expect(find.text('Raise multiple fixed price job'), findsOneWidget);
        expect(find.text('Raise an hourly attendance'), findsOneWidget);
        expect(find.text('Refer and earn'), findsOneWidget);
        expect(find.text('No enquiry required'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping "Raise an hourly attendance" opens the attendance sheet',
      (tester) async {
        tester.view.physicalSize = const Size(393 * 3, 1200 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(FollowOnPage(job: testJob, phase: FollowOnPhase.raise)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Raise an hourly attendance'));
        await tester.pumpAndSettle();

        expect(find.text('Raise Hourly Attendance'), findsOneWidget);
        expect(find.text('Submit Attendance Request'), findsOneWidget);
      },
    );

    testWidgets('Tapping "Refer and earn" opens the referral sheet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(FollowOnPage(job: testJob, phase: FollowOnPhase.raise)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Refer and earn'));
      await tester.pumpAndSettle();

      expect(find.text('Refer and Earn'), findsOneWidget);
      expect(find.text('Trade required'), findsOneWidget);
      expect(find.text('Submit Referral'), findsOneWidget);
    });

    testWidgets(
      'FollowOnPhase.jobClosed renders closed screen and "Slide to visit complete"',
      (tester) async {
        await tester.pumpWidget(
          _wrap(FollowOnPage(job: testJob, phase: FollowOnPhase.jobClosed)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Job closed'), findsNWidgets(2)); // Title & Banner
        expect(find.text('Slide to visit complete'), findsOneWidget);
        expect(find.text('SA-818687'), findsWidgets);
      },
    );

    testWidgets(
      'FollowOnPhase.visitComplete renders Visit complete and Back to home',
      (tester) async {
        await tester.pumpWidget(
          _wrap(FollowOnPage(job: testJob, phase: FollowOnPhase.visitComplete)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Visit complete'), findsOneWidget);
        expect(find.text('Back to home'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('What happens next'),
          100,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('What happens next'), findsOneWidget);
        expect(
          find.text('Your report goes to the office for review'),
          findsOneWidget,
        );
        expect(
          find.text('The customer receives their visit summary'),
          findsOneWidget,
        );
        expect(
          find.text('Points for this visit land in your Points Hub'),
          findsOneWidget,
        );
      },
    );
  });
}
