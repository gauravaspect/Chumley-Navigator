import 'dart:io';

import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/models/vcr_submit_payload.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Production Business Flow E2E Scenarios', () {
    test(
      'Scenario A — Reactive Job State Journey Transition & Step Clamping',
      () {
        // 1. Initial Dispatched state
        final dispatchedTarget = openJob(
          status: 'Dispatched',
          kind: FormKind.gas,
          furthestStep: 0,
        );
        expect(dispatchedTarget.phase, ResumePhase.dispatched);
        expect(dispatchedTarget.screenId, '2205-3809');

        // 2. Transition to In Transit
        final transitTarget = openJob(
          status: 'In Transit',
          kind: FormKind.gas,
          furthestStep: 0,
        );
        expect(transitTarget.phase, ResumePhase.transit);
        expect(transitTarget.screenId, '2205-3953');

        // 3. Arrive On Site with progression through 12 form steps
        final onSiteStep0 = openJob(
          status: 'On Site',
          kind: FormKind.gas,
          furthestStep: 0,
        );
        expect(onSiteStep0.phase, ResumePhase.form);
        expect(onSiteStep0.formStep, 0);
        expect(onSiteStep0.screenId, '2196-3397');

        final onSiteStep5 = openJob(
          status: 'On Site',
          kind: FormKind.gas,
          furthestStep: 5,
        );
        expect(onSiteStep5.phase, ResumePhase.form);
        expect(onSiteStep5.formStep, 5);
        expect(onSiteStep5.screenId, '2196-4116');

        // 4. Overflows clamped safely to last step
        final onSiteStepOverflow = openJob(
          status: 'On Site',
          kind: FormKind.gas,
          furthestStep: 99,
        );
        expect(onSiteStepOverflow.phase, ResumePhase.form);
        expect(onSiteStepOverflow.formStep, 11);
        expect(onSiteStepOverflow.screenId, '2196-5152');

        // 5. Job Closure & Complete state
        final completeTarget = openJob(
          status: 'Visit Complete',
          kind: FormKind.gas,
          furthestStep: 11,
        );
        expect(completeTarget.phase, ResumePhase.complete);
        expect(completeTarget.screenId, '2205-4099');
      },
    );

    test('Scenario B — Fixed-Price Job Quote & Payload Assembly', () {
      final payload = FixedPriceSubmitPayload.fromWizard(
        workOrderId: 'WO-10029',
        customerEmail: 'customer@example.com',
        earliestRequestedDate: '2026-09-30',
        tradeId: 'PLUMBING',
        categoryId: 'GENERAL_PLUMBING',
        workTypeId: 'TAP_REPLACEMENT',
        scopeOfWork:
            'Line 1: Arrive on site.\nLine 2: Inspect tap.\nLine 3: Replace valve.\nLine 4: Connect cold line.\nLine 5: Test flow and leaks.',
        collectionFeeApplicable: false,
        listPriceServiceCode: 'standard',
        operativeMaterialsCost: 45.0,
        chargeDrainagePatches: false,
        aspectMaterialsCost: 0.0,
        ulezChargeApplicable: false,
        labourRateLevel: 'Rate 1',
        durationHours: 2.0,
        customerConfirmationChoice: 'Customer Agrees - Send Estimate',
      );

      final errors = payload.validate();
      expect(errors, isEmpty);

      const context = FixedPriceSalesforceContext(
        siteId: 'SITE-01',
        accountId: 'ACC-01',
        contactId: 'CON-01',
      );

      final salesforceJson = payload.toSalesforceJson(context: context);
      expect(salesforceJson['source_work_order_id'], 'WO-10029');
      expect(salesforceJson['work_type_id'], 'TAP_REPLACEMENT');
      expect(salesforceJson['customer_decision'], 'send');
      expect(salesforceJson['materials_operative'], 45.0);
    });

    test('Scenario C — Compliance Form Multi-Step Draft Persistence', () async {
      SharedPreferences.setMockInitialValues({});
      final store = FormDraftStore();

      const jobId = 'SA-99042';
      final draftAnswers = {
        'risk_assessment_completed': true,
        'water_temp_celsius': '58.5',
        'outlet_location': 'Main Boiler Room',
      };
      final draftPhotos = {
        'boiler_plate':
            'https://chumleystorage.blob.core.windows.net/photos/boiler_plate.jpg',
      };

      // 1. Save multi-step answers and furthest step
      await store.saveDraft(
        jobId: jobId,
        step: 4,
        answers: draftAnswers,
        photos: draftPhotos,
      );

      // 2. Verify restoration
      final restoredStep = await store.loadFurthestStep(jobId);
      final restoredAnswers = await store.loadAnswers(jobId);
      final restoredPhotos = await store.loadPhotos(jobId);

      expect(restoredStep, 4);
      expect(restoredAnswers['risk_assessment_completed'], true);
      expect(restoredAnswers['water_temp_celsius'], '58.5');
      expect(restoredPhotos['boiler_plate'], contains('boiler_plate.jpg'));

      // 3. Verify dismiss tracking
      await store.saveFormsDismissed(jobId, true);
      final dismissed = await store.loadFormsDismissed(jobId);
      expect(dismissed, isTrue);
    });

    test('Scenario D — Vehicle Inspection Checklist & Payload Contract', () {
      final file1 = VcrSubmitFile(
        slotId: 'front_view',
        file: File('/tmp/vcr1.jpg'),
      );
      final file2 = VcrSubmitFile(
        slotId: 'dashboard_mileage',
        file: File('/tmp/vcr2.jpg'),
      );

      final vcrPayload = VcrSubmitPayload(
        vehicleId: 'VAN-LDN-04',
        description:
            'Daily morning pre-drive check completed. All tyres and fluids checked.',
        internalNotes: 'Minor scratch on rear left bumper noted.',
        inspectionResult: 'PASS',
        files: [file1, file2],
      );

      expect(vcrPayload.vehicleId, 'VAN-LDN-04');
      expect(vcrPayload.inspectionResult, 'PASS');
      expect(vcrPayload.files.length, 2);
      expect(vcrPayload.files[0].slotId, 'front_view');
      expect(vcrPayload.files[1].slotId, 'dashboard_mileage');
    });
  });
}
