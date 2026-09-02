import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/work_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => child,
    ),
  );
}

void main() {
  final job = VisitJob(
    id: 'demo-job-rx-001',
    saId: 'sa-demo-001',
    jobNumber: 'SA-818687',
    status: 'DISPATCHED',
    trade: 'Leak Detection',
    jobType: 'REACTIVE',
    scheduledStart: DateTime(2026, 8, 24, 10),
  );

  testWidgets('dispatched phase shows Slide to start journey', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WorkOrderPage(
          job: job,
          kind: FormKind.leak,
          phase: ResumePhase.dispatched,
          onStartJourney: () {},
        ),
      ),
    );
    expect(find.text('Slide to start journey'), findsOneWidget);
  });

  testWidgets('transit phase shows Slide to arrive on site', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WorkOrderPage(
          job: job,
          kind: FormKind.leak,
          phase: ResumePhase.transit,
          onArriveOnSite: () {},
        ),
      ),
    );
    expect(find.text('Slide to arrive on site'), findsOneWidget);
  });

  testWidgets('complete phase shows Job completed banner', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WorkOrderPage(
          job: job.copyWith(status: 'COMPLETE'),
          kind: FormKind.leak,
          phase: ResumePhase.complete,
        ),
      ),
    );
    expect(find.text('Job completed - all forms submitted'), findsOneWidget);
  });
}
