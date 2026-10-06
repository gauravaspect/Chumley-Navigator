import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scope = '''Assessment and Identification
The process begins with a thorough inspection of the property to locate issues related to leaking pipe in the category pipe repair (plumbing).

Containment
To prevent the spread of dust, debris, or water damage, containment measures will be put in place.

Removal & Repair
Faulty components, blocks, or damaged pipes will be removed or repaired in accordance with safety standards.

Cleaning & Sanitizing
Cleaning and sanitizing the work area post-repair.

Treatment & Verification
The repaired system or install will be tested to ensure functionality.

Ventilation and Moisture Control
Ensuring proper ventilation and moisture control is in place where necessary.''';

  const additionalScope2 = 'Replace 1.5m copper piping under kitchen sink.';

  final salesforceContext = const FixedPriceSalesforceContext(
    siteId: '0018d000000site123',
    accountId: '0018d000000acct123',
    contactId: '0038d000000cont123',
    resolvedServiceFeePct: 10.0,
    resolvedMarkupPct: 15.0,
    operativeSharePct: 40.0,
  );

  FixedPriceSubmitPayload buildSamplePayload() {
    return FixedPriceSubmitPayload.fromWizard(
      workOrderId: 'WO-98765432',
      sourceWorkOrderId: '0WO8d000000abc1234',
      customerEmail: 'customer@example.com',
      earliestRequestedDate: '2026-06-29',
      tradeId: 'trade_plumbing_01',
      categoryId: 'cat_pipe_repair_02',
      workTypeId: '08q8d000000xyz1234',
      scopeOfWork: scope,
      additionalScope2: additionalScope2,
      collectionFeeApplicable: true,
      listPriceServiceCode: 'standard',
      operativeMaterialsCost: 35.50,
      operativeMaterialsDescription:
          '2x 15mm copper couplings, 1.5m copper pipe',
      chargeDrainagePatches: false,
      aspectMaterialsCost: 15.00,
      aspectMaterialsDescription: 'Solder, flux, jointing compound',
      ulezChargeApplicable: true,
      labourRateLevel: 'Rate 1',
      customerConfirmationChoice: 'Send Estimate to Customer',
      durationHours: 2.0,
    );
  }

  group('FixedPriceSubmitPayload', () {
    test('toJson matches documented client payload shape', () {
      final payload = buildSamplePayload();
      final json = payload.toJson();

      expect(json['work_order_id'], 'WO-98765432');
      expect(json['source_work_order_id'], '0WO8d000000abc1234');
      expect(json['work_type_id'], '08q8d000000xyz1234');
      expect(json['duration_hours'], 2.0);
      expect(json['collection_fee_applicable'], isTrue);
      expect(json['operative_materials'], {
        'cost': 35.50,
        'description': '2x 15mm copper couplings, 1.5m copper pipe',
      });
      expect(json['aspect_materials'], {
        'cost': 15.00,
        'description': 'Solder, flux, jointing compound',
      });
      expect(json['pricing_summary'], isA<Map<String, dynamic>>());
    });

    test('chosenRateFromLabourLevel maps Rate 1/2/3', () {
      expect(FixedPriceSubmitPayload.chosenRateFromLabourLevel('Rate 1'), 1);
      expect(FixedPriceSubmitPayload.chosenRateFromLabourLevel('Rate 2'), 2);
      expect(FixedPriceSubmitPayload.chosenRateFromLabourLevel('Rate 3'), 3);
    });

    test(
      'toSubmitJson includes materials_*_with_markup from resolved markup pct',
      () {
        final payload = FixedPriceSubmitPayload.fromWizard(
          workOrderId: '0WOTl000009tYwjOAE',
          sourceWorkOrderId: '0WOTl000009tYwjOAE',
          customerEmail: 'customer@example.com',
          earliestRequestedDate: '2026-10-06',
          tradeId: 't',
          categoryId: 'c',
          workTypeId: '08q4G000000YVHhQAO',
          scopeOfWork: 'line1\nline2\nline3\nline4\nline5',
          collectionFeeApplicable: false,
          listPriceServiceCode: 'none',
          operativeMaterialsCost: 200.0,
          chargeDrainagePatches: false,
          aspectMaterialsCost: 210.0,
          ulezChargeApplicable: false,
          labourRateLevel: 'Rate 2',
          customerConfirmationChoice: 'Send Estimate to Customer',
          durationHours: 12.0,
        );

        final json = payload.toSubmitJson(
          context: const FixedPriceSalesforceContext(
            siteId: 'a1qTl000006xWWfIAM',
            accountId: '001Tl00000mbQPjIAM',
            contactId: '003Tl00000q9a4kIAA',
            resolvedServiceFeePct: 0.0,
            resolvedMarkupPct: 15.0,
            operativeSharePct: 40.0,
          ),
        );

        expect(json['materials_operative'], 200.0);
        expect(json['materials_aspect'], 210.0);
        // cost × (1 + 15/100)
        expect(json['materials_operative_with_markup'], 230.0);
        expect(json['materials_aspect_with_markup'], 241.5);
      },
    );

    test('toSubmitJson matches dry-run contract with chosen_rate', () {
      final payload = FixedPriceSubmitPayload.fromWizard(
        workOrderId: '0WOTl000009kpf3OAA',
        sourceWorkOrderId: '0WOTl000009kpf3OAA',
        customerEmail: 'customer@example.com',
        earliestRequestedDate: '2026-10-06',
        tradeId: 't',
        categoryId: 'c',
        workTypeId: '08q4G0000004CQ9QAM',
        scopeOfWork: 'Test - dry run only.\nline2\nline3\nline4\nline5',
        collectionFeeApplicable: false,
        listPriceServiceCode: 'none',
        operativeMaterialsCost: 0,
        chargeDrainagePatches: false,
        aspectMaterialsCost: 0,
        ulezChargeApplicable: false,
        labourRateLevel: 'Rate 1',
        customerConfirmationChoice: 'Send Estimate to Customer',
        durationHours: 2.5,
      );

      final json = payload.toSubmitJson(
        context: const FixedPriceSalesforceContext(
          siteId: 'a1qTl000006yd33IAA',
          accountId: '001Tl00000mhh9ZIAQ',
          contactId: '003Tl00000qHGj7IAG',
          resolvedServiceFeePct: 2.5,
          resolvedMarkupPct: 0,
          operativeSharePct: 40.0,
        ),
      );

      expect(json['source_work_order_id'], '0WOTl000009kpf3OAA');
      expect(json['work_type_id'], '08q4G0000004CQ9QAM');
      expect(json['duration_hours'], 2.5);
      expect(json['chosen_rate'], 1);
      expect(json['drainage_patches'], 0.0);
      expect(json['materials_operative'], 0.0);
      expect(json['materials_aspect'], 0.0);
      expect(json['customer_decision'], 'send');
      expect(json['scope_of_works'], contains('Test - dry run only.'));

      final estimate = json['estimate'] as Map<String, dynamic>;
      final context = estimate['context'] as Map<String, dynamic>;
      final rates = estimate['rates'] as Map<String, dynamic>;
      final breakdown = estimate['breakdown'] as Map<String, dynamic>;

      expect(context['site_id'], 'a1qTl000006yd33IAA');
      expect(context['resolved_service_fee_pct'], 2.5);
      expect(rates['operative_share_pct'], 40.0);
      expect(rates['zoned_rates'], {'1': 80.0, '2': 90.0, '3': 100.0});
      // labour = 2.5 × 80; service_fee = 200 × 2.5%
      expect(breakdown['labour'], 200.0);
      expect(breakdown['service_fee'], 5.0);
      expect(breakdown['subtotal'], 205.0);
      expect(breakdown['vat'], 41.0);
      expect(breakdown['total'], 246.0);
      expect(breakdown['deposit'], 123.0);
    });

    test('toSalesforceJson matches validated Salesforce sample', () {
      final payload = buildSamplePayload();
      const zeroFeeContext = FixedPriceSalesforceContext(
        siteId: '0018d000000site123',
        accountId: '0018d000000acct123',
        contactId: '0038d000000cont123',
        resolvedServiceFeePct: 0.0,
        resolvedMarkupPct: 0.0,
        operativeSharePct: 40.0,
      );
      final json = payload.toSalesforceJson(context: zeroFeeContext);

      expect(json['source_work_order_id'], '0WO8d000000abc1234');
      expect(json['work_type_id'], '08q8d000000xyz1234');
      expect(json['duration_hours'], 2.0);
      expect(json['chosen_rate'], 1);
      expect(json['drainage_patches'], 0.0);
      expect(json['materials_operative'], 35.50);
      expect(json['materials_aspect'], 15.00);
      // API requires explicit with_markup when materials costs are set (no silent fallback).
      expect(json['materials_operative_with_markup'], 35.50);
      expect(json['materials_aspect_with_markup'], 15.00);
      expect(json['customer_decision'], 'send');
      expect(json['scope_of_works'], contains(additionalScope2));

      final estimate = json['estimate'] as Map<String, dynamic>;
      final context = estimate['context'] as Map<String, dynamic>;
      final rates = estimate['rates'] as Map<String, dynamic>;
      final breakdown = estimate['breakdown'] as Map<String, dynamic>;

      expect(context['site_id'], '0018d000000site123');
      expect(context['account_id'], '0018d000000acct123');
      expect(context['contact_id'], '0038d000000cont123');
      expect(context['resolved_service_fee_pct'], 0.0);
      expect(context['resolved_markup_pct'], 0.0);
      expect(rates['operative_share_pct'], 40.0);
      expect(rates['zoned_rates'], {'1': 80.0, '2': 90.0, '3': 100.0});
      expect(breakdown['list_price'], 80.0);
      expect(breakdown['collection_fee'], 20.0);
      expect(breakdown['ulez'], 12.5);
      // labour = duration_hours (2.0) × Rate 1 zoned rate (80)
      expect(breakdown['labour'], 160.0);
      expect(breakdown['materials'], 50.5);
      expect(breakdown['service_fee'], 0.0);
      expect(breakdown['subtotal'], 323.0);
      expect(breakdown['vat'], 64.6);
      expect(breakdown['total'], 387.6);
      expect(breakdown['deposit'], 193.8);
    });

    test('validate requires duration and work order context fields', () {
      final payload = FixedPriceSubmitPayload.fromWizard(
        workOrderId: 'WO-1',
        customerEmail: 'a@b.com',
        earliestRequestedDate: '2026-06-29',
        tradeId: 't',
        categoryId: 'c',
        workTypeId: 'w',
        scopeOfWork: 'line1\nline2\nline3\nline4\nline5',
        collectionFeeApplicable: false,
        listPriceServiceCode: 'none',
        operativeMaterialsCost: 0,
        chargeDrainagePatches: false,
        aspectMaterialsCost: 0,
        ulezChargeApplicable: false,
        labourRateLevel: 'Rate 1',
        customerConfirmationChoice: 'Send Estimate to Customer',
      );

      final errors = payload.validate(salesforceContext: salesforceContext);
      expect(errors, contains('Duration hours must be greater than 0.'));
    });

    test('maps reject confirmation to Salesforce customer_decision', () {
      final payload = FixedPriceSubmitPayload.fromWizard(
        workOrderId: 'WO-1',
        customerEmail: 'a@b.com',
        earliestRequestedDate: '2026-06-29',
        tradeId: 't',
        categoryId: 'c',
        workTypeId: 'w',
        scopeOfWork: 'line1\nline2\nline3\nline4\nline5',
        collectionFeeApplicable: false,
        listPriceServiceCode: 'none',
        operativeMaterialsCost: 0,
        chargeDrainagePatches: false,
        aspectMaterialsCost: 0,
        ulezChargeApplicable: false,
        labourRateLevel: 'Rate 1',
        customerConfirmationChoice: 'Reject',
        durationHours: 1.5,
      );

      final json = payload.toSalesforceJson(context: salesforceContext);

      expect(json['customer_decision'], 'reject');
      expect(json['rejection_reason'], isNotEmpty);
      expect(json['drainage_patches'], 0.0);
    });
    test('toSalesforceJson labour uses duration_hours × zoned rate', () {
      final payload = FixedPriceSubmitPayload.fromWizard(
        workOrderId: '0WO4G0000005SG6WAM',
        sourceWorkOrderId: '0WO4G0000005SG6WAM',
        customerEmail: 'customer@example.com',
        earliestRequestedDate: '2026-06-29',
        tradeId: 't',
        categoryId: 'c',
        workTypeId: '08q4G0000004CQ9QAM',
        scopeOfWork: 'line1\nline2\nline3\nline4\nline5',
        collectionFeeApplicable: false,
        listPriceServiceCode: 'none',
        operativeMaterialsCost: 0,
        chargeDrainagePatches: false,
        aspectMaterialsCost: 0,
        ulezChargeApplicable: false,
        labourRateLevel: 'Rate 1',
        customerConfirmationChoice: 'Send Estimate to Customer',
        durationHours: 2.83,
      );

      final json = payload.toSubmitJson(
        context: const FixedPriceSalesforceContext(
          siteId: 'a1q4G000006VbmLQAS',
          accountId: '0014G00002jTnJuQAK',
          contactId: '0034G00002s0ZqvQAE',
          resolvedServiceFeePct: 0.0,
          resolvedMarkupPct: 0.0,
          operativeSharePct: 40.0,
        ),
      );

      expect(json['source_work_order_id'], '0WO4G0000005SG6WAM');
      expect(json['duration_hours'], 2.83);
      expect(json['chosen_rate'], 1);
      expect(json['drainage_patches'], 0.0);
      expect(json['materials_operative'], 0.0);
      expect(json['materials_aspect'], 0.0);
      expect(json['customer_decision'], 'send');

      final breakdown =
          (json['estimate'] as Map)['breakdown'] as Map<String, dynamic>;
      // 2.83 × 80 = 226.4 (matches API sample labour)
      expect(breakdown['labour'], closeTo(226.4, 0.001));
      expect(breakdown['materials'], 0.0);
      expect(breakdown['list_price'], 0.0);
      expect(breakdown['collection_fee'], 0.0);
      expect(breakdown['ulez'], 0.0);
      expect(breakdown['service_fee'], 0.0);
      expect(breakdown['subtotal'], closeTo(226.4, 0.001));
      expect(breakdown['vat'], closeTo(45.28, 0.001));
      expect(breakdown['total'], closeTo(271.68, 0.001));
      expect(breakdown['deposit'], closeTo(135.84, 0.001));
    });
  });
}
