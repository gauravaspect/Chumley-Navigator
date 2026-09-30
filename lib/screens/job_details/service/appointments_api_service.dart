import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/models/engineer_appointment_detail.dart';
import 'package:chumley_navigator/models/engineer_form_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:dio/dio.dart';

class AppointmentsApiService {
  AppointmentsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<EngineerAppointmentDetail> fetchAppointment(String saId) async {
    _ensureConfigured();
    final id = saId.trim();
    if (id.isEmpty) {
      throw const AppointmentApiException('Appointment id is missing.');
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.engineerAppointment(id),
      );
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load appointment.',
          ),
        );
      }
      return EngineerAppointmentDetail.fromJson(body);
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to load appointment.'),
      );
    }
  }

  /// Lists all engineer appointments (all statuses). Engineer from bearer token.
  Future<List<Appointment>> listAppointments() async {
    _ensureConfigured();

    try {
      Log('Fetching engineer appointments list', name: 'AppointmentsApi');
      final response = await _apiClient.get(ApiEndpoints.engineerAppointments);
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load appointments.',
          ),
        );
      }
      return _parseAppointmentList(body);
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to load appointments.'),
      );
    }
  }

  List<Appointment> _parseAppointmentList(Map<String, dynamic> body) {
    final raw =
        body['appointments'] ??
        body['service_appointments'] ??
        (body['data'] is Map
            ? (body['data'] as Map)['appointments'] ??
                  (body['data'] as Map)['service_appointments']
            : body['data']);

    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((m) => Appointment.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  Future<EngineerAppointmentDetail> updateStatus({
    required String saId,
    required String status,
  }) async {
    _ensureConfigured();
    final id = saId.trim();
    final nextStatus = status.trim();
    if (id.isEmpty) {
      throw const AppointmentApiException('Appointment id is missing.');
    }
    if (nextStatus.isEmpty) {
      throw const AppointmentApiException('Status is required.');
    }

    try {
      Log(
        'Updating appointment $id status to: "$nextStatus"',
        name: 'AppointmentsApi',
      );
      final response = await _apiClient.post(
        ApiEndpoints.engineerAppointmentStatus(id),
        {'status': nextStatus},
      );
      Log(
        'Update status response: ${response.statusCode} ${response.data}',
        name: 'AppointmentsApi',
      );
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to update appointment status.',
          ),
        );
      }
      return EngineerAppointmentDetail.fromJson(body);
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      Log(
        'Update status failed for $id with error: ${e.response?.statusCode} ${e.response?.data}',
        name: 'AppointmentsApi',
      );
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to update appointment status.'),
      );
    }
  }

  Future<List<EngineerFormSummary>> fetchForms(String saId) async {
    _ensureConfigured();
    final id = saId.trim();
    if (id.isEmpty) {
      throw const AppointmentApiException('Appointment id is missing.');
    }

    try {
      Log('Fetching forms for appointment $id', name: 'AppointmentsApi');
      final response = await _apiClient.get(
        ApiEndpoints.engineerAppointmentForms(id),
      );
      Log(
        'Fetch forms response for $id: ${response.statusCode}',
        name: 'AppointmentsApi',
      );
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load appointment forms.',
          ),
        );
      }
      final list = body['forms'] ?? body['data'] ?? [];
      if (list is List) {
        return list
            .whereType<Map>()
            .map(
              (m) => EngineerFormSummary.fromJson(Map<String, dynamic>.from(m)),
            )
            .toList();
      }
      return const [];
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      Log(
        'Fetch forms failed for $id: ${e.response?.statusCode} ${e.response?.data}',
        name: 'AppointmentsApi',
      );
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to load appointment forms.'),
      );
    }
  }

  Future<EngineerFormDetail> fetchFormDetail({
    required String saId,
    required String workTypeId,
  }) async {
    _ensureConfigured();
    final id = saId.trim();
    final wt = workTypeId.trim();
    if (id.isEmpty || wt.isEmpty) {
      throw const AppointmentApiException(
        'Appointment id and work type id are required.',
      );
    }

    try {
      Log('Fetching form detail for $id / $wt', name: 'AppointmentsApi');
      final response = await _apiClient.get(
        ApiEndpoints.engineerAppointmentFormDetail(id, wt),
      );
      Log(
        'Fetch form detail response for $id / $wt: ${response.statusCode}',
        name: 'AppointmentsApi',
      );
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load form details.',
          ),
        );
      }
      return EngineerFormDetail.fromJson(body);
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      Log(
        'Fetch form detail failed for $id / $wt: ${e.response?.statusCode} ${e.response?.data}',
        name: 'AppointmentsApi',
      );
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to load form details.'),
      );
    }
  }

  Future<EngineerFormDetail> saveFormDraft({
    required String saId,
    required String workTypeId,
    required Map<String, dynamic> answers,
    Map<String, String>? photoSlots,
    int? step,
    Map<String, dynamic>? extraData,
  }) async {
    _ensureConfigured();
    final id = saId.trim();
    final wt = workTypeId.trim();
    if (id.isEmpty || wt.isEmpty) {
      throw const AppointmentApiException(
        'Appointment id and work type id are required.',
      );
    }

    final payload = <String, dynamic>{
      'answers': answers,
      'photo_slots': ?photoSlots,
      'step': ?step,
      ...?extraData,
    };

    try {
      Log(
        'Saving form draft for $id / $wt: payload keys ${payload.keys}',
        name: 'AppointmentsApi',
      );
      final response = await _apiClient.put(
        ApiEndpoints.engineerAppointmentFormDraft(id, wt),
        payload,
      );
      Log(
        'Save form draft response for $id / $wt: ${response.statusCode}',
        name: 'AppointmentsApi',
      );
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to save form draft.',
          ),
        );
      }
      return EngineerFormDetail.fromJson(body);
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      Log(
        'Save form draft failed for $id / $wt: ${e.response?.statusCode} ${e.response?.data}',
        name: 'AppointmentsApi',
      );
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to save form draft.'),
      );
    }
  }

  Future<Map<String, dynamic>> submitForm({
    required String saId,
    required String workTypeId,
    required Map<String, dynamic> answers,
    Map<String, String>? photoSlots,
    Map<String, dynamic>? extraData,
  }) async {
    _ensureConfigured();
    final id = saId.trim();
    final wt = workTypeId.trim();
    if (id.isEmpty || wt.isEmpty) {
      throw const AppointmentApiException(
        'Appointment id and work type id are required.',
      );
    }

    final payload = <String, dynamic>{
      'answers': answers,
      'photo_slots': ?photoSlots,
      ...?extraData,
    };

    try {
      Log(
        'Submitting form for $id / $wt: payload keys ${payload.keys}',
        name: 'AppointmentsApi',
      );
      final response = await _apiClient.post(
        ApiEndpoints.engineerAppointmentFormSubmit(id, wt),
        payload,
      );
      Log(
        'Submit form response for $id / $wt: ${response.statusCode} ${response.data}',
        name: 'AppointmentsApi',
      );
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AppointmentApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to submit form.',
          ),
        );
      }
      return body;
    } on AppointmentApiException {
      rethrow;
    } on DioException catch (e) {
      Log(
        'Submit form failed for $id / $wt: ${e.response?.statusCode} ${e.response?.data}',
        name: 'AppointmentsApi',
      );
      throw AppointmentApiException(
        _messageForDio(e, fallback: 'Unable to submit form.'),
      );
    }
  }

  void _ensureConfigured() {
    if (!ApiEndpoints.isConfigured) {
      throw const AppointmentApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }
  }

  String _messageForDio(DioException e, {required String fallback}) {
    final serverMessage = ApiResponseHelper.extractMessage(e.response?.data);
    if (serverMessage.isNotEmpty && serverMessage != 'Server error') {
      return serverMessage;
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return 'Session expired. Please sign in again.';
    }
    if (code == 404) {
      return 'This job is not assigned to you or could not be found.';
    }
    if (code == 409) {
      return ApiResponseHelper.extractMessage(
        e.response?.data,
        fallback: 'That status change is not allowed.',
      );
    }
    if (code == 400) {
      return ApiResponseHelper.extractMessage(
        e.response?.data,
        fallback: 'Invalid status.',
      );
    }
    return serverMessage.isNotEmpty
        ? serverMessage
        : (NetworkExceptions.getError(e).isNotEmpty
              ? NetworkExceptions.getError(e)
              : fallback);
  }
}

class AppointmentApiException implements Exception {
  const AppointmentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
