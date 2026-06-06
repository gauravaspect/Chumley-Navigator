import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide dark / light preference for the dashboard command-centre theme.
class ThemeNotifier extends ChangeNotifier {
  static const _prefKey = 'isDark';

  bool _isDark = true;
  bool _loaded = false;

  bool get isDark => _isDark;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> toggle() => setDark(!_isDark);
}
