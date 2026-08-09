import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PpmJobTask.fromJson', () {
    test('parses demo PPM task payload', () {
      final task = PpmJobTask.fromJson({
        'Id': 'ppm-SA-20260804-001',
        'AppointmentNumber': 'SA-20260804-001',
        'Subject': 'CP12 Gas Safety — PPM',
        'WorkType_Name': 'CP12 (Gas Safety)',
        'Allocated_Engineer__c': 'demo-eng-navigator',
        'Allocated_Engineer_Name': 'Navigator Test Engineer',
        'engineer_email': 'navigatorengineer@aspect.co.uk',
        'Status': 'On site',
        'Trade_Group__c': 'Gas',
        'Job_Type__c': 'PPM',
        'Postcode__c': 'SW1A 1AA',
        'start_hour': 11,
        'end_hour': 13,
      });

      expect(task.id, 'ppm-SA-20260804-001');
      expect(task.appointmentNumber, 'SA-20260804-001');
      expect(task.subject, 'CP12 Gas Safety — PPM');
      expect(task.workTypeName, 'CP12 (Gas Safety)');
      expect(task.allocatedEngineerId, 'demo-eng-navigator');
      expect(task.allocatedEngineerName, 'Navigator Test Engineer');
      expect(task.engineerEmail, 'navigatorengineer@aspect.co.uk');
      expect(task.status, 'On site');
      expect(task.tradeGroup, 'Gas');
      expect(task.jobType, 'PPM');
      expect(task.postcode, 'SW1A 1AA');
      expect(task.startHour, 11);
      expect(task.endHour, 13);
    });
  });

  group('PpmJobsResponse.fromJson', () {
    test('parses success envelope with tasks list', () {
      final response = PpmJobsResponse.fromJson({
        'success': true,
        'tasks': [
          {
            'Id': 'ppm-SA-20260804-001',
            'AppointmentNumber': 'SA-20260804-001',
            'Subject': 'CP12 Gas Safety — PPM',
            'WorkType_Name': 'CP12 (Gas Safety)',
            'Allocated_Engineer__c': 'demo-eng-navigator',
            'Allocated_Engineer_Name': 'Navigator Test Engineer',
            'engineer_email': 'navigatorengineer@aspect.co.uk',
            'Status': 'On site',
            'Trade_Group__c': 'Gas',
            'Job_Type__c': 'PPM',
            'Postcode__c': 'SW1A 1AA',
            'start_hour': 11,
            'end_hour': 13,
          },
        ],
      });

      expect(response.success, isTrue);
      expect(response.tasks, hasLength(1));
      expect(response.tasks.first.jobType, 'PPM');
      expect(response.tasks.first.startHour, 11);
    });
  });
}
