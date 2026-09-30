import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:equatable/equatable.dart';

sealed class FixedPriceState extends Equatable {
  const FixedPriceState();

  @override
  List<Object?> get props => [];
}

class FixedPriceInitial extends FixedPriceState {
  const FixedPriceInitial();
}

class FixedPriceLoading extends FixedPriceState {
  const FixedPriceLoading({this.cachedTrades = const []});

  final List<FixedPriceModel> cachedTrades;

  @override
  List<Object?> get props => [cachedTrades];
}

class FixedPriceLoaded extends FixedPriceState {
  const FixedPriceLoaded({
    required this.trades,
    this.categories = const [],
    this.loadingCategories = false,
    this.categoryError,
    this.workTypes = const [],
    this.loadingWorkTypes = false,
    this.workTypeError,
    this.isSubmitting = false,
    this.submitError,
  });

  final List<FixedPriceModel> trades;
  final List<FixedPriceCategoryModel> categories;
  final bool loadingCategories;
  final String? categoryError;
  final List<FixedPriceWorkTypeModel> workTypes;
  final bool loadingWorkTypes;
  final String? workTypeError;
  final bool isSubmitting;
  final String? submitError;

  FixedPriceLoaded copyWith({
    List<FixedPriceModel>? trades,
    List<FixedPriceCategoryModel>? categories,
    bool? loadingCategories,
    String? categoryError,
    List<FixedPriceWorkTypeModel>? workTypes,
    bool? loadingWorkTypes,
    String? workTypeError,
    bool? isSubmitting,
    String? submitError,
  }) {
    return FixedPriceLoaded(
      trades: trades ?? this.trades,
      categories: categories ?? this.categories,
      loadingCategories: loadingCategories ?? this.loadingCategories,
      categoryError: categoryError ?? this.categoryError,
      workTypes: workTypes ?? this.workTypes,
      loadingWorkTypes: loadingWorkTypes ?? this.loadingWorkTypes,
      workTypeError: workTypeError ?? this.workTypeError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    trades,
    categories,
    loadingCategories,
    categoryError,
    workTypes,
    loadingWorkTypes,
    workTypeError,
    isSubmitting,
    submitError,
  ];
}

class FixedPriceError extends FixedPriceState {
  const FixedPriceError({required this.message, this.cachedTrades = const []});

  final String message;
  final List<FixedPriceModel> cachedTrades;

  @override
  List<Object?> get props => [message, cachedTrades];
}

extension FixedPriceStateX on FixedPriceState {
  List<FixedPriceModel> get trades => switch (this) {
    FixedPriceLoaded(:final trades) => trades,
    FixedPriceLoading(:final cachedTrades) => cachedTrades,
    FixedPriceError(:final cachedTrades) => cachedTrades,
    _ => const [],
  };

  List<FixedPriceCategoryModel> get categories => switch (this) {
    FixedPriceLoaded(:final categories) => categories,
    _ => const [],
  };

  bool get loadingCategories => switch (this) {
    FixedPriceLoaded(:final loadingCategories) => loadingCategories,
    _ => false,
  };

  List<FixedPriceWorkTypeModel> get workTypes => switch (this) {
    FixedPriceLoaded(:final workTypes) => workTypes,
    _ => const [],
  };

  bool get loadingWorkTypes => switch (this) {
    FixedPriceLoaded(:final loadingWorkTypes) => loadingWorkTypes,
    _ => false,
  };

  bool get isSubmitting => switch (this) {
    FixedPriceLoaded(:final isSubmitting) => isSubmitting,
    _ => false,
  };
}
