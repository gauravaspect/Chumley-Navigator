import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/screens/job_details/repo/fixed_price_repository.dart';

import 'fixed_price_state.dart';

class FixedPriceCubit extends Cubit<FixedPriceState> {
  FixedPriceCubit(this._repository) : super(const FixedPriceInitial());

  final FixedPriceRepository _repository;

  Future<void> loadTrades({bool forceRefresh = false}) async {
    List<FixedPriceModel> cached = [];
    if (!forceRefresh) {
      cached = await _repository.readCachedFixedPriceTrades();
      if (cached.isNotEmpty) {
        emit(FixedPriceLoaded(trades: cached));
      }
    }

    if (state is! FixedPriceLoaded) {
      emit(FixedPriceLoading(cachedTrades: cached));
    }

    try {
      final trades = await _repository.fetchFixedPriceTrades();
      emit(FixedPriceLoaded(trades: trades));
    } catch (error) {
      emit(
        FixedPriceError(
          message: error.toString(),
          cachedTrades: cached.isNotEmpty ? cached : state.trades,
        ),
      );
    }
  }

  Future<void> loadCategories(String tradeId) async {
    final currentState = state;
    if (currentState is! FixedPriceLoaded) return;

    emit(currentState.copyWith(loadingCategories: true, categoryError: null));

    try {
      final categories = await _repository.fetchFixedPriceCategories(tradeId);
      final latestState = state;
      if (latestState is FixedPriceLoaded) {
        emit(
          latestState.copyWith(
            categories: categories,
            loadingCategories: false,
          ),
        );
      }
    } catch (error) {
      final latestState = state;
      if (latestState is FixedPriceLoaded) {
        emit(
          latestState.copyWith(
            loadingCategories: false,
            categoryError: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> loadWorkTypes(String groupId) async {
    final currentState = state;
    if (currentState is! FixedPriceLoaded) return;

    emit(currentState.copyWith(loadingWorkTypes: true, workTypeError: null));

    try {
      final workTypes = await _repository.fetchFixedPriceWorkTypes(groupId);
      final latestState = state;
      if (latestState is FixedPriceLoaded) {
        emit(
          latestState.copyWith(workTypes: workTypes, loadingWorkTypes: false),
        );
      }
    } catch (error) {
      final latestState = state;
      if (latestState is FixedPriceLoaded) {
        emit(
          latestState.copyWith(
            loadingWorkTypes: false,
            workTypeError: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> submitWorkOrder({
    required FixedPriceSubmitPayload payload,
    required FixedPriceSalesforceContext context,
    bool dryRun = false,
  }) async {
    final currentState = state;
    if (currentState is! FixedPriceLoaded) return;

    emit(currentState.copyWith(isSubmitting: true, submitError: null));

    try {
      await _repository.submitFixedPriceWorkOrder(
        payload: payload,
        context: context,
        dryRun: dryRun,
      );
      final latestState = state;
      if (latestState is FixedPriceLoaded) {
        emit(latestState.copyWith(isSubmitting: false, submitError: null));
      }
    } catch (error) {
      final latestState = state;
      if (latestState is FixedPriceLoaded) {
        emit(
          latestState.copyWith(
            isSubmitting: false,
            submitError: error.toString(),
          ),
        );
      }
      rethrow;
    }
  }
}
