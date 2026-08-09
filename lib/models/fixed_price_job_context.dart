import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:equatable/equatable.dart';

/// Work-order context required to submit a fixed-price agreement.
class FixedPriceJobContext extends Equatable {
  const FixedPriceJobContext({
    required this.sourceWorkOrderId,
    required this.siteId,
    required this.accountId,
    required this.contactId,
    this.workOrderLabel = '',
    this.customerEmail = '',
    this.earliestRequestedDate = '',
    this.resolvedServiceFeePct = 0.0,
    this.resolvedMarkupPct = 0.0,
    this.operativeSharePct = 40.0,
  });

  final String sourceWorkOrderId;
  final String workOrderLabel;
  final String siteId;
  final String accountId;
  final String contactId;
  final String customerEmail;
  final String earliestRequestedDate;
  final double resolvedServiceFeePct;
  final double resolvedMarkupPct;
  final double operativeSharePct;

  factory FixedPriceJobContext.fromAppointment(Appointment appointment) {
    final scheduled = appointment.scheduledStart;
    final dateStr = scheduled != null
        ? '${scheduled.year}-'
            '${scheduled.month.toString().padLeft(2, '0')}-'
            '${scheduled.day.toString().padLeft(2, '0')}'
        : '';

    // Prefer parent Work Order id (0WO...). Fall back to Service Appointment id
    // when the API does not expose the parent work order separately.
    final sourceId = appointment.sourceWorkOrderId.isNotEmpty
        ? appointment.sourceWorkOrderId
        : appointment.id;

    return FixedPriceJobContext(
      sourceWorkOrderId: sourceId,
      workOrderLabel: appointment.appointmentNumber.isNotEmpty
          ? appointment.appointmentNumber
          : sourceId,
      siteId: appointment.siteId,
      accountId: appointment.accountId,
      contactId: appointment.contactId,
      customerEmail: appointment.customerEmail,
      earliestRequestedDate: dateStr,
      resolvedServiceFeePct: appointment.resolvedServiceFeePct,
      resolvedMarkupPct: appointment.resolvedMarkupPct,
      operativeSharePct: appointment.operativeSharePct,
    );
  }

  FixedPriceSalesforceContext toSalesforceContext() {
    return FixedPriceSalesforceContext(
      siteId: siteId,
      accountId: accountId,
      contactId: contactId,
      resolvedServiceFeePct: resolvedServiceFeePct,
      resolvedMarkupPct: resolvedMarkupPct,
      operativeSharePct: operativeSharePct,
    );
  }

  List<String> validate() {
    final errors = <String>[];
    if (sourceWorkOrderId.trim().isEmpty) {
      errors.add('Source work order is required.');
    }
    if (siteId.trim().isEmpty) {
      errors.add('Site is required for this work order.');
    }
    return errors;
  }

  @override
  List<Object?> get props => [
        sourceWorkOrderId,
        workOrderLabel,
        siteId,
        accountId,
        contactId,
        customerEmail,
        earliestRequestedDate,
        resolvedServiceFeePct,
        resolvedMarkupPct,
        operativeSharePct,
      ];
}
