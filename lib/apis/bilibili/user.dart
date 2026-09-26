import 'package:bilitv/apis/bilibili/client.dart';
import 'package:bilitv/storages/auth.dart' show loadCookie;
import 'package:dio/dio.dart' show Headers;

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

// 用户关系属性
class UserRelation {
  final int attribute; // 0：未关注 2：已关注 6：已互粉 128：已拉黑

  const UserRelation({this.attribute = 0});

  factory UserRelation.fromJson(Map<String, dynamic> json) {
    return UserRelation(attribute: json['attribute'] ?? 0);
  }

  // 是否已关注
  bool get following => attribute == 2 || attribute == 6;
}

// 查询用户与自己关系（需要登陆）
Future<UserRelation> getUserRelation(int mid) async {
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/relation',
    queries: {'fid': mid},
  );
  if (data is! Map<String, dynamic>) return const UserRelation();
  return UserRelation.fromJson(data);
}

// 查询用户粉丝数
Future<int> getUserFollowerCount(int mid) async {
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/relation/stat',
    queries: {'vmid': mid},
  );
  if (data is! Map<String, dynamic>) return 0;
  return data['follower'] ?? 0;
}

// 关注/取关（需要登陆）
Future<void> modifyUserRelation(int mid, {required bool follow}) async {
  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/relation/modify',
    contentType: Headers.formUrlEncodedContentType,
    body: {'fid': mid, 'act': follow ? 1 : 2, 're_src': 14, 'csrf': csrf},
  );
}
