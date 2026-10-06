import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/models/multiple_fixed_price_submit_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MultipleFixedPriceSubmitPayload', () {
    test('chosenRateFromLabourLevel maps Rate 1/2/3', () {
      expect(
        MultipleFixedPriceJobPayload.chosenRateFromLabourLevel('Rate 1'),
        1,
      );
      expect(
        MultipleFixedPriceJobPayload.chosenRateFromLabourLevel('Rate 2'),
        2,
      );
      expect(
        MultipleFixedPriceJobPayload.chosenRateFromLabourLevel('Rate 3'),
        3,
      );
      expect(
        MultipleFixedPriceJobPayload.chosenRateFromLabourLevel('Level 1'),
        1,
      );
    });

    test('toSubmitJson matches dry-run contract', () {
      const rates = FixedPriceEstimateRates(
        operativeSharePct: 40.0,
        zonedRates: FixedPriceZonedRates(zone1: 80, zone2: 90, zone3: 100),
      );
      final payload = MultipleFixedPriceSubmitPayload(
        sourceWorkOrderId: '0WOTl000009kpf3OAA',
        userId: '0054G00000BaJZHQA3',
        customerDecision: 'send',
        jobs: [
          MultipleFixedPriceJobPayload(
            workTypeId: '08q4G0000004CQ9QAM',
            scopeOfWorks: 'Trade 1 - dry run only.',
            durationHours: 2.5,
            chosenRate: 1,
            ulezChargeApplicable: true,
            useAsMainJobType: false,
            rates: rates,
            breakdown: const MultipleFixedPriceJobBreakdown(
              collectionFee: 0,
              ulez: 12.5,
              materialsWithMarkup: 0,
              adminFeePercentage: 2.5,
              materialsMarkupBandPercent: 0,
            ),
          ),
          MultipleFixedPriceJobPayload(
            workTypeId: '08q4G0000004CQAQA2',
            scopeOfWorks: 'Trade 2 - dry run only.',
            durationHours: 1.5,
            chosenRate: 1,
            ulezChargeApplicable: false,
            useAsMainJobType: true,
            rates: rates,
            breakdown: const MultipleFixedPriceJobBreakdown(
              collectionFee: 0,
              ulez: 0,
              materialsWithMarkup: 0,
              adminFeePercentage: 2.5,
              materialsMarkupBandPercent: 0,
            ),
          ),
        ],
      );

      final json = payload.toSubmitJson();
      expect(json['source_work_order_id'], '0WOTl000009kpf3OAA');
      expect(json['user_id'], '0054G00000BaJZHQA3');
      expect(json['customer_decision'], 'send');
      final jobs = json['jobs'] as List;
      expect(jobs.length, 2);
      expect(jobs[0]['use_as_main_job_type'], isFalse);
      expect(jobs[0]['ulez_charge_applicable'], isTrue);
      expect(jobs[0]['breakdown']['ulez'], 12.5);
      expect(jobs[0]['rates']['zoned_rates'], {
        '1': 80.0,
        '2': 90.0,
        '3': 100.0,
      });
      expect(jobs[1]['use_as_main_job_type'], isTrue);
      expect(jobs[1]['work_type_id'], '08q4G0000004CQAQA2');
    });

    test('validate requires source, user, and at least one job', () {
      const payload = MultipleFixedPriceSubmitPayload(
        sourceWorkOrderId: '',
        userId: '',
        customerDecision: '',
        jobs: [],
      );
      final errors = payload.validate();
      expect(errors, contains('Source work order is required.'));
      expect(
        errors,
        contains('User id is required to raise this work order.'),
      );
      expect(errors, contains('At least one job is required.'));
      expect(errors, contains('Customer decision is required.'));
    });

    test('validate rejects more than maxJobs (6)', () {
      const rates = FixedPriceEstimateRates(
        operativeSharePct: 40.0,
        zonedRates: FixedPriceZonedRates(zone1: 80, zone2: 90, zone3: 100),
      );
      MultipleFixedPriceJobPayload job(int i) => MultipleFixedPriceJobPayload(
        workTypeId: '08q4G0000004CQ9QAM',
        scopeOfWorks: 'Job $i',
        durationHours: 1.0,
        chosenRate: 1,
        ulezChargeApplicable: false,
        useAsMainJobType: i == 7,
        rates: rates,
        breakdown: const MultipleFixedPriceJobBreakdown(
          collectionFee: 0,
          ulez: 0,
          materialsWithMarkup: 0,
          adminFeePercentage: 0,
          materialsMarkupBandPercent: 0,
        ),
      );

      final payload = MultipleFixedPriceSubmitPayload(
        sourceWorkOrderId: '0WOTl000009kpf3OAA',
        userId: '0054G00000BaJZHQA3',
        customerDecision: 'send',
        jobs: [for (var i = 1; i <= 7; i++) job(i)],
      );

      expect(MultipleFixedPriceSubmitPayload.maxJobs, 6);
      expect(
        payload.validate(),
        contains('A maximum of 6 fixed price jobs can be submitted at once.'),
      );
    });

    test(
      'toSubmitJson includes rejection_reason when customer_decision is reject',
      () {
        const rates = FixedPriceEstimateRates(
          operativeSharePct: 40.0,
          zonedRates: FixedPriceZonedRates(zone1: 80, zone2: 90, zone3: 100),
        );
        final payload = MultipleFixedPriceSubmitPayload(
          sourceWorkOrderId: '0WOTl000009kpf3OAA',
          userId: '0054G00000BaJZHQA3',
          customerDecision: 'reject',
          rejectionReason: 'Customer declined the fixed price estimate.',
          jobs: [
            MultipleFixedPriceJobPayload(
              workTypeId: '08q4G0000004CQ9QAM',
              scopeOfWorks: 'Rejected job.',
              durationHours: 1.0,
              chosenRate: 1,
              ulezChargeApplicable: false,
              useAsMainJobType: true,
              rates: rates,
              breakdown: const MultipleFixedPriceJobBreakdown(
                collectionFee: 0,
                ulez: 0,
                materialsWithMarkup: 0,
                adminFeePercentage: 0,
                materialsMarkupBandPercent: 0,
              ),
            ),
          ],
        );

        final json = payload.toSubmitJson();
        expect(json['customer_decision'], 'reject');
        expect(
          json['rejection_reason'],
          'Customer declined the fixed price estimate.',
        );
        expect(payload.validate(), isEmpty);
      },
    );

    test('validate requires rejection_reason when decision is reject', () {
      const rates = FixedPriceEstimateRates(
        operativeSharePct: 40.0,
        zonedRates: FixedPriceZonedRates(zone1: 80, zone2: 90, zone3: 100),
      );
      final payload = MultipleFixedPriceSubmitPayload(
        sourceWorkOrderId: '0WOTl000009kpf3OAA',
        userId: '0054G00000BaJZHQA3',
        customerDecision: 'reject',
        jobs: [
          MultipleFixedPriceJobPayload(
            workTypeId: '08q4G0000004CQ9QAM',
            scopeOfWorks: 'Rejected job.',
            durationHours: 1.0,
            chosenRate: 1,
            ulezChargeApplicable: false,
            useAsMainJobType: true,
            rates: rates,
            breakdown: const MultipleFixedPriceJobBreakdown(
              collectionFee: 0,
              ulez: 0,
              materialsWithMarkup: 0,
              adminFeePercentage: 0,
              materialsMarkupBandPercent: 0,
            ),
          ),
        ],
      );

      expect(
        payload.validate(),
        contains('Rejection reason is required when the estimate is rejected.'),
      );
    });
  });
}
