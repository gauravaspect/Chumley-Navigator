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
        'work_order': {'id': '0WO4G0000005SG6WAM'},
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

    test(
      'reads appointment schema from navigator /api/engineer/appointments/{id}',
      () {
        final json = {
          "id": "08pTl000003fXSvIAM",
          "appointment_number": "SA-840942",
          "status": "Scheduled",
          "scheduled_start": "2026-08-30T16:58:00.000+0000",
          "scheduled_end": "2026-08-30T17:58:00.000+0000",
          "actual_start": null,
          "actual_end": null,
          "title": "J-434471 - Andrew Secular - Ravenscourt Close  - RM12 6HR",
          "work_type":
              "Blocked Sink & Sink Waste Only - Blockage - Drainage (Wastewater)",
          "site": {
            "name": "Andrew Secular - Ravenscourt Close  - RM12 6HR",
            "address": "12 Ravenscourt Close",
            "postcode": "RM12 6HR",
          },
          "customer": {
            "name": "Andrew Secular",
            "contact_name": "Andrew Secular",
          },
          "allowed_next_statuses": [
            "In Transit",
            "On site",
            "Job Closure",
            "Visit Complete",
          ],
          "updated_at": "2026-08-30T11:15:49.000+0000",
        };

        final appointment = Appointment.fromJson(json);

        expect(appointment.id, "08pTl000003fXSvIAM");
        expect(appointment.appointmentNumber, "SA-840942");
        expect(appointment.status, "Scheduled");
        expect(
          appointment.workType,
          "Blocked Sink & Sink Waste Only - Blockage - Drainage (Wastewater)",
        );
        expect(
          appointment.siteName,
          "Andrew Secular - Ravenscourt Close  - RM12 6HR",
        );
        expect(appointment.siteAddress, "12 Ravenscourt Close");
        expect(appointment.sitePostcode, "RM12 6HR");
        expect(appointment.customerName, "Andrew Secular");
        expect(appointment.customerContactName, "Andrew Secular");
        expect(appointment.allowedNextStatuses, [
          "In Transit",
          "On site",
          "Job Closure",
          "Visit Complete",
        ]);
        expect(
          appointment.scheduledStart,
          DateTime.parse("2026-08-30T16:58:00.000Z"),
        );
        expect(
          appointment.scheduledEnd,
          DateTime.parse("2026-08-30T17:58:00.000Z"),
        );
        expect(
          appointment.updatedAt,
          DateTime.parse("2026-08-30T11:15:49.000Z"),
        );
      },
    );
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

    test('preserves site and WO ids when detail payload omits them', () {
      final fromSchedule = Appointment.fromJson({
        'id': '08pTl000003UkTVIA0',
        'appointment_number': 'SA-797641',
        'site_id': 'a1q4G000006VbmLQAS',
        'account_id': '0014G00002jTnJuQAK',
        'contact_id': '0034G000002s0ZqvQAE',
        'work_order': {'id': '0WO4G0000005SG6WAM'},
      });
      final fromDetail = Appointment.fromJson({
        'id': '08pTl000003UkTVIA0',
        'appointment_number': 'SA-797641',
        'status': 'On site',
        'site': {
          'name': 'Brighton Site',
          'address': '1 High St',
          'postcode': 'BN1 1AA',
        },
      });

      final merged = fromSchedule.mergePreservingWorkOrderContext(fromDetail);
      final context = FixedPriceJobContext.fromAppointment(merged);

      expect(merged.siteId, 'a1q4G000006VbmLQAS');
      expect(merged.sourceWorkOrderId, '0WO4G0000005SG6WAM');
      expect(merged.accountId, '0014G00002jTnJuQAK');
      expect(merged.siteName, 'Brighton Site');
      expect(context.siteId, 'a1q4G000006VbmLQAS');
      expect(context.sourceWorkOrderId, '0WO4G0000005SG6WAM');
    });
  });
}
