import 'package:chumley_navigator/screens/job_details/post_submit/status_progress_timeline.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Layout-constraint checks at representative widths.
/// These are NOT a substitute for physical foldable/hinge verification.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {required Size logicalSize}) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: logicalSize),
          child: Scaffold(
            body: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
  }

  Future<void> pumpAtWidth(
    WidgetTester tester, {
    required double width,
    required Widget child,
  }) async {
    final size = Size(width, 852);
    tester.view.physicalSize = Size(width * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(child, logicalSize: size));
    await tester.pumpAndSettle();
  }

  group('representative foldable / large widths', () {
    const widths = <String, double>{
      'compact phone': 360,
      'folded-like': 673,
      'unfolded foldable': 840,
      'tablet': 1024,
    };

    for (final entry in widths.entries) {
      testWidgets(
        'CallStyleActionSlider has no overflow at ${entry.key} (${entry.value.toInt()}dp)',
        (tester) async {
          await pumpAtWidth(
            tester,
            width: entry.value,
            child: CallStyleActionSlider(
              text: 'Continue filling forms',
              backgroundColor: const Color(0xFF3B82F6),
              icon: LucideIcons.clipboardList,
              isEnabled: true,
              onConfirm: () {},
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(CallStyleActionSlider), findsOneWidget);
          expect(find.text('Continue filling forms'), findsOneWidget);
        },
      );

      testWidgets(
        'StatusProgressTimeline LayoutBuilder has no overflow at ${entry.key}',
        (tester) async {
          await pumpAtWidth(
            tester,
            width: entry.value,
            child: const StatusProgressTimeline(completed: false),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(StatusProgressTimeline), findsOneWidget);
        },
      );
    }
  });
}
