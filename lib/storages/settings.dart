import 'package:shared_preferences/shared_preferences.dart';

const _settingsKey = 'settings';

class Settings {
  static const pathHASwitch = ['setting', 'player', 'ha'];
  static const pathVOSwitch = ['setting', 'player', 'vo'];
  static const pathHwdecSwitch = ['setting', 'player', 'hwdec'];
  static const pathDanmuSwitch = ['setting', 'danmu', 'switch'];
  static const pathDanmuBlockWeightSwitch = [
    'setting',
    'danmu',
    'block_weight',
  ];
  static const pathQualitySwitch = ['setting', 'player', 'quality'];

  static String _getKey(List<String> path) => '$_settingsKey.${path.join('.')}';

  static Future<void> setBool(List<String> path, bool v) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_getKey(path), v);
  }

  static Future<bool?> getBool(List<String> path) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getKey(path));
  }

  static Future<void> setInt(List<String> path, int v) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_getKey(path), v);
  }

  static Future<int?> getInt(List<String> path) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getKey(path));
  }

  static Future<void> setString(List<String> path, String v) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_getKey(path), v);
  }

  static Future<String?> getString(List<String> path) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_getKey(path));
  }
}
