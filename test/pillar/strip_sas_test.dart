import 'package:chumley_navigator/pillar/photo_uploader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stripSas removes query string', () {
    expect(
      stripSas('https://blob.example/photo.jpg?sv=2021-01-01&sig=abc'),
      'https://blob.example/photo.jpg',
    );
  });
}
