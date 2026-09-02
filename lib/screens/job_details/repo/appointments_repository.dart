import 'package:chumley_navigator/models/engineer_appointment_detail.dart';
import 'package:chumley_navigator/models/engineer_form_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/job_details/service/appointments_api_service.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._apiService);

  final AppointmentsApiService _apiService;

  Future<EngineerAppointmentDetail> fetchAppointment(String saId) {
    return _apiService.fetchAppointment(saId);
  }

  Future<List<Appointment>> listAppointments() {
    return _apiService.listAppointments();
  }

  Future<EngineerAppointmentDetail> updateStatus({
    required String saId,
    required String status,
  }) {
    return _apiService.updateStatus(saId: saId, status: status);
  }

  Future<List<EngineerFormSummary>> fetchForms(String saId) {
    return _apiService.fetchForms(saId);
  }

  Future<EngineerFormDetail> fetchFormDetail({
    required String saId,
    required String workTypeId,
  }) {
    return _apiService.fetchFormDetail(saId: saId, workTypeId: workTypeId);
  }

  Future<EngineerFormDetail> saveFormDraft({
    required String saId,
    required String workTypeId,
    required Map<String, dynamic> answers,
    Map<String, String>? photoSlots,
    int? step,
    Map<String, dynamic>? extraData,
  }) {
    return _apiService.saveFormDraft(
      saId: saId,
      workTypeId: workTypeId,
      answers: answers,
      photoSlots: photoSlots,
      step: step,
      extraData: extraData,
    );
  }

  Future<Map<String, dynamic>> submitForm({
    required String saId,
    required String workTypeId,
    required Map<String, dynamic> answers,
    Map<String, String>? photoSlots,
    Map<String, dynamic>? extraData,
  }) {
    return _apiService.submitForm(
      saId: saId,
      workTypeId: workTypeId,
      answers: answers,
      photoSlots: photoSlots,
      extraData: extraData,
    );
  }
}
