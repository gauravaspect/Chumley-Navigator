import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';

class JobsRepository {
  JobsRepository({FormDraftStore? drafts}) : _drafts = drafts ?? FormDraftStore();

  final FormDraftStore _drafts;

  Future<String> resolveStatus(String jobId, String fallback) async {
    return (await _drafts.loadStatus(jobId)) ?? fallback;
  }

  /// Writes `ON_SITE` only when the form wizard opens at step 0 (first entry).
  Future<void> ensureOnSiteAtFormEntry({
    required String jobId,
    required int formStepIndex,
  }) async {
    if (formStepIndex != 0) return;
    final current = await resolveStatus(jobId, '');
    if (current.toUpperCase() == PillarClient.statusOnSite) return;
    await setStatus(jobId: jobId, status: PillarClient.statusOnSite);
  }

  Future<void> setStatus({
    required String jobId,
    required String status,
    String engineerEmail = PillarClient.defaultEngineerEmail,
  }) async {
    await _drafts.saveStatus(jobId, status);
    final ok = await PillarClient.setStatus(
      jobId: jobId,
      newStatus: status,
      engineerEmail: engineerEmail,
    );
    if (!ok) {
      throw StateError('Could not write $status for $jobId');
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
    await _drafts.saveStatus(jobId, PillarClient.statusComplete);
    final ok = await PillarClient.submitSignOff(
      jobId: jobId,
      reportType: reportType,
      reportSuffix: reportSuffix,
      answers: answers,
      photoSlots: photoSlots,
      pmProjectId: pmProjectId,
    );
    if (!ok) {
      throw StateError('Could not submit report for $jobId');
    }
  }
}
