import 'package:bilitv/pages/qr_login.dart';
import 'package:bilitv/pages/user_info.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:flutter/material.dart';

class UserEntryPage extends StatelessWidget {
  const UserEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: loginInfoNotifier,
      builder: (context, value, _) {
        return value.isLogin ? const UserInfoPage() : const QRLoginPage();
      },
    );
  }
}
