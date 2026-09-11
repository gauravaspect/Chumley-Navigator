import 'package:chumley_navigator/screens/job_details/post_submit_flow.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithScreenUtil(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(393, 1200),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('PostSubmitFlow UI tests', () {
    testWidgets('renders jobCompleted phase with "Slide to close job"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool closedCalled = false;
      await tester.pumpWidget(
        wrapWithScreenUtil(
          PostSubmitFlow(
            phase: PostSubmitPhase.jobCompleted,
            jobNumber: 'SA-10293',
            customerName: 'Alice Green',
            jobType: 'Leak Detection',
            workTypeLabel: 'Leak Survey',
            description: 'Inspect ground floor ceiling leak.',
            onPhaseChanged: (p) {
              if (p == PostSubmitPhase.followOn) closedCalled = true;
            },
            onBackToHome: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Job Completed'), findsOneWidget);
      expect(find.text('SA-10293'), findsWidgets);
      expect(find.text('Slide to close job'), findsOneWidget);

      final slider = find.byType(CallStyleActionSlider);
      expect(slider, findsOneWidget);
      (tester.widget(slider) as CallStyleActionSlider).onConfirm();
      expect(closedCalled, isTrue);
    });

    testWidgets(
      'renders followOn phase with enquiry options and "No enquiry required"',
      (tester) async {
        tester.view.physicalSize = const Size(393 * 3, 1200 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool noEnquiryCalled = false;
        await tester.pumpWidget(
          wrapWithScreenUtil(
            PostSubmitFlow(
              phase: PostSubmitPhase.followOn,
              jobNumber: 'SA-10293',
              customerName: 'Alice Green',
              jobType: 'Leak Detection',
              workTypeLabel: 'Leak Survey',
              description: 'Inspect ground floor ceiling leak.',
              onPhaseChanged: (p) {
                if (p == PostSubmitPhase.jobClosed) noEnquiryCalled = true;
              },
              onBackToHome: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Anything else for this site?'), findsOneWidget);
        expect(find.text('Create a fixed price quote'), findsOneWidget);
        expect(find.text('Raise an hourly attendance'), findsOneWidget);
        expect(find.text('Refer and earn'), findsOneWidget);
        expect(find.text('No enquiry required'), findsOneWidget);

        await tester.tap(find.text('No enquiry required'));
        expect(noEnquiryCalled, isTrue);
      },
    );

    testWidgets('renders jobClosed phase with "Slide to visit complete"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool visitCompleteCalled = false;
      await tester.pumpWidget(
        wrapWithScreenUtil(
          PostSubmitFlow(
            phase: PostSubmitPhase.jobClosed,
            jobNumber: 'SA-10293',
            customerName: 'Alice Green',
            jobType: 'Leak Detection',
            workTypeLabel: 'Leak Survey',
            description: 'Inspect ground floor ceiling leak.',
            onPhaseChanged: (p) {
              if (p == PostSubmitPhase.visitComplete)
                visitCompleteCalled = true;
            },
            onBackToHome: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Job closed'), findsWidgets);
      expect(find.text('Slide to visit complete'), findsOneWidget);

      final slider = find.byType(CallStyleActionSlider);
      expect(slider, findsOneWidget);
      (tester.widget(slider) as CallStyleActionSlider).onConfirm();
      expect(visitCompleteCalled, isTrue);
    });

    testWidgets('renders visitComplete phase with "Back to home"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool homeCalled = false;
      await tester.pumpWidget(
        wrapWithScreenUtil(
          PostSubmitFlow(
            phase: PostSubmitPhase.visitComplete,
            jobNumber: 'SA-10293',
            customerName: 'Alice Green',
            jobType: 'Leak Detection',
            workTypeLabel: 'Leak Survey',
            description: 'Inspect ground floor ceiling leak.',
            onPhaseChanged: (_) {},
            onBackToHome: () => homeCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Visit complete'), findsOneWidget);
      expect(find.text('What happens next'), findsOneWidget);
      expect(find.text('Back to home'), findsOneWidget);

      await tester.tap(find.text('Back to home'));
      expect(homeCalled, isTrue);
    });
  });
}
