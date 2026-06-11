import 'package:chumley_navigator/components/dashboard/dashboard_calendar.dart';
import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/providers/theme_notifier.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserModel serializes fields correctly', () {
    final user = UserModel.fromJson(const {
      'id': 'user_id',
      'name': 'John Doe',
      'position': 'Engineer',
      'overall_rating': 4.5,
      'photo_url': 'http://example.com/photo.png',
      'performance_score': 85.0,
    });

    expect(user.id, 'user_id');
    expect(user.name, 'John Doe');
    expect(user.position, 'Engineer');
    expect(user.overallRating, 4.5);
    expect(user.photoUrl, 'http://example.com/photo.png');
    expect(user.performanceScore, 85.0);
  });

  test('EngineerPerformanceHistory serializes fields correctly', () {
    final history = EngineerPerformanceHistory.fromJson(const {
      'engineer_id': 'eng_1',
      'engineer_name': 'Test Engineer',
      'trade_group': 'Heating',
      'months_requested': 12,
      'cumulative_total': 1500,
      'this_month_total': 120,
      'months': [
        {
          'engineer_id': 'eng_1',
          'engineer_name': 'Test Engineer',
          'trade_group': 'Heating',
          'date_range': '2026-05',
          'month_label': 'May 2026',
          'trade_baseline': {
            'avg_job_value': 250.0,
            'avg_converted_estimate_value': 400.0,
          },
          'total_points': 120,
          'categories': {
            'per_job': {
              'total': 50,
              'events': [
                {
                  'label': 'Job Completed',
                  'points': 50,
                  'count': 1,
                  'detail': 'Detail msg',
                  'data_quality': 'high',
                }
              ],
            }
          }
        }
      ]
    });

    expect(history.engineerId, 'eng_1');
    expect(history.engineerName, 'Test Engineer');
    expect(history.tradeGroup, 'Heating');
    expect(history.monthsRequested, 12);
    expect(history.cumulativeTotal, 1500);
    expect(history.thisMonthTotal, 120);
    expect(history.months.length, 1);
    expect(history.months.first.monthLabel, 'May 2026');
    expect(history.months.first.categories.perJob.total, 50);
    expect(history.months.first.categories.perJob.events.first.label, 'Job Completed');

    final json = history.toJson();
    expect(json['engineer_id'], 'eng_1');
    expect(json['cumulative_total'], 1500);
    expect(json['months'].first['month_label'], 'May 2026');
    expect(json['months'].first['categories']['per_job']['total'], 50);
  });

  testWidgets('JobScheduleCard renders appointment details correctly', (WidgetTester tester) async {
    final appointment = Appointment(
      id: 'app_1',
      appointmentNumber: 'SA-123456',
      scheduledStart: DateTime(2026, 6, 10, 14, 30),
      status: 'In Progress',
      title: 'J-111111 - test task',
      type: 'Planned',
    );

    final themeNotifier = ThemeNotifier();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThemeScope(
            notifier: themeNotifier,
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => JobScheduleCard(appointment: appointment),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('SA-123456'), findsOneWidget);
    expect(find.text('JUN'), findsOneWidget);
    expect(find.text('10th'), findsOneWidget);
    expect(find.text('14:30'), findsOneWidget);
    expect(find.text('J-111111 - test task'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
  });
}
