import 'dart:developer';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  /// Compresses and resizes a [file] so that the longest edge is at most [targetLongestEdge]
  /// and the JPEG quality is set to [quality].
  ///
  /// Uses native platform background compression without loading raw uncompressed
  /// bitmap byte arrays into Dart VM heap memory.
  static Future<File?> compressImage(
    File file, {
    int targetLongestEdge = 1600,
    int quality = 70,
  }) async {
    try {
      if (!await file.exists()) {
        log('File does not exist, skipping compression.');
        return file;
      }

      final originalLength = await file.length();
      if (originalLength == 0) {
        log('File is empty, skipping compression.');
        return file;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: quality,
            minWidth: targetLongestEdge,
            minHeight: targetLongestEdge,
            format: CompressFormat.jpeg,
          );

      if (compressedXFile == null) {
        log('Native compressor returned null, falling back to original');
        return file;
      }

      final compressedFile = File(compressedXFile.path);
      final compressedLength = await compressedFile.length();

      log(
        'Image compression complete: '
        '(${(originalLength / 1024).toStringAsFixed(1)} KB) -> '
        '(${(compressedLength / 1024).toStringAsFixed(1)} KB). '
        'Saved ~${((originalLength - compressedLength) / originalLength * 100).toStringAsFixed(1)}% payload.',
      );

      return compressedFile;
    } catch (e, stackTrace) {
      log(
        'Error during image compression: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return file; // Fallback
    }
  }
}
