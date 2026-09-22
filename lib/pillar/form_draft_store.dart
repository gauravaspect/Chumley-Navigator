import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local drafts: `navigator.form.answers.<jobId>` and `navigator.job.progress.<jobId>`.
class FormDraftStore {
  static const _answersPrefix = 'navigator.form.answers.';
  static const _progressPrefix = 'navigator.job.progress.';
  static const _statusPrefix = 'navigator.job.status.';
  static const _photosPrefix = 'navigator.form.photos.';
  static const _formsDismissedPrefix = 'navigator.job.formsDismissed.';

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

  /// True when the engineer cancelled the on-site form session (step 1 cancel).
  /// Survives leaving the job and reopening so we show "Continue filling forms"
  /// instead of auto-launching the FormKind wizard (e.g. CP12).
  Future<bool> loadFormsDismissed(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_formsDismissedPrefix$jobId') ?? false;
  }

  Future<void> saveFormsDismissed(String jobId, bool dismissed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_formsDismissedPrefix$jobId', dismissed);
  }
}
