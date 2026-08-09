import 'package:chumley_navigator/models/fixed_price_job_context.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Appointment.fromJson', () {
    test('reads site, account, and contact ids from service appointment', () {
      final appointment = Appointment.fromJson({
        'id': '08pTl000003UkTVIA0',
        'appointment_number': 'SA-797641',
        'scheduled_start': '2026-06-09T10:00:00Z',
        'status': 'Scheduled',
        'title': 'J-123 - Phil Harris - Brighton',
        'type': 'Brick Laying - PPM',
        'site_id': 'a1q4G000006VbmLQAS',
        'account_id': '0014G00002jTnJuQAK',
        'contact_id': '0034G000002s0ZqvQAE',
        'work_order': {
          'id': '0WO4G0000005SG6WAM',
        },
      });

      expect(appointment.siteId, 'a1q4G000006VbmLQAS');
      expect(appointment.accountId, '0014G00002jTnJuQAK');
      expect(appointment.contactId, '0034G000002s0ZqvQAE');
      expect(appointment.sourceWorkOrderId, '0WO4G0000005SG6WAM');
    });

    test('reads Salesforce-style field names on service appointment', () {
      final appointment = Appointment.fromJson({
        'id': '08pTl000003UkTVIA0',
        'Site__c': 'a1q4G000006VbmLQAS',
        'AccountId': '0014G00002jTnJuQAK',
        'ContactId': '0034G000002s0ZqvQAE',
        'ParentRecordId': '0WO4G0000005SG6WAM',
      });

      expect(appointment.siteId, 'a1q4G000006VbmLQAS');
      expect(appointment.accountId, '0014G00002jTnJuQAK');
      expect(appointment.contactId, '0034G000002s0ZqvQAE');
      expect(appointment.sourceWorkOrderId, '0WO4G0000005SG6WAM');
    });

    test('reads ids from nested service_appointment wrapper', () {
      final appointment = Appointment.fromJson({
        'service_appointment': {
          'id': '08pTl000003UkTVIA0',
          'site_id': 'a1q4G000006VbmLQAS',
          'account_id': '0014G00002jTnJuQAK',
          'contact_id': '0034G000002s0ZqvQAE',
        },
      });

      expect(appointment.id, '08pTl000003UkTVIA0');
      expect(appointment.siteId, 'a1q4G000006VbmLQAS');
      expect(appointment.accountId, '0014G00002jTnJuQAK');
      expect(appointment.contactId, '0034G000002s0ZqvQAE');
    });
  });

  group('FixedPriceJobContext.fromAppointment', () {
    test('maps service appointment ids into submit context', () {
      final appointment = Appointment.fromJson({
        'id': '08pTl000003UkTVIA0',
        'appointment_number': 'SA-797641',
        'scheduled_start': '2026-06-09T10:00:00Z',
        'site_id': 'a1q4G000006VbmLQAS',
        'account_id': '0014G00002jTnJuQAK',
        'contact_id': '0034G000002s0ZqvQAE',
        'work_order': {'id': '0WO4G0000005SG6WAM'},
      });

      final context = FixedPriceJobContext.fromAppointment(appointment);

      expect(context.sourceWorkOrderId, '0WO4G0000005SG6WAM');
      expect(context.siteId, 'a1q4G000006VbmLQAS');
      expect(context.accountId, '0014G00002jTnJuQAK');
      expect(context.contactId, '0034G000002s0ZqvQAE');
      expect(context.toSalesforceContext().siteId, 'a1q4G000006VbmLQAS');
    });
  });
}
