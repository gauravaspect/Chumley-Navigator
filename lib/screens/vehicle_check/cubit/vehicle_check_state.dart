import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:equatable/equatable.dart';

sealed class VehicleCheckState extends Equatable {
  const VehicleCheckState();

  @override
  List<Object?> get props => [];
}

class VehicleCheckInitial extends VehicleCheckState {
  const VehicleCheckInitial();
}

class VehicleCheckLoading extends VehicleCheckState {
  const VehicleCheckLoading({
    this.cachedAllocations,
    this.selectedVehicle,
  });

  final VehicleResponse? cachedAllocations;
  final VehicleModel? selectedVehicle;

  @override
  List<Object?> get props => [cachedAllocations, selectedVehicle];
}

class VehicleCheckLoaded extends VehicleCheckState {
  const VehicleCheckLoaded({
    required this.allocations,
    this.selectedVehicle,
  });

  final VehicleResponse allocations;
  final VehicleModel? selectedVehicle;

  @override
  List<Object?> get props => [allocations, selectedVehicle];
}

class VehicleCheckError extends VehicleCheckState {
  const VehicleCheckError({
    required this.message,
    this.cachedAllocations,
    this.selectedVehicle,
  });

  final String message;
  final VehicleResponse? cachedAllocations;
  final VehicleModel? selectedVehicle;

  @override
  List<Object?> get props => [message, cachedAllocations, selectedVehicle];
}

extension VehicleCheckStateX on VehicleCheckState {
  VehicleResponse? get allocationsOrNull => switch (this) {
    VehicleCheckLoaded(:final allocations) => allocations,
    VehicleCheckLoading(:final cachedAllocations) => cachedAllocations,
    VehicleCheckError(:final cachedAllocations) => cachedAllocations,
    _ => null,
  };

  VehicleModel? get selectedVehicleOrNull => switch (this) {
    VehicleCheckLoaded(:final selectedVehicle) => selectedVehicle,
    VehicleCheckLoading(:final selectedVehicle) => selectedVehicle,
    VehicleCheckError(:final selectedVehicle) => selectedVehicle,
    _ => null,
  };

  List<VehicleModel> get vehicles => allocationsOrNull?.data ?? const [];

  bool get hasVehicles => vehicles.isNotEmpty;
}
