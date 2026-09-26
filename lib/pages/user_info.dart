import 'package:bilitv/apis/bilibili/error.dart';
import 'package:bilitv/apis/bilibili/user.dart';
import 'package:bilitv/consts/color.dart';
import 'package:bilitv/storages/auth.dart'
    show clearCookie, loginInfoNotifier, LoginInfo;
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/cache_future_builder.dart';
import 'package:bilitv/widgets/pink_style.dart';
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
    // 以1080p为基准缩放整体尺寸
    final ui = MediaQuery.sizeOf(context).height / 1080;

    return CacheFutureBuilder(
      future: _load,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: biliPink));
        } else if (snapshot.data == null) {
          return const Center(child: Text('未登录'));
        }
        return Center(
          child: PinkPanel(
            ui: ui,
            padding: EdgeInsets.symmetric(
              horizontal: 80 * ui,
              vertical: 48 * ui,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6 * ui),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: biliPink, width: 3 * ui),
                  ),
                  child: BilibiliAvatar(snapshot.data!.avatar, radius: 80 * ui),
                ),
                SizedBox(width: 40 * ui),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data!.name,
                      style: TextStyle(
                        fontSize: 36 * ui,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12 * ui),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * ui,
                        vertical: 4 * ui,
                      ),
                      decoration: BoxDecoration(
                        color: biliPink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8 * ui),
                      ),
                      child: Text(
                        '等级 ${snapshot.data!.level}',
                        style: TextStyle(
                          fontSize: 20 * ui,
                          fontWeight: FontWeight.w600,
                          color: biliPink,
                        ),
                      ),
                    ),
                    SizedBox(height: 28 * ui),
                    PinkButton(
                      ui: ui,
                      label: '退出登录',
                      icon: Icons.logout_rounded,
                      onPressed: _logout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
