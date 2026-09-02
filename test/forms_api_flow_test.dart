import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/screens/forms/widgets/hse_risk_section.dart';
import 'package:chumley_navigator/screens/job_details/repo/appointments_repository.dart';
import 'package:chumley_navigator/screens/job_details/service/appointments_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends ApiClient {
  String? lastGetPath;
  String? lastPutPath;
  dynamic lastPutData;
  String? lastPostPath;
  dynamic lastPostData;

  Response<dynamic>? mockGetResponse;
  Response<dynamic>? mockPutResponse;
  Response<dynamic>? mockPostResponse;

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    lastGetPath = endpoint;
    if (mockGetResponse != null) {
      return mockGetResponse!;
    }
    return Response(
      requestOptions: RequestOptions(path: endpoint),
      data: {'success': true},
      statusCode: 200,
    );
  }

  @override
  Future<Response> put(String endpoint, dynamic data) async {
    lastPutPath = endpoint;
    lastPutData = data;
    if (mockPutResponse != null) {
      return mockPutResponse!;
    }
    return Response(
      requestOptions: RequestOptions(path: endpoint),
      data: {'success': true},
      statusCode: 200,
    );
  }

  @override
  Future<Response> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    lastPostPath = endpoint;
    lastPostData = data;
    if (mockPostResponse != null) {
      return mockPostResponse!;
    }
    return Response(
      requestOptions: RequestOptions(path: endpoint),
      data: {'success': true},
      statusCode: 200,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Forms API Endpoints URL Verification', () {
    test('ApiEndpoints correctly format forms routes', () {
      const saId = 'SA-290627';
      const workTypeId = 'ld_form';

      expect(
        ApiEndpoints.engineerAppointmentForms(saId),
        '/api/engineer/appointments/SA-290627/forms',
      );
      expect(
        ApiEndpoints.engineerAppointmentFormDetail(saId, workTypeId),
        '/api/engineer/appointments/SA-290627/forms/ld_form',
      );
      expect(
        ApiEndpoints.engineerAppointmentFormDraft(saId, workTypeId),
        '/api/engineer/appointments/SA-290627/forms/ld_form/draft',
      );
      expect(
        ApiEndpoints.engineerAppointmentFormSubmit(saId, workTypeId),
        '/api/engineer/appointments/SA-290627/forms/ld_form/submit',
      );
    });
  });

  group('AppointmentsApiService Forms Integration', () {
    late MockApiClient mockClient;
    late AppointmentsApiService apiService;

    setUp(() {
      mockClient = MockApiClient();
      apiService = AppointmentsApiService(mockClient);
    });

    test('fetchForms GET calls /api/engineer/appointments/{sa_id}/forms', () async {
      mockClient.mockGetResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'success': true,
          'forms': [
            {
              'id': 'f1',
              'work_type_id': 'ld_form',
              'title': 'LD Inspection Form',
              'status': 'draft',
              'is_draft': true,
            },
            {
              'id': 'f2',
              'work_type_id': 'damp_survey',
              'title': 'Damp Survey Form',
              'status': 'submitted',
              'is_submitted': true,
            },
          ]
        },
      );

      final forms = await apiService.fetchForms('SA-100');
      expect(mockClient.lastGetPath, '/api/engineer/appointments/SA-100/forms');
      expect(forms.length, 2);
      expect(forms[0].workTypeId, 'ld_form');
      expect(forms[0].isDraft, true);
      expect(forms[1].workTypeId, 'damp_survey');
      expect(forms[1].isSubmitted, true);
    });

    test('fetchFormDetail GET calls /api/engineer/appointments/{sa_id}/forms/{work_type_id}', () async {
      mockClient.mockGetResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'success': true,
          'form': {
            'id': 'f1',
            'work_type_id': 'ld_form',
            'title': 'LD Inspection',
            'status': 'draft',
            'step': 2,
            'answers': {
              'weather': 'Sunny',
              'visual_findings': 'Minor damp observed',
            },
            'photo_slots': {
              'front': 'https://example.com/front.jpg',
            },
          }
        },
      );

      final detail = await apiService.fetchFormDetail(
        saId: 'SA-100',
        workTypeId: 'ld_form',
      );
      expect(
        mockClient.lastGetPath,
        '/api/engineer/appointments/SA-100/forms/ld_form',
      );
      expect(detail.step, 2);
      expect(detail.answers['weather'], 'Sunny');
      expect(detail.photoSlots['front'], 'https://example.com/front.jpg');
    });

    test('saveFormDraft PUT calls /api/engineer/appointments/{sa_id}/forms/{work_type_id}/draft with consistent payload', () async {
      mockClient.mockPutResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'success': true,
          'form': {
            'work_type_id': 'ld_form',
            'status': 'draft',
          }
        },
      );

      final answers = {
        'weather': 'Rainy',
        'visual_findings': 'Inspection complete',
      };
      final photoSlots = {'site': 'https://example.com/site.jpg'};

      await apiService.saveFormDraft(
        saId: 'SA-100',
        workTypeId: 'ld_form',
        answers: answers,
        photoSlots: photoSlots,
        step: 1,
      );

      expect(
        mockClient.lastPutPath,
        '/api/engineer/appointments/SA-100/forms/ld_form/draft',
      );
      final payload = mockClient.lastPutData as Map<String, dynamic>;
      expect(payload['answers'], answers);
      expect(payload['photo_slots'], photoSlots);
      expect(payload['step'], 1);
    });

    test('submitForm POST calls /api/engineer/appointments/{sa_id}/forms/{work_type_id}/submit with consistent payload', () async {
      mockClient.mockPostResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Form submitted successfully',
        },
      );

      final answers = {
        'weather': 'Rainy',
        'works_completed': true,
      };

      final result = await apiService.submitForm(
        saId: 'SA-100',
        workTypeId: 'damp_survey',
        answers: answers,
        photoSlots: const {},
      );

      expect(
        mockClient.lastPostPath,
        '/api/engineer/appointments/SA-100/forms/damp_survey/submit',
      );
      final payload = mockClient.lastPostData as Map<String, dynamic>;
      expect(payload['answers'], answers);
      expect(payload['photo_slots'], const {});
      expect(result['success'], true);
    });
  });

  group('HseRiskFormController Serialization', () {
    test('toMap and fromMap serialize and restore all risk fields', () {
      final controller = HseRiskFormController();
      controller.riskAssessment = 'Yes - risk assessment completed, standard controls in place';
      controller.workAtHeight = 'Yes - work at height in scope today';
      controller.safeIsolation = 'Yes - locked off and proved dead';
      controller.clientBriefed = 'Briefed and consent given';
      controller.vulnerable = 'None present';
      controller.riskNoteController.text = 'Site is clear';

      final map = controller.toMap();
      expect(map['risk_assessment'], contains('standard controls in place'));
      expect(map['work_at_height'], contains('work at height in scope'));
      expect(map['risk_note'], 'Site is clear');

      final restored = HseRiskFormController();
      restored.fromMap(map);
      expect(restored.riskAssessment, controller.riskAssessment);
      expect(restored.workAtHeight, controller.workAtHeight);
      expect(restored.safeIsolation, controller.safeIsolation);
      expect(restored.clientBriefed, controller.clientBriefed);
      expect(restored.vulnerable, controller.vulnerable);
      expect(restored.riskNoteController.text, 'Site is clear');
    });
  });

  group('JobsRepository Forms Flow', () {
    test('saveFormDraft saves to local store and calls repository API', () async {
      final mockClient = MockApiClient();
      final apiService = AppointmentsApiService(mockClient);
      final repo = AppointmentsRepository(apiService);
      final draftStore = FormDraftStore();
      final jobs = JobsRepository(drafts: draftStore, appointments: repo);

      final answers = {
        'form_name': 'LD Form',
        'weather': 'Sunny',
      };

      await jobs.saveFormDraft(
        saId: 'SA-999',
        workTypeId: 'ld_form',
        answers: answers,
        step: 2,
      );

      final localAnswers = await draftStore.loadAnswers('SA-999');
      expect(localAnswers['form_name'], 'LD Form');
      expect(localAnswers['weather'], 'Sunny');
      final localStep = await draftStore.loadFurthestStep('SA-999');
      expect(localStep, 2);

      expect(
        mockClient.lastPutPath,
        '/api/engineer/appointments/SA-999/forms/ld_form/draft',
      );
    });
  });
}
