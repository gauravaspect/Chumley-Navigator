import 'package:chumley_navigator/core/responsive/responsive_breakpoints.dart';
import 'package:chumley_navigator/core/responsive/responsive_content.dart';
import 'package:chumley_navigator/core/responsive/responsive_layout.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/chat_bubble.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget harness({required Size size, required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('ResponsiveLayout', () {
    testWidgets('sizeClass and max widths at representative widths', (
      tester,
    ) async {
      final samples = <double, ResponsiveSizeClass>{
        360: ResponsiveSizeClass.compact,
        673: ResponsiveSizeClass.medium,
        840: ResponsiveSizeClass.expanded,
        1024: ResponsiveSizeClass.expanded,
        1300: ResponsiveSizeClass.large,
      };

      for (final entry in samples.entries) {
        late ResponsiveSizeClass cls;
        late double chatMax;
        late double sheetMax;
        await tester.pumpWidget(
          harness(
            size: Size(entry.key, 852),
            child: Builder(
              builder: (context) {
                cls = ResponsiveLayout.sizeClassOf(context);
                chatMax = ResponsiveLayout.chatBubbleMaxWidth(context);
                sheetMax = ResponsiveLayout.sheetMaxWidth(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(cls, entry.value, reason: 'width ${entry.key}');
        expect(chatMax, lessThanOrEqualTo(ResponsiveBreakpoints.chatBubbleMax));
        if (entry.key >= ResponsiveBreakpoints.compactMax) {
          expect(sheetMax, ResponsiveBreakpoints.sheetMax);
        } else {
          expect(sheetMax, entry.key);
        }
      }
    });

    testWidgets('ResponsiveContent caps child width on large screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        harness(
          size: const Size(1024, 852),
          child: ResponsiveContent.form(
            child: Container(
              key: const Key('inner'),
              width: double.infinity,
              height: 40,
              color: Colors.blue,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final box = tester.renderObject<RenderBox>(
        find.byKey(const Key('inner')),
      );
      expect(
        box.size.width,
        lessThanOrEqualTo(ResponsiveBreakpoints.formContentMax),
      );
    });

    testWidgets('ChatBubble respects chatBubbleMax on tablet width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        harness(
          size: const Size(1024, 852),
          child: Builder(
            builder: (context) {
              final theme = DashboardTheme.of(context);
              return ChatBubble(
                theme: theme,
                text:
                    'Hello from a long message that should not span the tablet',
                isUser: true,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ChatBubble), findsOneWidget);
    });

    test('photoGridColumns scales with width', () {
      expect(ResponsiveLayout.photoGridColumns(300), 2);
      expect(ResponsiveLayout.photoGridColumns(500), inInclusiveRange(2, 4));
      expect(ResponsiveLayout.photoGridColumns(900), 4);
    });

    testWidgets('ScreenUtil does not enlarge .sp on unfolded widths', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(840 * 3, 840 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late double sp16;
      late double w16;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(
            ResponsiveBreakpoints.phoneDesignWidth,
            ResponsiveBreakpoints.phoneDesignHeight,
          ),
          minTextAdapt: true,
          splitScreenMode: true,
          enableScaleWH: ResponsiveLayout.screenUtilShouldScale,
          enableScaleText: ResponsiveLayout.screenUtilShouldScale,
          builder: (_, _) => MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(840, 840)),
              child: Builder(
                builder: (context) {
                  sp16 = 16.sp;
                  w16 = 16.w;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without the scale cap, 16.sp would be ~34 on an 840dp screen.
      expect(sp16, closeTo(16, 0.5));
      expect(w16, closeTo(16, 0.5));
    });
  });
}
