import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:dio/dio.dart';

class VcrExamplesApiService {
  VcrExamplesApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<VcrExamplePhoto>> fetchExamples(String section) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getVcrExamples(section),
      );
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw Exception(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load example photos.',
          ),
        );
      }

      return _parseExamples(body['data'], section);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getError(e));
    }
  }

  List<VcrExamplePhoto> _parseExamples(dynamic data, String section) {
    final fallbackLabel = vcrSectionLabels[section] ?? 'Example';

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final images = map['images'];
      if (images is List) {
        return images
            .whereType<Map>()
            .map(
              (image) => _photoFromMap(
                Map<String, dynamic>.from(image),
                fallbackLabel,
              ),
            )
            .where((photo) => photo.imageUrl.isNotEmpty)
            .toList();
      }
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (image) =>
                _photoFromMap(Map<String, dynamic>.from(image), fallbackLabel),
          )
          .where((photo) => photo.imageUrl.isNotEmpty)
          .toList();
    }

    return const [];
  }

  VcrExamplePhoto _photoFromMap(
    Map<String, dynamic> image,
    String fallbackLabel,
  ) {
    final label =
        (image['name'] ?? image['label'] ?? image['title'] ?? fallbackLabel)
            .toString();
    final imageUrl =
        (image['url'] ?? image['imageUrl'] ?? image['image_url'] ?? '')
            .toString();

    return VcrExamplePhoto(label: label, imageUrl: imageUrl);
  }
}
