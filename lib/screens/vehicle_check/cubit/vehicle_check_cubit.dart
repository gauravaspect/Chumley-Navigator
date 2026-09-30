import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vehicle_check_state.dart';
import 'package:chumley_navigator/screens/vehicle_check/repo/vehicle_check_repository.dart';
import 'package:chumley_navigator/screens/vehicle_check/service/vehicle_check_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleCheckCubit extends Cubit<VehicleCheckState> {
  VehicleCheckCubit(this._repository) : super(const VehicleCheckInitial());

  final VehicleCheckRepository _repository;

  Future<void> load() async {
    final cachedAllocations =
        state.allocationsOrNull ??
        await _repository.readCachedVehicleAllocations();
    final selectedVehicle = state.selectedVehicleOrNull;
    emit(
      VehicleCheckLoading(
        cachedAllocations: cachedAllocations,
        selectedVehicle: selectedVehicle,
      ),
    );

    try {
      final allocations = await _repository.fetchVehicleAllocations();
      emit(
        VehicleCheckLoaded(
          allocations: allocations,
          selectedVehicle: _resolveSelectedVehicle(
            allocations: allocations,
            current: selectedVehicle,
          ),
        ),
      );
    } on VehicleCheckApiException catch (e) {
      emit(
        VehicleCheckError(
          message: e.message,
          cachedAllocations: cachedAllocations,
          selectedVehicle: selectedVehicle,
        ),
      );
    } catch (_) {
      emit(
        VehicleCheckError(
          message: 'Unable to load vehicle allocations. Please try again.',
          cachedAllocations: cachedAllocations,
          selectedVehicle: selectedVehicle,
        ),
      );
    }
  }

  void selectVehicle(VehicleModel vehicle) {
    final allocations = state.allocationsOrNull;
    if (allocations == null) return;

    switch (state) {
      case VehicleCheckLoaded():
        emit(
          VehicleCheckLoaded(
            allocations: allocations,
            selectedVehicle: vehicle,
          ),
        );
      case VehicleCheckError(:final message):
        emit(
          VehicleCheckError(
            message: message,
            cachedAllocations: allocations,
            selectedVehicle: vehicle,
          ),
        );
      case VehicleCheckLoading(:final cachedAllocations):
        emit(
          VehicleCheckLoading(
            cachedAllocations: cachedAllocations,
            selectedVehicle: vehicle,
          ),
        );
      default:
        break;
    }
  }

  Future<void> refresh() => load();

  VehicleModel? _resolveSelectedVehicle({
    required VehicleResponse allocations,
    VehicleModel? current,
  }) {
    if (allocations.data.isEmpty) return null;
    if (current != null &&
        allocations.data.any((vehicle) => vehicle.id == current.id)) {
      return current;
    }
    return allocations.data.first;
  }
}
