import 'package:flutter_test/flutter_test.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';

void main() {
  group('FixedPriceModel', () {
    test('fromJson sets properties correctly', () {
      final json = {
        'id': 'a2d4G000000ukoxQAA',
        'name': 'Access',
      };

      final model = FixedPriceModel.fromJson(json);

      expect(model.id, 'a2d4G000000ukoxQAA');
      expect(model.name, 'Access');
    });

    test('toJson serializes properties correctly', () {
      const model = FixedPriceModel(
        id: 'a2d4G000000ukoxQAA',
        name: 'Access',
      );

      final json = model.toJson();

      expect(json['id'], 'a2d4G000000ukoxQAA');
      expect(json['name'], 'Access');
    });

    test('supports value equality', () {
      expect(
        const FixedPriceModel(id: '1', name: 'Access'),
        equals(const FixedPriceModel(id: '1', name: 'Access')),
      );
    });
  });

  group('FixedPriceTradesResponse', () {
    test('fromJson sets trades correctly', () {
      final json = {
        'trades': [
          {
            'id': 'a2d4G000000ukoxQAA',
            'name': 'Access',
          },
          {
            'id': 'a2d4G000000ukp2QAA',
            'name': 'Air Con',
          }
        ]
      };

      final response = FixedPriceTradesResponse.fromJson(json);

      expect(response.trades.length, 2);
      expect(response.trades[0].id, 'a2d4G000000ukoxQAA');
      expect(response.trades[0].name, 'Access');
      expect(response.trades[1].id, 'a2d4G000000ukp2QAA');
      expect(response.trades[1].name, 'Air Con');
    });

    test('toJson serializes trades correctly', () {
      const response = FixedPriceTradesResponse(
        trades: [
          FixedPriceModel(id: 'a2d4G000000ukoxQAA', name: 'Access'),
        ],
      );

      final json = response.toJson();

      expect(json['trades'], isA<List>());
      expect(json['trades'][0]['id'], 'a2d4G000000ukoxQAA');
      expect(json['trades'][0]['name'], 'Access');
    });
  });

  group('FixedPriceCategoryModel', () {
    test('fromJson sets properties correctly', () {
      final json = {
        'id': 'cat_1',
        'name': 'Leaks',
      };

      final model = FixedPriceCategoryModel.fromJson(json);

      expect(model.id, 'cat_1');
      expect(model.name, 'Leaks');
    });

    test('toJson serializes properties correctly', () {
      const model = FixedPriceCategoryModel(
        id: 'cat_1',
        name: 'Leaks',
      );

      final json = model.toJson();

      expect(json['id'], 'cat_1');
      expect(json['name'], 'Leaks');
    });

    test('supports value equality', () {
      expect(
        const FixedPriceCategoryModel(id: '1', name: 'Leaks'),
        equals(const FixedPriceCategoryModel(id: '1', name: 'Leaks')),
      );
    });
  });

  group('FixedPriceCategoriesResponse', () {
    test('fromJson sets categories correctly', () {
      final json = {
        'categories': [
          {
            'id': 'cat_1',
            'name': 'Leaks',
          },
          {
            'id': 'cat_2',
            'name': 'Taps',
          }
        ]
      };

      final response = FixedPriceCategoriesResponse.fromJson(json);

      expect(response.categories.length, 2);
      expect(response.categories[0].id, 'cat_1');
      expect(response.categories[0].name, 'Leaks');
      expect(response.categories[1].id, 'cat_2');
      expect(response.categories[1].name, 'Taps');
    });

    test('toJson serializes categories correctly', () {
      const response = FixedPriceCategoriesResponse(
        categories: [
          FixedPriceCategoryModel(id: 'cat_1', name: 'Leaks'),
        ],
      );

      final json = response.toJson();

      expect(json['categories'], isA<List>());
      expect(json['categories'][0]['id'], 'cat_1');
      expect(json['categories'][0]['name'], 'Leaks');
    });
  });

  group('FixedPriceWorkTypeModel', () {
    test('fromJson sets properties correctly', () {
      final json = {
        'id': 'wt_1',
        'name': 'Trace & Access',
      };

      final model = FixedPriceWorkTypeModel.fromJson(json);

      expect(model.id, 'wt_1');
      expect(model.name, 'Trace & Access');
    });

    test('toJson serializes properties correctly', () {
      const model = FixedPriceWorkTypeModel(
        id: 'wt_1',
        name: 'Trace & Access',
      );

      final json = model.toJson();

      expect(json['id'], 'wt_1');
      expect(json['name'], 'Trace & Access');
    });

    test('supports value equality', () {
      expect(
        const FixedPriceWorkTypeModel(id: '1', name: 'T&A'),
        equals(const FixedPriceWorkTypeModel(id: '1', name: 'T&A')),
      );
    });
  });

  group('FixedPriceWorkTypesResponse', () {
    test('fromJson sets work types correctly', () {
      final json = {
        'work_types': [
          {
            'id': 'wt_1',
            'name': 'Trace & Access',
          },
          {
            'id': 'wt_2',
            'name': 'Repair Leak',
          }
        ]
      };

      final response = FixedPriceWorkTypesResponse.fromJson(json);

      expect(response.workTypes.length, 2);
      expect(response.workTypes[0].id, 'wt_1');
      expect(response.workTypes[0].name, 'Trace & Access');
      expect(response.workTypes[1].id, 'wt_2');
      expect(response.workTypes[1].name, 'Repair Leak');
    });

    test('toJson serializes work types correctly', () {
      const response = FixedPriceWorkTypesResponse(
        workTypes: [
          FixedPriceWorkTypeModel(id: 'wt_1', name: 'Trace & Access'),
        ],
      );

      final json = response.toJson();

      expect(json['work_types'], isA<List>());
      expect(json['work_types'][0]['id'], 'wt_1');
      expect(json['work_types'][0]['name'], 'Trace & Access');
    });
  });
}
