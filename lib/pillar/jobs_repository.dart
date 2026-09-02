import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/models/engineer_appointment_detail.dart';
import 'package:chumley_navigator/models/engineer_form_model.dart';
import 'package:chumley_navigator/models/sa_status.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/screens/job_details/repo/appointments_repository.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';

class JobsRepository {
  JobsRepository({
    FormDraftStore? drafts,
    AppointmentsRepository? appointments,
  })  : _drafts = drafts ?? FormDraftStore(),
        _appointments =
            appointments ?? AppDependencies.appointmentsRepository;

  final FormDraftStore _drafts;
  final AppointmentsRepository _appointments;

  Future<EngineerAppointmentDetail> fetchAppointment(String saId) {
    return _appointments.fetchAppointment(saId);
  }

  Future<String> resolveStatus(String saId, String fallback) async {
    return (await _drafts.loadStatus(saId)) ?? fallback;
  }

  /// Writes `On site` when the form wizard opens at step 0 (first entry).
  Future<void> ensureOnSiteAtFormEntry({
    required String saId,
    required int formStepIndex,
  }) async {
    if (formStepIndex != 0) return;
    final current = await resolveStatus(saId, '');
    if (SaStatus.normalizedKey(current) == SaStatus.normalizedKey(SaStatus.onSite)) {
      return;
    }
    final detail = await fetchAppointment(saId);
    if (detail.allowedNextStatuses.contains(SaStatus.onSite)) {
      await setStatus(saId: saId, status: SaStatus.onSite);
    }
  }

  Future<EngineerAppointmentDetail> setStatus({
    required String saId,
    required String status,
  }) async {
    final result = await _appointments.updateStatus(saId: saId, status: status);
    await _drafts.saveStatus(saId, result.status);
    return result;
  }

  /// Fetches the list of forms for this appointment via GET /api/engineer/appointments/{sa_id}/forms.
  Future<List<EngineerFormSummary>> fetchForms(String saId) {
    return _appointments.fetchForms(saId);
  }

  /// Retrieves draft responses from GET /api/engineer/appointments/{sa_id}/forms/{work_type_id},
  /// falling back to Firebase `demo_form_drafts` or local SharedPreferences store.
  Future<EngineerFormDetail?> fetchFormDraft({
    required String saId,
    required String workTypeId,
  }) async {
    try {
      final detail = await _appointments.fetchFormDetail(
        saId: saId,
        workTypeId: workTypeId,
      );
      if (detail.answers.isNotEmpty || detail.photoSlots.isNotEmpty) {
        await _drafts.saveDraft(
          jobId: saId,
          step: detail.step,
          answers: detail.answers,
          photos: detail.photoSlots,
        );
      }
      return detail;
    } catch (e) {
      Log('API fetchFormDetail failed for $saId / $workTypeId, checking Firebase / local: $e', name: 'JobsRepository');
    }

    // Fallback 1: Firebase Firestore draft document
    final firebaseDraft = await PillarClient.getFormDraft(
      saId: saId,
      workTypeId: workTypeId,
    );
    if (firebaseDraft != null) {
      final detail = EngineerFormDetail.fromJson(firebaseDraft);
      await _drafts.saveDraft(
        jobId: saId,
        step: detail.step,
        answers: detail.answers,
        photos: detail.photoSlots,
      );
      return detail;
    }

    // Fallback 2: SharedPreferences local store
    final localAnswers = await _drafts.loadAnswers(saId);
    final localPhotos = await _drafts.loadPhotos(saId);
    final localStep = await _drafts.loadFurthestStep(saId);
    if (localAnswers.isNotEmpty || localPhotos.isNotEmpty) {
      return EngineerFormDetail(
        id: workTypeId,
        workTypeId: workTypeId,
        title: workTypeId,
        answers: localAnswers,
        photoSlots: localPhotos,
        step: localStep,
      );
    }

    return null;
  }

  /// Saves form draft via PUT /api/engineer/appointments/{sa_id}/forms/{work_type_id}/draft,
  /// syncs to Firestore `demo_form_drafts` and updates local SharedPreferences.
  Future<void> saveFormDraft({
    required String saId,
    required String workTypeId,
    required Map<String, dynamic> answers,
    Map<String, String> photoSlots = const {},
    int step = 0,
    Map<String, dynamic>? extraData,
  }) async {
    // 1. Local draft save
    await _drafts.saveDraft(
      jobId: saId,
      step: step,
      answers: answers,
      photos: photoSlots,
    );

    // 2. Firebase schema creation / write
    await PillarClient.saveFormDraft(
      saId: saId,
      workTypeId: workTypeId,
      answers: answers,
      photoSlots: photoSlots,
      step: step,
      extraData: extraData,
    );

    // 3. API endpoint call
    try {
      await _appointments.saveFormDraft(
        saId: saId,
        workTypeId: workTypeId,
        answers: answers,
        photoSlots: photoSlots,
        step: step,
        extraData: extraData,
      );
    } catch (e) {
      Log('PUT form draft endpoint failed for $saId / $workTypeId (saved to Firebase & local): $e', name: 'JobsRepository');
    }
  }

  /// Submits form responses via POST /api/engineer/appointments/{sa_id}/forms/{work_type_id}/submit
  /// and commits sign-off to Firebase.
  Future<void> submitForm({
    required String saId,
    required String workTypeId,
    required String reportType,
    required String reportSuffix,
    required Map<String, dynamic> answers,
    required Map<String, String> photoSlots,
    String? pmProjectId,
    Map<String, dynamic>? extraData,
  }) async {
    await _drafts.saveStatus(saId, SaStatus.visitComplete);

    // 1. POST API submit endpoint
    try {
      await _appointments.submitForm(
        saId: saId,
        workTypeId: workTypeId,
        answers: answers,
        photoSlots: photoSlots,
        extraData: extraData,
      );
    } catch (e) {
      Log('POST submit form API failed for $saId / $workTypeId: $e', name: 'JobsRepository');
    }

    // 2. Commit sign-off to Firestore
    final ok = await PillarClient.submitSignOff(
      jobId: saId,
      reportType: reportType,
      reportSuffix: reportSuffix,
      answers: answers,
      photoSlots: photoSlots,
      pmProjectId: pmProjectId,
    );
    if (!ok) {
      throw StateError('Could not submit report for $saId');
    }
  }

  Future<void> signOff({
    required String jobId,
    required String reportType,
    required String reportSuffix,
    required Map<String, dynamic> answers,
    required Map<String, String> photoSlots,
    String? pmProjectId,
  }) async {
    await submitForm(
      saId: jobId,
      workTypeId: reportType,
      reportType: reportType,
      reportSuffix: reportSuffix,
      answers: answers,
      photoSlots: photoSlots,
      pmProjectId: pmProjectId,
    );
  }

  /// After sign-off, advance SA status when the API allows (Job Closure → Visit Complete).
  Future<EngineerAppointmentDetail?> advanceAfterSignOff(String saId) async {
    try {
      var detail = await fetchAppointment(saId);
      for (final target in [SaStatus.jobClosure, SaStatus.visitComplete]) {
        final allowed = SaStatus.pickAllowed(detail.allowedNextStatuses, target);
        if (allowed == null) continue;
        detail = await setStatus(saId: saId, status: allowed);
        if (SaStatus.isVisitComplete(detail.status)) return detail;
      }
      return detail;
    } catch (e) {
      Log('advanceAfterSignOff failed for $saId: $e', name: 'JobsRepository');
      return null;
    }
  }
}
