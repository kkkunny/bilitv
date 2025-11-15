import 'package:shared_preferences/shared_preferences.dart';

const _settingsKey = 'settings';

class Settings {
  static const pathDanmuSwitch = ['danmu', 'switch'];

  static String _getKey(List<String> path) => '$_settingsKey.${path.join('.')}';

  static Future<void> setBool(List<String> path, bool v) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_getKey(path), v);
  }

  static Future<bool?> getBool(List<String> path) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getKey(path));
  }
}
