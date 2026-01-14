import 'package:bilitv/apis/bilibili/error.dart';
import 'package:bilitv/apis/bilibili/user.dart';
import 'package:bilitv/storages/auth.dart'
    show clearCookie, loginInfoNotifier, LoginInfo;
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  Future<MySelf?> _load() async {
    try {
      final info = await getMySelfInfo();
      loginInfoNotifier.value = LoginInfo.login(
        mid: info.mid,
        nickname: info.name,
        avatar: info.avatar,
      );
      return info;
    } on BilibiliError catch (e) {
      if (e == BilibiliError.notLoggedIn) await _logout();
    }
    return null;
  }

  Future<void> _logout() async {
    await clearCookie();
    loginInfoNotifier.value = LoginInfo.notLogin;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data == null) {
          return const Center(child: Text('未登录'));
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BilibiliAvatar(snapshot.data!.avatar, radius: 100),
                const SizedBox(width: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.data!.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '等级 ${snapshot.data!.level}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _logout, child: const Text('退出登录')),
          ],
        );
      },
    );
  }
}
