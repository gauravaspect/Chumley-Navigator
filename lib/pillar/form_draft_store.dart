import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local drafts: `navigator.form.answers.<jobId>` and `navigator.job.progress.<jobId>`.
class FormDraftStore {
  static const _answersPrefix = 'navigator.form.answers.';
  static const _progressPrefix = 'navigator.job.progress.';
  static const _statusPrefix = 'navigator.job.status.';
  static const _photosPrefix = 'navigator.form.photos.';

  Future<Map<String, dynamic>> loadAnswers(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_answersPrefix$jobId');
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  Future<void> saveAnswers(String jobId, Map<String, dynamic> answers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_answersPrefix$jobId', jsonEncode(answers));
  }

  Future<int> loadFurthestStep(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_progressPrefix$jobId') ?? 0;
  }

  Future<void> saveFurthestStep(String jobId, int step) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_progressPrefix$jobId') ?? 0;
    if (step > current) {
      await prefs.setInt('$_progressPrefix$jobId', step);
    }
  }

  Future<String?> loadStatus(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_statusPrefix$jobId');
  }

  Future<void> saveStatus(String jobId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_statusPrefix$jobId', status.trim());
  }

  Future<Map<String, String>> loadPhotos(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_photosPrefix$jobId');
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  Future<void> savePhotos(String jobId, Map<String, String> photos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_photosPrefix$jobId', jsonEncode(photos));
  }

  Future<void> saveDraft({
    required String jobId,
    required int step,
    required Map<String, dynamic> answers,
    required Map<String, String> photos,
  }) async {
    await saveFurthestStep(jobId, step);
    await saveAnswers(jobId, answers);
    await savePhotos(jobId, photos);
  }
}
