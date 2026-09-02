import 'dart:io';

/// Normalizes API bodies (Map, List, String) for safe reads in cubits/services.
class ApiResponseHelper {
  /// Per-file limit for multipart uploads (nginx often caps ~1–10 MB).
  static const int maxUploadFileBytes = 4 * 1024 * 1024;
  static Map<String, dynamic> toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) return {'data': data};
    if (data is String && data.trim().isNotEmpty) {
      return {'message': data.trim()};
    }
    return {};
  }

  static String extractMessage(
      dynamic data, {
        String fallback = 'Something went wrong',
        int? statusCode,
      }) {
    if (statusCode == 413) {
      return _payloadTooLargeMessage;
    }

    if (data == null) return fallback;
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return fallback;
      final fromHtml = _messageFromHtmlOrPlain(trimmed);
      if (fromHtml != null) return fromHtml;
      return trimmed;
    }
    if (data is List) {
      final parts = data
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isEmpty) return fallback;
      return parts.join('\n');
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message = map['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;

      final detail = map['detail']?.toString().trim();
      if (detail != null && detail.isNotEmpty) {
        final match = RegExp(r"'message':\s*'([^']+)'").firstMatch(detail);
        if (match != null && match.group(1) != null) {
          return match.group(1)!;
        }
        return detail;
      }

      final error = map['error']?.toString().trim();
      if (error != null && error.isNotEmpty) return error;

      final nested = map['data'];
      if (nested is Map) {
        final nestedMessage = Map<String, dynamic>.from(
          nested,
        )['message']?.toString().trim();
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
      if (nested is String && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }
    return fallback;
  }

  static bool readIsReporter(dynamic data) {
    if (data is bool) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['isReporter'] == true) return true;
      if (map['is_reporter'] == true) return true;
    }
    return false;
  }

  static const String _payloadTooLargeMessage =
      'Upload too large. Use smaller images (under 4 MB each) or take a new photo at lower resolution.';

  static String? _messageFromHtmlOrPlain(String body) {
    final lower = body.toLowerCase();
    if (lower.contains('request entity too large') || lower.contains('413')) {
      return _payloadTooLargeMessage;
    }
    if (body.trimLeft().startsWith('<')) {
      return 'Server error. Please try again.';
    }
    return null;
  }

  static Future<bool> isFileWithinUploadLimit(File file) async {
    final length = await file.length();
    return length <= maxUploadFileBytes;
  }

  static String fileSizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
