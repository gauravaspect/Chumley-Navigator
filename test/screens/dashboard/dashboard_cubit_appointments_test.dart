import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/models/appointment.dart';
import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/screens/dashboard/repo/dashboard_repository.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDashboardRepository extends DashboardRepository {
  _FakeDashboardRepository() : super(DashboardApiService(ApiClient()));

  List<Appointment> appointments = const [];

  @override
  Future<UserModel?> readCachedProfile() async => const UserModel(id: 'u1');

  @override
  Future<List<Appointment>> fetchAppointments({
    UserModel? profileFallback,
  }) async {
    return appointments;
  }
}

void main() {
  group('DashboardCubit.upsertAppointment', () {
    test('replaces matching appointment status in loaded state', () {
      final repo = _FakeDashboardRepository();
      final cubit = DashboardCubit(repo);

      cubit.emit(
        const DashboardLoaded(
          user: UserModel(id: 'u1'),
          performanceHistory: EngineerPerformanceHistory(),
          appointments: [
            Appointment(id: 'sa-1', status: 'Dispatched', title: 'Job A'),
            Appointment(id: 'sa-2', status: 'In Transit', title: 'Job B'),
          ],
        ),
      );

      cubit.upsertAppointment(
        const Appointment(id: 'sa-1', status: 'On Site', title: 'Job A'),
      );

      final state = cubit.state;
      expect(state, isA<DashboardLoaded>());
      final appointments = (state as DashboardLoaded).appointments;
      expect(appointments.map((a) => a.status), ['On Site', 'In Transit']);
    });

    test('is a no-op when appointment id is unknown', () {
      final repo = _FakeDashboardRepository();
      final cubit = DashboardCubit(repo);

      const loaded = DashboardLoaded(
        user: UserModel(id: 'u1'),
        performanceHistory: EngineerPerformanceHistory(),
        appointments: [
          Appointment(id: 'sa-1', status: 'Dispatched', title: 'Job A'),
        ],
      );
      cubit.emit(loaded);

      cubit.upsertAppointment(
        const Appointment(id: 'missing', status: 'On Site', title: 'Other'),
      );

      expect(cubit.state, loaded);
    });
  });
}
