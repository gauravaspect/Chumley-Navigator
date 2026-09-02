import 'package:chumley_navigator/models/engineer_appointment_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EngineerAppointmentDetail parses allowed_next_statuses', () {
    final detail = EngineerAppointmentDetail.fromJson({
      'status': 'In Transit',
      'allowed_next_statuses': ['On site', 'Job Closure', 'Visit Complete'],
      'service_appointment': {
        'id': 'sa-001',
        'appointment_number': 'SA-001',
        'status': 'In Transit',
        'title': 'Leak - Customer - London',
      },
    });

    expect(detail.status, 'In Transit');
    expect(detail.allowedNextStatuses, [
      'On site',
      'Job Closure',
      'Visit Complete',
    ]);
    expect(detail.appointment?.id, 'sa-001');
  });

  test('EngineerAppointmentDetail parses idempotent status update', () {
    final detail = EngineerAppointmentDetail.fromJson({
      'status': 'On site',
      'changed': false,
      'allowed_next_statuses': ['Job Closure', 'Visit Complete'],
    });

    expect(detail.changed, isFalse);
    expect(detail.allowedNextStatuses, ['Job Closure', 'Visit Complete']);
  });

  test('EngineerAppointmentDetail parses full /api/engineer/appointments/{id} payload', () {
    final payload = {
      "success": true,
      "appointment": {
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
          "postcode": "RM12 6HR"
        },
        "customer": {
          "name": "Andrew Secular",
          "contact_name": "Andrew Secular"
        },
        "allowed_next_statuses": [
          "In Transit",
          "On site",
          "Job Closure",
          "Visit Complete"
        ],
        "updated_at": "2026-08-30T11:15:49.000+0000"
      }
    };

    final detail = EngineerAppointmentDetail.fromJson(payload);

    expect(detail.status, 'Scheduled');
    expect(detail.allowedNextStatuses, [
      'In Transit',
      'On site',
      'Job Closure',
      'Visit Complete',
    ]);
    expect(detail.appointment, isNotNull);
    final appt = detail.appointment!;
    expect(appt.id, '08pTl000003fXSvIAM');
    expect(appt.appointmentNumber, 'SA-840942');
    expect(appt.status, 'Scheduled');
    expect(appt.workType,
        'Blocked Sink & Sink Waste Only - Blockage - Drainage (Wastewater)');
    expect(appt.siteAddress, '12 Ravenscourt Close');
    expect(appt.sitePostcode, 'RM12 6HR');
    expect(appt.customerName, 'Andrew Secular');
    expect(appt.customerContactName, 'Andrew Secular');
    expect(appt.scheduledStart, DateTime.parse("2026-08-30T16:58:00.000Z"));
    expect(appt.scheduledEnd, DateTime.parse("2026-08-30T17:58:00.000Z"));
    expect(appt.actualStart, isNull);
    expect(appt.actualEnd, isNull);
    expect(appt.updatedAt, DateTime.parse("2026-08-30T11:15:49.000Z"));
  });
}
