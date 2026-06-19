import 'dart:io';
import 'package:chumley_navigator/utils/image_compressor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageCompressor Tests', () {
    test('compressImage fallback returns the original file when file is empty', () async {
      final mockFile = File('non_existent_mock_file.jpg');
      
      // If the file does not exist or has 0 length, it should return the original file
      final result = await ImageCompressor.compressImage(mockFile);
      
      expect(result, isNotNull);
      expect(result!.path, equals(mockFile.path));
    });

    test('compressImage gracefully catches errors and falls back to the original file', () async {
      // Create a temporary mock file with some content
      final directory = Directory.systemTemp.createTempSync();
      final mockFile = File('${directory.path}/test_image.jpg');
      mockFile.writeAsBytesSync([0, 1, 2, 3]);

      try {
        // Calling compressImage will try to decode bytes and invoke the native channel,
        // which will fail in a unit test environment.
        // It should gracefully catch the exception, log it, and return the original file.
        final result = await ImageCompressor.compressImage(mockFile);

        expect(result, isNotNull);
        expect(result!.path, equals(mockFile.path));
      } finally {
        directory.deleteSync(recursive: true);
      }
    });
  });
}
