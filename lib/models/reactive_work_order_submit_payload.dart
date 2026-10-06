import 'package:chumley_navigator/models/auth_user.dart';
import 'package:equatable/equatable.dart';

class ReactiveWorkOrderSubmitPayload extends Equatable {
  const ReactiveWorkOrderSubmitPayload({
    required this.sourceWorkOrderId,
    required this.userId,
    required this.workTypeId,
    required this.jobTitle,
    required this.description,
    this.accessNotes = '',
    required this.customerDecision,
    this.workCommencingChoice = 'now',
  });

  final String sourceWorkOrderId;
  final String userId;
  final String workTypeId;
  final String jobTitle;
  final String description;
  final String accessNotes;
  final String customerDecision;
  final String workCommencingChoice;

  Map<String, dynamic> toSubmitJson() => {
    'source_work_order_id': sourceWorkOrderId,
    'user_id': userId,
    'work_type_id': workTypeId,
    'job_title': jobTitle,
    'description': description,
    'access_notes': accessNotes,
    'customer_decision': customerDecision,
    'work_commencing_choice': workCommencingChoice,
  };

  List<String> validate() {
    final errors = <String>[];
    if (sourceWorkOrderId.trim().isEmpty) {
      errors.add('Source work order is required.');
    }
    if (userId.trim().isEmpty) {
      errors.add('User id is required to raise this work order.');
    } else if (!AuthUser.isSalesforceId(userId)) {
      errors.add(
        'A valid Salesforce engineer id is required to raise this work order.',
      );
    }
    if (workTypeId.trim().isEmpty) {
      errors.add('Work type is required.');
    }
    if (jobTitle.trim().isEmpty) {
      errors.add('Job title is required.');
    }
    if (description.trim().isEmpty) {
      errors.add('Description is required.');
    }
    if (customerDecision.trim().isEmpty) {
      errors.add('Customer decision is required.');
    }
    return errors;
  }

  @override
  List<Object?> get props => [
    sourceWorkOrderId,
    userId,
    workTypeId,
    jobTitle,
    description,
    accessNotes,
    customerDecision,
    workCommencingChoice,
  ];
}
