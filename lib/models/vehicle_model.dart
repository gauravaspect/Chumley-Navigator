import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  const VehicleModel({
    this.id = '',
    this.vehicleId = '',
    this.vehicleName = '',
    this.vanNumber = '',
    this.regNo = '',
    this.serviceResourceId = '',
    this.engineerName = '',
    this.startDate = '',
    this.endDate = '',
  });

  final String id;
  final String vehicleId;
  final String vehicleName;
  final String vanNumber;
  final String regNo;
  final String serviceResourceId;
  final String engineerName;
  final String startDate;
  final String endDate;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] ?? '').toString(),
      vehicleId: (json['vehicle_id'] ?? '').toString(),
      vehicleName: (json['vehicle_name'] ?? '').toString(),
      vanNumber: (json['van_number'] ?? '').toString(),
      regNo: (json['reg_no'] ?? '').toString(),
      serviceResourceId: (json['service_resource_id'] ?? '').toString(),
      engineerName: (json['engineer_name'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: json['end_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': vehicleId,
    'vehicle_name': vehicleName,
    'van_number': vanNumber,
    'reg_no': regNo,
    'service_resource_id': serviceResourceId,
    'engineer_name': engineerName,
    'start_date': startDate,
    'end_date': endDate,
  };

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    vehicleName,
    vanNumber,
    regNo,
    serviceResourceId,
    engineerName,
    startDate,
    endDate,
  ];
}

class VehicleResponse extends Equatable {
  const VehicleResponse({
    this.data = const [],
    this.success = false,
  });

  final List<VehicleModel> data;
  final bool success;

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final vehicles = rawData is List
        ? rawData
            .whereType<Map>()
            .map(
              (item) => VehicleModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <VehicleModel>[];

    return VehicleResponse(
      data: vehicles,
      success: json['success'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'success': success,
  };

  @override
  List<Object?> get props => [data, success];
}
