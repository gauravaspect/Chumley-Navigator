import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  /// Compresses and resizes a [file] so that the longest edge is at most [targetLongestEdge]
  /// and the JPEG quality is set to [quality].
  static Future<File?> compressImage(
    File file, {
    int targetLongestEdge = 1600,
    int quality = 70,
  }) async {
    try {
      final originalLength = await file.length();
      if (originalLength == 0) {
        log('File is empty, skipping compression.');
        return file;
      }

      final bytes = await file.readAsBytes();

      // Retrieve image dimensions asynchronously using Flutter's native decoder
      final ui.Image decodedImage = await decodeImageFromList(bytes);
      final int originalWidth = decodedImage.width;
      final int originalHeight = decodedImage.height;

      int targetWidth = originalWidth;
      int targetHeight = originalHeight;

      if (originalWidth > originalHeight) {
        if (originalWidth > targetLongestEdge) {
          targetWidth = targetLongestEdge;
          targetHeight = (originalHeight * (targetLongestEdge / originalWidth)).round();
        }
      } else {
        if (originalHeight > targetLongestEdge) {
          targetHeight = targetLongestEdge;
          targetWidth = (originalWidth * (targetLongestEdge / originalHeight)).round();
        }
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: targetWidth,
        minHeight: targetHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedXFile == null) {
        log('Failed to compress image: native compressor returned null');
        return file; // Fallback
      }

      final compressedFile = File(compressedXFile.path);
      final compressedLength = await compressedFile.length();

      log('Image compression complete: '
          '${originalWidth}x$originalHeight (${(originalLength / 1024).toStringAsFixed(1)} KB) -> '
          '${targetWidth}x$targetHeight (${(compressedLength / 1024).toStringAsFixed(1)} KB). '
          'Saved ~${((originalLength - compressedLength) / originalLength * 100).toStringAsFixed(1)}% payload.');

      return compressedFile;
    } catch (e, stackTrace) {
      log('Error during image compression: $e', error: e, stackTrace: stackTrace);
      return file; // Fallback
    }
  }
}
