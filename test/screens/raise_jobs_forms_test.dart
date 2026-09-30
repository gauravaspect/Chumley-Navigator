import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_cubit.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_state.dart';
import 'package:chumley_navigator/screens/job_details/raise_multiple_fixed_price_page.dart';
import 'package:chumley_navigator/screens/job_details/raise_reactive_job_page.dart';
import 'package:chumley_navigator/screens/job_details/repo/fixed_price_repository.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_submission_dialog.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFixedPriceRepository implements FixedPriceRepository {
  @override
  Future<List<FixedPriceModel>> fetchFixedPriceTrades() async {
    return const [
      FixedPriceModel(id: 'trade_1', name: 'Plumbing'),
      FixedPriceModel(id: 'trade_2', name: 'Gas / Heating'),
    ];
  }

  @override
  Future<List<FixedPriceModel>> readCachedFixedPriceTrades() async {
    return const [
      FixedPriceModel(id: 'trade_1', name: 'Plumbing'),
      FixedPriceModel(id: 'trade_2', name: 'Gas / Heating'),
    ];
  }

  @override
  Future<List<FixedPriceCategoryModel>> fetchFixedPriceCategories(String tradeId) async {
    return const [
      FixedPriceCategoryModel(id: 'cat_1', name: 'Leak Investigation'),
    ];
  }

  @override
  Future<List<FixedPriceWorkTypeModel>> fetchFixedPriceWorkTypes(String groupId) async {
    return const [
      FixedPriceWorkTypeModel(id: 'wt_1', name: 'Trace & Access'),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrapTestWidget(Widget child, {FixedPriceCubit? cubit}) {
  final fakeRepo = FakeFixedPriceRepository();
  final testCubit = cubit ?? FixedPriceCubit(fakeRepo);

  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      home: BlocProvider<FixedPriceCubit>.value(
        value: testCubit,
        child: child,
      ),
    ),
  );
}

void main() {
  group('RaiseReactiveJobPage Tests', () {
    testWidgets('renders step 1 with catalog dropdowns', (tester) async {
      tester.view.physicalSize = const Size(420, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeRepo = FakeFixedPriceRepository();
      final cubit = FixedPriceCubit(fakeRepo);
      await cubit.loadTrades();

      await tester.pumpWidget(
        _wrapTestWidget(
          const RaiseReactiveJobPage(jobId: '0WO12345'),
          cubit: cubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RAISE REACTIVE JOB'), findsOneWidget);
      expect(find.text('Raise a Reactive Job'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Please Select Trade *'), findsOneWidget);
    });

    testWidgets('advances to step 2 and step 3 and submits with confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(420, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeRepo = FakeFixedPriceRepository();
      final cubit = FixedPriceCubit(fakeRepo);
      await cubit.loadTrades();
      await cubit.loadCategories('trade_1');
      await cubit.loadWorkTypes('cat_1');

      await tester.pumpWidget(
        _wrapTestWidget(
          const RaiseReactiveJobPage(jobId: '0WO12345'),
          cubit: cubit,
        ),
      );
      await tester.pumpAndSettle();

      // Open trade dropdown and select
      await tester.tap(find.byType(DropdownButtonFormField2<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plumbing').last);
      await tester.pumpAndSettle();

      // Open category dropdown and select
      await tester.tap(find.byType(DropdownButtonFormField2<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leak Investigation').last);
      await tester.pumpAndSettle();

      // Open work type dropdown and select
      await tester.tap(find.byType(DropdownButtonFormField2<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trace & Access').last);
      await tester.pumpAndSettle();

      // Tap Next to advance to step 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('Job Title *'), findsOneWidget);

      // Enter Title & Description
      await tester.enterText(find.byType(TextField).first, 'Urgent Pipe Burst');
      await tester.enterText(find.byType(TextField).at(1), 'Pipe ruptured under sink. Flooding hallway.');
      await tester.pumpAndSettle();

      // Tap Next to advance to step 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Reactive Attendance Summary'), findsOneWidget);
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('Leak Investigation'), findsOneWidget);
      expect(find.text('Trace & Access'), findsOneWidget);
      expect(find.text('Please confirm customer choice *'), findsOneWidget);

      // Select Customer Choice "Accept"
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Tap Submit Reactive Job
      await tester.tap(find.text('Submit Reactive Job'));
      await tester.pumpAndSettle();

      // Verify Submission Dialog appears
      expect(find.text('Reactive Job Raised'), findsOneWidget);
      expect(find.text('Back to Job'), findsOneWidget);
    });
  });

  group('RaiseMultipleFixedPricePage Tests', () {
    testWidgets('renders step 1 and allows batching multiple jobs with options dialog', (tester) async {
      tester.view.physicalSize = const Size(420, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final fakeRepo = FakeFixedPriceRepository();
      final cubit = FixedPriceCubit(fakeRepo);
      await cubit.loadTrades();
      await cubit.loadCategories('trade_1');
      await cubit.loadWorkTypes('cat_1');

      await tester.pumpWidget(
        _wrapTestWidget(
          const RaiseMultipleFixedPricePage(jobId: '0WO12345'),
          cubit: cubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MULTIPLE FIXED PRICE JOBS'), findsOneWidget);
      expect(find.text('Fixed Price Job #1'), findsOneWidget);
      expect(find.text('Step 1 of 8'), findsOneWidget);

      // Select Trade, Category, Work Type
      await tester.tap(find.byType(DropdownButtonFormField2<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plumbing').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField2<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leak Investigation').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField2<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trace & Access').last);
      await tester.pumpAndSettle();

      // Next to Step 2 (Scope)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 8'), findsOneWidget);

      // Next to Step 3 (Pricing)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 8'), findsOneWidget);

      // Select Collection Fee = No, List Price Service = Standard, ULEZ = No
      await tester.tap(find.text('No').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField2<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Standard Labour Service - £80.00').last);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No').last);
      await tester.pumpAndSettle();

      // Next to Step 5 (Operative)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 5 of 8'), findsOneWidget);

      // Step 5 (Operative)
      // Enter duration and select rate
      await tester.enterText(find.byType(TextField).first, '2');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rate 1 (£80.00/hr)'));
      await tester.pumpAndSettle();

      // Next to Step 7 (Confirmation)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 7 of 8'), findsOneWidget);

      // Select Customer Choice = Send Estimate to Customer
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Estimate to Customer'));
      await tester.pumpAndSettle();

      // Next to Step 8 (Review)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 8 of 8'), findsOneWidget);

      // Tap Finish & Options
      await tester.tap(find.text('Finish & Options'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Job #1 Ready'), findsOneWidget);
      expect(find.text('+ Add Another Job'), findsOneWidget);
      expect(find.text('Submit All (1 Jobs)'), findsOneWidget);

      // Tap + Add Another Job
      await tester.tap(find.text('+ Add Another Job'));
      await tester.pumpAndSettle();

      // Should now be back at Step 1 for Job #2 with the batch strip showing 1 configured job
      expect(find.text('Fixed Price Job #2'), findsOneWidget);
      expect(find.text('Step 1 of 8'), findsOneWidget);
      expect(find.text('Configured Jobs in Batch (1)'), findsOneWidget);
    });
  });

  group('JobSubmissionDialog Tests', () {
    testWidgets('renders properly with details and dismisses', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: JobSubmissionDialog(
                theme: const DashboardTheme(isDark: true),
                title: 'Test Job Raised',
                subtitle: 'Test job subtitle',
                referenceId: 'RJ-9999',
                details: const {
                  'Trade': 'Gas / Heating',
                  'Choice': 'Accept',
                },
                buttonLabel: 'Done',
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Job Raised'), findsOneWidget);
      expect(find.text('RJ-9999'), findsOneWidget);
      expect(find.text('Gas / Heating'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      expect(dismissed, isTrue);
    });
  });
}
