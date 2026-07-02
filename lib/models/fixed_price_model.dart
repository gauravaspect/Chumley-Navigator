import 'package:equatable/equatable.dart';

class FixedPriceTradesResponse extends Equatable {
  const FixedPriceTradesResponse({this.trades = const []});

  final List<FixedPriceModel> trades;

  factory FixedPriceTradesResponse.fromJson(Map<String, dynamic> json) {
    final rawTrades = json['trades'];

    final trades = rawTrades is List
        ? rawTrades
              .whereType<Map>()
              .map(
                (item) =>
                    FixedPriceModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : <FixedPriceModel>[];

    return FixedPriceTradesResponse(trades: trades);
  }

  Map<String, dynamic> toJson() => {
    'trades': trades.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [trades];
}

class FixedPriceModel extends Equatable {
  const FixedPriceModel({this.id = '', this.name = ''});

  final String id;
  final String name;

  factory FixedPriceModel.fromJson(Map<String, dynamic> json) {
    return FixedPriceModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class FixedPriceCategoriesResponse extends Equatable {
  const FixedPriceCategoriesResponse({this.categories = const []});

  final List<FixedPriceCategoryModel> categories;

  factory FixedPriceCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];

    final categories = rawCategories is List
        ? rawCategories
              .whereType<Map>()
              .map(
                (item) =>
                    FixedPriceCategoryModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : <FixedPriceCategoryModel>[];

    return FixedPriceCategoriesResponse(categories: categories);
  }

  Map<String, dynamic> toJson() => {
    'categories': categories.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [categories];
}

class FixedPriceCategoryModel extends Equatable {
  const FixedPriceCategoryModel({this.id = '', this.name = ''});

  final String id;
  final String name;

  factory FixedPriceCategoryModel.fromJson(Map<String, dynamic> json) {
    return FixedPriceCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class FixedPriceWorkTypesResponse extends Equatable {
  const FixedPriceWorkTypesResponse({this.workTypes = const []});

  final List<FixedPriceWorkTypeModel> workTypes;

  factory FixedPriceWorkTypesResponse.fromJson(Map<String, dynamic> json) {
    final rawWorkTypes = json['work_types'] ?? json['workTypes'] ?? json['data'];

    final list = rawWorkTypes is List
        ? rawWorkTypes
              .whereType<Map>()
              .map(
                (item) =>
                    FixedPriceWorkTypeModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : <FixedPriceWorkTypeModel>[];

    return FixedPriceWorkTypesResponse(workTypes: list);
  }

  Map<String, dynamic> toJson() => {
    'work_types': workTypes.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [workTypes];
}

class FixedPriceWorkTypeModel extends Equatable {
  const FixedPriceWorkTypeModel({this.id = '', this.name = ''});

  final String id;
  final String name;

  factory FixedPriceWorkTypeModel.fromJson(Map<String, dynamic> json) {
    return FixedPriceWorkTypeModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}
