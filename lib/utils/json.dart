// JSON 容错取值工具
//
// B 站接口存在字段缺失、类型漂移（int/字符串互换）、风控页返回 HTML 等情况，
// 这里提供统一的容错取值：类型不符时返回 null 或默认值，而不是抛异常。

// 非 Map 返回 null
Map<String, dynamic>? jsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry('$k', v));
  return null;
}

// 非 List 返回 null
List<dynamic>? jsonList(Object? value) {
  if (value is List) return value;
  return null;
}

// int/num/数字字符串 → int，其余返回 fallback
int jsonInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final text = value.trim();
    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? fallback;
  }
  return fallback;
}

// 仅接受 String，其余返回 fallback
String jsonString(Object? value, {String fallback = ''}) {
  if (value is String) return value;
  return fallback;
}

// bool → 原值；num → 是否非 0；其余返回 fallback
bool jsonBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return fallback;
}
