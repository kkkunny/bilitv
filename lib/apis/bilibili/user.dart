import 'client.dart';

class MySelf {
  final String name;
  final String avatar;
  final int level;

  MySelf({required this.name, required this.avatar, required this.level});

  factory MySelf.fromJson(Map<String, dynamic> json) {
    return MySelf(
      name: json['uname'] ?? '',
      avatar: json['face'] ?? '',
      level: json['level_info']['current_level'] ?? 0,
    );
  }
}

Future<MySelf> getMySelfInfo() async {
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/web-interface/nav',
  );
  return MySelf.fromJson(data);
}
