import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';

class VisitJob {
  const VisitJob({
    required this.id,
    required this.saId,
    required this.jobNumber,
    required this.status,
    this.customerName = '',
    this.siteAddress = '',
    this.jobType,
    this.trade,
    this.workType,
    this.description,
    this.scheduledStart,
    this.scheduledEnd,
    this.fpSubmissionId,
    this.pmProjectId,
    this.pmStage,
    this.pmStageOrder,
    this.saCount,
  });

  final String id;
  final String saId;
  final String jobNumber;
  final String status;
  final String customerName;
  final String siteAddress;
  final String? jobType;
  final String? trade;
  final String? workType;
  final String? description;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? fpSubmissionId;
  final String? pmProjectId;
  final String? pmStage;
  final int? pmStageOrder;
  final int? saCount;

  FormKind get kind => FormKindResolver.kindOf(
    jobType: jobType,
    trade: trade,
    workType: workType,
    description: description,
  );

  String get coercedJobType => JobTypeCoerce.coerce(jobType);

  factory VisitJob.fromAppointment(Appointment a) {
    final custName = a.customerName.isNotEmpty
        ? a.customerName
        : (a.customerContactName.isNotEmpty
              ? a.customerContactName
              : a.customerEmail);
    final siteAddr = a.siteAddress.isNotEmpty
        ? (a.sitePostcode.isNotEmpty && !a.siteAddress.contains(a.sitePostcode)
              ? '${a.siteAddress}, ${a.sitePostcode}'
              : a.siteAddress)
        : (a.siteName.isNotEmpty ? a.siteName : a.title);

    return VisitJob(
      id: a.sourceWorkOrderId.isNotEmpty ? a.sourceWorkOrderId : a.id,
      saId: a.id,
      jobNumber: a.appointmentNumber.isNotEmpty ? a.appointmentNumber : a.id,
      status: a.status,
      customerName: custName,
      siteAddress: siteAddr,
      jobType: a.type,
      trade: a.workType.isNotEmpty ? a.workType : a.title,
      workType: a.workType.isNotEmpty ? a.workType : a.type,
      description: a.workType.isNotEmpty ? a.workType : a.title,
      scheduledStart: a.scheduledStart,
      scheduledEnd: a.scheduledEnd,
    );
  }

  factory VisitJob.fromPpmTask(PpmJobTask t) {
    return VisitJob(
      id: t.id,
      saId: t.id,
      jobNumber: t.appointmentNumber.isNotEmpty ? t.appointmentNumber : t.id,
      status: t.status,
      customerName: t.allocatedEngineerName,
      siteAddress: t.postcode,
      jobType: t.jobType,
      trade: t.tradeGroup,
      workType: t.workTypeName,
      description: t.subject,
      scheduledStart: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        t.startHour,
      ),
    );
  }

  VisitJob copyWith({String? status}) {
    return VisitJob(
      id: id,
      saId: saId,
      jobNumber: jobNumber,
      status: status ?? this.status,
      customerName: customerName,
      siteAddress: siteAddress,
      jobType: jobType,
      trade: trade,
      workType: workType,
      description: description,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      fpSubmissionId: fpSubmissionId,
      pmProjectId: pmProjectId,
      pmStage: pmStage,
      pmStageOrder: pmStageOrder,
      saCount: saCount,
    );
  }
}
