import 'client.dart';

class UserInfo {
  final int mid;
  final String name;
  final String avatar;

  UserInfo({required this.mid, required this.name, required this.avatar});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      mid: json['mid'] ?? 0,
      name: json['uname'] ?? '',
      avatar: json['face'] ?? '',
    );
  }
}

class MySelf extends UserInfo {
  final int level;
  final int money;

  MySelf({
    required super.mid,
    required super.name,
    required super.avatar,
    required this.level,
    required this.money,
  });

  factory MySelf.fromJson(Map<String, dynamic> json) {
    return MySelf(
      mid: json['mid'] ?? 0,
      name: json['uname'] ?? '',
      avatar: json['face'] ?? '',
      level: json['level_info']['current_level'] ?? 0,
      money: json['money'] ?? 0,
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
