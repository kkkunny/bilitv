import 'package:bilitv/pages/qr_login.dart';
import 'package:bilitv/pages/user_info.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:flutter/material.dart';

class UserEntryPage extends StatefulWidget {
  const UserEntryPage({super.key});

  @override
  State<UserEntryPage> createState() => _UserEntryPageState();
}

class _UserEntryPageState extends State<UserEntryPage> {
  late final ValueNotifier<bool> _loginNotifier;

  @override
  void initState() {
    super.initState();
    _loginNotifier = ValueNotifier(loginInfoNotifier.value.isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _loginNotifier,
      builder: (context, value, _) {
        return value
            ? UserInfoPage(_loginNotifier)
            : QRLoginPage(_loginNotifier);
      },
    );
  }
}
