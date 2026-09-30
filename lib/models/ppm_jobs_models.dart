import 'package:equatable/equatable.dart';

class PpmJobsResponse extends Equatable {
  const PpmJobsResponse({this.success = false, this.tasks = const []});

  final bool success;
  final List<PpmJobTask> tasks;

  factory PpmJobsResponse.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'];
    final tasks = rawTasks is List
        ? rawTasks
              .whereType<Map>()
              .map(
                (item) => PpmJobTask.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const <PpmJobTask>[];

    return PpmJobsResponse(success: json['success'] == true, tasks: tasks);
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'tasks': tasks.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [success, tasks];
}

class PpmJobTask extends Equatable {
  const PpmJobTask({
    this.engineerEmail = '',
    this.allocatedEngineerId = '',
    this.id = '',
    this.status = '',
    this.subject = '',
    this.tradeGroup = '',
    this.workTypeName = '',
    this.postcode = '',
    this.endHour = 0,
    this.allocatedEngineerName = '',
    this.startHour = 0,
    this.jobType = '',
    this.appointmentNumber = '',
  });

  final String engineerEmail;
  final String allocatedEngineerId;
  final String id;
  final String status;
  final String subject;
  final String tradeGroup;
  final String workTypeName;
  final String postcode;
  final int endHour;
  final String allocatedEngineerName;
  final int startHour;
  final String jobType;
  final String appointmentNumber;

  factory PpmJobTask.fromJson(Map<String, dynamic> json) {
    return PpmJobTask(
      engineerEmail: (json['engineer_email'] ?? '').toString(),
      allocatedEngineerId: (json['Allocated_Engineer__c'] ?? '').toString(),
      id: (json['Id'] ?? '').toString(),
      status: (json['Status'] ?? '').toString(),
      subject: (json['Subject'] ?? '').toString(),
      tradeGroup: (json['Trade_Group__c'] ?? '').toString(),
      workTypeName: (json['WorkType_Name'] ?? '').toString(),
      postcode: (json['Postcode__c'] ?? '').toString(),
      endHour: _readInt(json['end_hour']),
      allocatedEngineerName: (json['Allocated_Engineer_Name'] ?? '').toString(),
      startHour: _readInt(json['start_hour']),
      jobType: (json['Job_Type__c'] ?? '').toString(),
      appointmentNumber: (json['AppointmentNumber'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'engineer_email': engineerEmail,
    'Allocated_Engineer__c': allocatedEngineerId,
    'Id': id,
    'Status': status,
    'Subject': subject,
    'Trade_Group__c': tradeGroup,
    'WorkType_Name': workTypeName,
    'Postcode__c': postcode,
    'end_hour': endHour,
    'Allocated_Engineer_Name': allocatedEngineerName,
    'start_hour': startHour,
    'Job_Type__c': jobType,
    'AppointmentNumber': appointmentNumber,
  };

  @override
  List<Object?> get props => [
    engineerEmail,
    allocatedEngineerId,
    id,
    status,
    subject,
    tradeGroup,
    workTypeName,
    postcode,
    endHour,
    allocatedEngineerName,
    startHour,
    jobType,
    appointmentNumber,
  ];
}

int _readInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
