String stripSas(String url) {
  final u = Uri.parse(url);
  return u.replace(query: '').toString().replaceFirst(RegExp(r'\?$'), '');
}

class PhotoUploader {
  PhotoUploader({required this.uploadBase, required this.postBytes});

  final String uploadBase;
  final Future<String> Function(List<int> bytes, String filename) postBytes;

  String get endpoint {
    final base = uploadBase.replaceAll(RegExp(r'/+$'), '');
    return '$base/image-upload';
  }
}
