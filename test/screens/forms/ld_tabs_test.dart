import 'package:chumley_navigator/providers/theme_notifier.dart';
import 'package:chumley_navigator/screens/forms/ld/steps/ld_customer_tab.dart';
import 'package:chumley_navigator/screens/forms/ld/steps/ld_information_tab.dart';
import 'package:chumley_navigator/screens/forms/ld/steps/ld_visual_tab.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
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

  group('LD Form Step Widgets Tests', () {
    testWidgets('LdInformationTab renders form fields and work order display', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final nameCtrl = TextEditingController(text: 'Lightning Test Form');
      final pdfCtrl = TextEditingController(text: 'https://aspect.co.uk/doc');
      final searchCtrl = TextEditingController();
      String? selectedAppointment;

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              final theme = DashboardTheme.of(context);
              return LdInformationTab(
                theme: theme,
                formNameController: nameCtrl,
                pdfUrlController: pdfCtrl,
                appointmentSearchController: searchCtrl,
                workOrderDisplay: 'WO-998877',
                selectedAppointment: selectedAppointment,
                serviceAppointments: const ['SA-10021 · 12 High Street'],
                onAppointmentChanged: (v) => selectedAppointment = v,
              );
            },
          ),
        ),
      );

      expect(find.text('LD Form Name'), findsOneWidget);
      expect(find.text('Work Order'), findsOneWidget);
      expect(find.text('WO-998877'), findsOneWidget);
      expect(find.text('LD Form PDF Url'), findsOneWidget);
      expect(find.text('Service Appointment'), findsOneWidget);
    });

    testWidgets(
      'LdCustomerTab renders date picker buttons and operative search',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final frontCtrl = TextEditingController();
        final opSearchCtrl = TextEditingController();
        var datePicked = false;

        await tester.pumpWidget(
          buildTestableWidget(
            Builder(
              builder: (context) {
                final theme = DashboardTheme.of(context);
                return LdCustomerTab(
                  theme: theme,
                  frontOfPropertyController: frontCtrl,
                  operativeSearchController: opSearchCtrl,
                  selectedOperative: 'Alex Morgan',
                  people: const ['Alex Morgan', 'Sam Patel'],
                  surveyDateTime: DateTime(2026, 9, 25, 14, 30),
                  dateTimeError: null,
                  onOperativeChanged: (_) {},
                  onPickSurveyDate: () => datePicked = true,
                  onPickSurveyTime: () {},
                  formatDate: (dt) => 'Fri, 25 Sep 2026',
                  formatTime: (dt) => '14:30',
                );
              },
            ),
          ),
        );

        expect(find.text('Operative Name'), findsOneWidget);
        expect(
          find.text('Description for image — Front of Property'),
          findsOneWidget,
        );
        expect(find.text('Fri, 25 Sep 2026'), findsOneWidget);
        expect(find.text('14:30'), findsOneWidget);

        await tester.tap(find.text('Fri, 25 Sep 2026'));
        expect(datePicked, isTrue);
      },
    );

    testWidgets('LdVisualTab renders weather dropdown and findings fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final descCtrl = TextEditingController();
      final findingsCtrl = TextEditingController();
      final weatherOtherCtrl = TextEditingController();
      String? weather;

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              final theme = DashboardTheme.of(context);
              return LdVisualTab(
                theme: theme,
                visualImageDescController: descCtrl,
                visualFindingsController: findingsCtrl,
                weatherOtherController: weatherOtherCtrl,
                selectedWeather: weather,
                weatherOptions: const ['Sunny', 'Cloudy', 'Rainy'],
                onWeatherChanged: (v) => weather = v,
              );
            },
          ),
        ),
      );

      expect(
        find.text('Description for visual inspection image'),
        findsOneWidget,
      );
      expect(find.text('Findings from visual inspection'), findsOneWidget);
      expect(find.text('How is the weather during survey'), findsOneWidget);
      expect(find.text('Weather other details'), findsOneWidget);
    });
  });
}
