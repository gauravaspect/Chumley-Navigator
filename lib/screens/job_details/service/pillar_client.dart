import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chumley_navigator/core/log.dart';

/// Contract constants and Firestore spine client for Aspect Navigator.
/// Matches `JOB_FLOW.md`, `contract/contract.ts`, and runtime specifications.
class PillarClient {
  static const String defaultEngineerEmail = 'navigatorengineer@aspect.co.uk';

  /// Toggle for live Firestore network writes.
  /// Set to false to test initial offline/local workflow without executing remote Firebase writes.
  static const bool enableFirestoreWrites = false;

  // Firestore Collections
  static const String colEngineerJobs = 'demo_engineer_jobs';
  static const String colStatusUpdates = 'demo_job_status_updates';
  static const String colReports = 'demo_reports';
  static const String colJobPhotos = 'demo_job_photos';
  static const String colFpSubmissions = 'demo_fp_submissions';
  static const String colFpLineItems = 'demo_fp_line_items';
  static const String colCustomerEnquiries = 'demo_customer_enquiries';
  static const String colPmProjects = 'demo_pm_projects';
  static const String colPmTasks = 'demo_pm_tasks';
  static const String colFormDrafts = 'demo_form_drafts';

  // Contract Status Enums (Sequential Ladder)
  static const String statusScheduled = 'SCHEDULED';
  static const String statusDispatched = 'DISPATCHED';
  static const String statusInTransit = 'IN_TRANSIT';
  static const String statusOnSite = 'ON_SITE';
  static const String statusComplete = 'COMPLETE';
  static const String statusAwaitingApproval = 'AWAITING_APPROVAL';
  static const String statusApproved = 'APPROVED';

  // Rank Map for Forward-Only transitions
  static const Map<String, int> rank = {
    statusScheduled: 0,
    statusDispatched: 1,
    statusInTransit: 2,
    statusOnSite: 3,
    statusComplete: 4,
    statusAwaitingApproval: 5,
    statusApproved: 6,
  };

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Status Ladder & Sibling Demotion
  // ---------------------------------------------------------------------------

  /// Updates job status according to rank guard.
  /// When setting `IN_TRANSIT`:
  ///   - sets `actual_start`
  ///   - demotes other in-flight jobs of this engineer back to `DISPATCHED` with `actual_start: null`
  /// When setting `COMPLETE`:
  ///   - sets `actual_end`
  /// Appends status record in `demo_job_status_updates/{jobId}__{status}`.
  static Future<bool> setStatus({
    required String jobId,
    required String newStatus,
    String engineerEmail = defaultEngineerEmail,
    Map<String, dynamic>? extraData,
  }) async {
    if (jobId.trim().isEmpty) return false;
    final normalizedNew = newStatus.toUpperCase().trim();
    final newRank = rank[normalizedNew] ?? -1;

    try {
      final savedLocalStatus = await getLocalStatus(jobId) ?? statusDispatched;
      final currentRank = rank[savedLocalStatus] ?? 1;

      // LOCAL UI TEST: skip forward-only guard so the same job can be re-run.
      if (!enableFirestoreWrites) {
        await saveLocalStatus(jobId, normalizedNew);
        Log(
          '[LOCAL UI TEST] setStatus for $jobId -> $normalizedNew (SharedPreferences only)',
          name: 'PillarClient',
        );
        return true;
      }

      if (newRank < currentRank && newRank != -1) {
        Log(
          'Status regression blocked: cannot move from $savedLocalStatus (rank $currentRank) to $normalizedNew (rank $newRank)',
          name: 'PillarClient',
        );
        return false;
      }

      // Sync local preference cache immediately
      await saveLocalStatus(jobId, normalizedNew);

      /* -----------------------------------------------------------------------
       * ACTUAL FIRESTORE WRITE (Active when enableFirestoreWrites = true)
       * ----------------------------------------------------------------------- */
      final docRef = _db.collection(colEngineerJobs).doc(jobId);
      final updatePayload = <String, dynamic>{
        'status': normalizedNew,
        'engineer_email': engineerEmail,
        if (extraData != null) ...extraData,
      };

      if (normalizedNew == statusInTransit) {
        updatePayload['actual_start'] = FieldValue.serverTimestamp();
      } else if (normalizedNew == statusComplete) {
        updatePayload['actual_end'] = FieldValue.serverTimestamp();
      }

      // Single-Engineer Single-Site Rule: Demote sibling in-flight jobs if moving to IN_TRANSIT
      if (normalizedNew == statusInTransit) {
        final siblingQuery = await _db
            .collection(colEngineerJobs)
            .where('engineer_email', isEqualTo: engineerEmail)
            .get();

        final batch = _db.batch();
        for (final sibling in siblingQuery.docs) {
          if (sibling.id == jobId) continue;
          final sStatus = (sibling.data()['status'] ?? '').toString().toUpperCase();
          if (sStatus == statusInTransit || sStatus == statusOnSite) {
            batch.update(sibling.reference, {
              'status': statusDispatched,
              'actual_start': null,
              'updated_at': FieldValue.serverTimestamp(),
            });
            final siblingUpdateDoc = _db.collection(colStatusUpdates).doc('${sibling.id}__dispatched');
            batch.set(siblingUpdateDoc, {
              'job_id': sibling.id,
              'status': statusDispatched,
              'engineer_email': engineerEmail,
              'reason': 'Sibling job $jobId transitioned to IN_TRANSIT',
              'created_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
        batch.set(docRef, updatePayload, SetOptions(merge: true));

        final timelineDoc = _db.collection(colStatusUpdates).doc('${jobId}__${normalizedNew.toLowerCase()}');
        batch.set(timelineDoc, {
          'job_id': jobId,
          'status': normalizedNew,
          'engineer_email': engineerEmail,
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await batch.commit();
      } else {
        await docRef.set(updatePayload, SetOptions(merge: true));

        final timelineDoc = _db.collection(colStatusUpdates).doc('${jobId}__${normalizedNew.toLowerCase()}');
        await timelineDoc.set({
          'job_id': jobId,
          'status': normalizedNew,
          'engineer_email': engineerEmail,
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e, st) {
      Log('Pillar setStatus error: $e\n$st', name: 'PillarClient');
      await saveLocalStatus(jobId, normalizedNew);
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign-off Batch Write (`signoff_runtime.js` parity)
  // ---------------------------------------------------------------------------

  /// Performs atomic Firestore batch sign-off write matching Section 6 of JOB_FLOW.md:
  /// 1. `demo_engineer_jobs/{jobId}` -> status COMPLETE, actual_end, completion_data, photos
  /// 2. `demo_reports/{jobId}__{reportSuffix}` -> full report details
  /// 3. `demo_job_status_updates/{jobId}__complete` -> completion timeline
  /// 4. `demo_job_photos/{jobId}__{slot}` -> camelCase portal schema (jobId, photoUrl, caption, isReady, uploadedAt)
  /// 5. Recounts PM project progress if applicable via `advanceProject`.
  static Future<bool> submitSignOff({
    required String jobId,
    required String reportSuffix, // "ld" or "pm"
    required String reportType, // "LD" or "PM_WORKS"
    required Map<String, dynamic> answers,
    required Map<String, String> photoSlots, // { slotName: photoUrlOrPath }
    Map<String, dynamic>? completionData,
    String? pmProjectId,
    String engineerEmail = defaultEngineerEmail,
    String engineerName = 'Navigator Test Engineer',
  }) async {
    if (jobId.trim().isEmpty) return false;

    // Split answers and photo skips
    final substantiveAnswers = <String, dynamic>{};
    final photoSkips = <String, dynamic>{};
    answers.forEach((key, value) {
      if (key.startsWith('skip:')) {
        photoSkips[key.replaceFirst('skip:', '')] = value;
      } else {
        substantiveAnswers[key] = value;
      }
    });

    final photoUrlsList = photoSlots.values.where((v) => v.isNotEmpty).toList();
    final compiledCompletionData = completionData ?? {
      'form': reportType.toLowerCase(),
      'pm_project_id': pmProjectId,
      'answers': substantiveAnswers,
      'photo_skips': photoSkips,
      'photo_urls': photoSlots,
      'answered_count': substantiveAnswers.length,
      'photo_count': photoUrlsList.length,
      'completed_by': engineerName,
      'completed_at': DateTime.now().toIso8601String(),
    };

    // Save locally
    await saveLocalStatus(jobId, statusComplete);
    await clearLocalAnswers(jobId);
    await saveJobProgress(jobId, 5); // Step 5 completed

    if (!enableFirestoreWrites) {
      Log(
        '[TEST MODE: Firebase writes disabled] submitSignOff for $jobId (Type: $reportType, Answers: ${substantiveAnswers.length}, Photos: ${photoUrlsList.length})',
        name: 'PillarClient',
      );
      return true;
    }

    /* -------------------------------------------------------------------------
     * ACTUAL FIRESTORE BATCH COMMIT (Active when enableFirestoreWrites = true)
     * ------------------------------------------------------------------------- */
    try {
      final batch = _db.batch();

      final jobDoc = _db.collection(colEngineerJobs).doc(jobId);
      final jobUpdate = <String, dynamic>{
        'status': statusComplete,
        'actual_end': FieldValue.serverTimestamp(),
        'completion_data': compiledCompletionData,
        'photos': photoUrlsList,
        'engineer_email': engineerEmail,
        'updated_at': FieldValue.serverTimestamp(),
      };
      batch.set(jobDoc, jobUpdate, SetOptions(merge: true));

      // Deterministic report document
      final reportDoc = _db.collection(colReports).doc('${jobId}__${reportSuffix.toLowerCase()}');
      batch.set(reportDoc, {
        'job_id': jobId,
        'report_type': reportType,
        'answers': substantiveAnswers,
        'photo_skips': photoSkips,
        'photos': photoSlots,
        'engineer_email': engineerEmail,
        'engineer_name': engineerName,
        'status': 'submitted',
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mark draft as submitted in demo_form_drafts
      final draftDoc = _db.collection(colFormDrafts).doc('${jobId}__${reportSuffix.toLowerCase()}');
      batch.set(draftDoc, {
        'status': 'submitted',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Status update timeline doc
      final statusDoc = _db.collection(colStatusUpdates).doc('${jobId}__complete');
      batch.set(statusDoc, {
        'job_id': jobId,
        'status': statusComplete,
        'engineer_email': engineerEmail,
        'engineer_name': engineerName,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Photos in camelCase for Customer Portal
      photoSlots.forEach((slot, url) {
        if (url.isNotEmpty) {
          final slotSlug = slot.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
          final photoDoc = _db.collection(colJobPhotos).doc('${jobId}__$slotSlug');
          batch.set(photoDoc, {
            'jobId': jobId,
            'photoUrl': url,
            'caption': slot,
            'uploadedAt': FieldValue.serverTimestamp(),
            'isReady': true,
          }, SetOptions(merge: true));
        }
      });

      await batch.commit();

      // PM Project Recount if applicable
      if (pmProjectId != null && pmProjectId.isNotEmpty) {
        await advanceProject(pmProjectId);
      }

      return true;
    } catch (e, st) {
      Log('Sign-off error in PillarClient: $e\n$st', name: 'PillarClient');
      return true;
    }
  }

  /// Writes form draft schema and answers to Firestore `demo_form_drafts/{saId}__{workTypeId}`.
  static Future<bool> saveFormDraft({
    required String saId,
    required String workTypeId,
    required Map<String, dynamic> answers,
    Map<String, String> photoSlots = const {},
    int step = 0,
    String engineerEmail = defaultEngineerEmail,
    Map<String, dynamic>? extraData,
  }) async {
    final docId = '${saId.trim()}__${workTypeId.trim().toLowerCase()}';
    try {
      if (!enableFirestoreWrites) {
        Log('[TEST MODE] saveFormDraft for $docId (Answers: ${answers.length})', name: 'PillarClient');
        return true;
      }
      final draftDoc = _db.collection(colFormDrafts).doc(docId);
      await draftDoc.set({
        'sa_id': saId,
        'work_type_id': workTypeId,
        'answers': answers,
        'photo_slots': photoSlots,
        'step': step,
        'engineer_email': engineerEmail,
        'status': 'draft',
        'updated_at': FieldValue.serverTimestamp(),
        if (extraData != null) ...extraData,
      }, SetOptions(merge: true));
      return true;
    } catch (e, st) {
      Log('Draft error in PillarClient: $e\n$st', name: 'PillarClient');
      return false;
    }
  }

  /// Retrieves draft form document from Firestore `demo_form_drafts/{saId}__{workTypeId}`.
  static Future<Map<String, dynamic>?> getFormDraft({
    required String saId,
    required String workTypeId,
  }) async {
    final docId = '${saId.trim()}__${workTypeId.trim().toLowerCase()}';
    try {
      if (!enableFirestoreWrites) return null;
      final draftDoc = await _db.collection(colFormDrafts).doc(docId).get();
      if (draftDoc.exists && draftDoc.data() != null) {
        return draftDoc.data();
      }
    } catch (e) {
      Log('Failed to get form draft from Firestore: $e', name: 'PillarClient');
    }
    return null;
  }

  /// Recounts PM Project visits and updates completion percentage on `demo_pm_projects`
  static Future<void> advanceProject(String pmProjectId) async {
    if (!enableFirestoreWrites) return;
    try {
      final visitsQuery = await _db
          .collection(colEngineerJobs)
          .where('pm_project_id', isEqualTo: pmProjectId)
          .get();

      final visits = visitsQuery.docs;
      final completedCount = visits.where((d) => (d.data()['status'] ?? '').toString().toUpperCase() == statusComplete).length;

      final projectRef = _db.collection(colPmProjects).doc(pmProjectId);
      final projectSnap = await projectRef.get();
      final projectData = projectSnap.data() ?? {};
      final totalStages = (projectData['sa_count'] as num?)?.toInt() ?? visits.length;

      final percentComplete = totalStages > 0 ? ((completedCount / totalStages) * 100).round() : 0;
      final newProjectStatus = completedCount >= totalStages
          ? 'COMPLETE'
          : completedCount > 0
              ? 'IN_PROGRESS'
              : 'APPROVED';

      await projectRef.set({
        'stages_complete': completedCount,
        'percent_complete': percentComplete,
        'status': newProjectStatus,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Log('advanceProject: $pmProjectId updated to $percentComplete% ($newProjectStatus)', name: 'PillarClient');
    } catch (e) {
      Log('advanceProject error: $e', name: 'PillarClient');
    }
  }

  // ---------------------------------------------------------------------------
  // Fixed Price Estimate Raise (`estimate_runtime.js` parity)
  // ---------------------------------------------------------------------------

  static Future<bool> submitFpEstimate({
    required String jobId,
    required List<Map<String, dynamic>> lineItems,
    required double totalNet,
    required double totalGross,
    String notes = '',
    String engineerEmail = defaultEngineerEmail,
  }) async {
    final submissionId = 'fp-$jobId';
    if (!enableFirestoreWrites) {
      Log('[TEST MODE: Firebase writes disabled] submitFpEstimate for $jobId ($submissionId, Gross: £$totalGross)', name: 'PillarClient');
      return true;
    }

    try {
      final batch = _db.batch();

      final fpDoc = _db.collection(colFpSubmissions).doc(submissionId);
      batch.set(fpDoc, {
        'job_id': jobId,
        'status': 'SUBMITTED',
        'origin': 'NAV_APP',
        'line_items': lineItems,
        'total_net': totalNet,
        'total_gross': totalGross,
        'notes': notes,
        'engineer_email': engineerEmail,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final jobDoc = _db.collection(colEngineerJobs).doc(jobId);
      batch.set(jobDoc, {
        'fp_submission_id': submissionId,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      return true;
    } catch (e, st) {
      Log('submitFpEstimate error: $e\n$st', name: 'PillarClient');
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Customer Enquiry Leads (`enquiry_runtime.js` parity)
  // ---------------------------------------------------------------------------

  static Future<bool> raiseEnquiry({
    required String category, // "PPM_INTEREST" | "PM_INTEREST" | "REACTIVE_ATTENDANCE" | "REFERRAL"
    required String description,
    required Map<String, dynamic> details,
    String? jobId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? postcode,
    String engineerEmail = defaultEngineerEmail,
  }) async {
    if (!enableFirestoreWrites) {
      Log('[TEST MODE: Firebase writes disabled] raiseEnquiry category: $category for job: $jobId', name: 'PillarClient');
      return true;
    }

    try {
      final enquiryRef = _db.collection(colCustomerEnquiries).doc();
      final payload = <String, dynamic>{
        'id': enquiryRef.id,
        'category': category,
        'origin': 'NAV_APP',
        'status': 'NEW',
        'work_order_id': jobId ?? '',
        'engineer_email': engineerEmail,
        'description': description,
        'customer_name': customerName ?? '',
        'customer_phone': customerPhone ?? '',
        'customer_email': customerEmail ?? '',
        'postcode': postcode ?? '',
        'details': details,
        'created_at': FieldValue.serverTimestamp(),
      };

      await enquiryRef.set(payload);
      return true;
    } catch (e, st) {
      Log('raiseEnquiry error: $e\n$st', name: 'PillarClient');
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Local State, Draft Answers & Furthest Step Progress Persistence
  // ---------------------------------------------------------------------------

  static Future<void> saveLocalStatus(String jobId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pillar_job_status_$jobId', status);
  }

  static Future<String?> getLocalStatus(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pillar_job_status_$jobId');
  }

  static Future<void> saveFormAnswers(String jobId, Map<String, dynamic> answers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pillar_form_answers_$jobId', jsonEncode(answers));
  }

  static Future<Map<String, dynamic>> getFormAnswers(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('pillar_form_answers_$jobId');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  static Future<void> clearLocalAnswers(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pillar_form_answers_$jobId');
  }

  /// Progress tracking (`navigator.job.progress`) for resuming directly to furthest form step
  static Future<void> saveJobProgress(String jobId, int stepIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('navigator.job.progress.$jobId') ?? 1;
    if (stepIndex > current) {
      await prefs.setInt('navigator.job.progress.$jobId', stepIndex);
    }
  }

  static Future<int> getJobProgress(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('navigator.job.progress.$jobId') ?? 1;
  }
}
