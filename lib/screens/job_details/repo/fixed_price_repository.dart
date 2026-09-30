import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/screens/job_details/service/fixed_price_api_service.dart';

class FixedPriceRepository {
  final FixedPriceApiService _apiService;
  FixedPriceRepository(this._apiService);

  Future<List<FixedPriceModel>> readCachedFixedPriceTrades() async {
    final cached = await Prefs.getFixedPriceTrades();
    return cached?.trades ?? <FixedPriceModel>[];
  }

  Future<List<FixedPriceModel>> fetchFixedPriceTrades() async {
    try {
      final response = await _apiService.fetchFixedPriceTrades();
      await Prefs.saveFixedPriceTrades(
        FixedPriceTradesResponse(trades: response),
      );
      return response;
    } on FixedPriceApiException {
      final cached = await readCachedFixedPriceTrades();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<FixedPriceCategoryModel>> fetchFixedPriceCategories(
    String tradeId,
  ) async {
    return _apiService.fetchFixedPriceCategories(tradeId);
  }

  Future<List<FixedPriceWorkTypeModel>> fetchFixedPriceWorkTypes(
    String groupId,
  ) async {
    return _apiService.fetchFixedPriceWorkTypes(groupId);
  }

  Future<Map<String, dynamic>> submitFixedPriceWorkOrder({
    required FixedPriceSubmitPayload payload,
    required FixedPriceSalesforceContext context,
    bool dryRun = false,
  }) {
    return _apiService.submitFixedPriceWorkOrder(
      payload: payload,
      context: context,
      dryRun: dryRun,
    );
  }
}
