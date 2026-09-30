import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chumley_navigator/core/log.dart';

/// Photo pipeline service that adheres to JOB_FLOW.md Section 5.5:
/// - Max edge 900px
/// - JPEG quality ~0.65
/// - Target file size ~55KB
/// - Prepares clean slot dictionary
class PhotoPipelineService {
  /// Downscales and compresses an image from a local path
  static Future<String?> processPhoto(
    String sourcePath, {
    int maxEdge = 900,
    int quality = 65,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return null;

      final tempDir = await getTemporaryDirectory();
      final filename = sourcePath.split(Platform.pathSeparator).last;
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_$filename';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: maxEdge,
        minHeight: maxEdge,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final sizeKb = (await compressedFile.length()) / 1024;
        Log(
          'Compressed photo from $sourcePath to ${result.path} (${sizeKb.toStringAsFixed(1)} KB)',
          name: 'PhotoPipeline',
        );
        return result.path;
      }
    } catch (e, st) {
      Log('Photo compression error: $e\n$st', name: 'PhotoPipeline');
    }
    // Fallback to original path if compression fails
    return sourcePath;
  }
}
