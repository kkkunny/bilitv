import 'package:bilitv/storages/cookie.dart';
import 'package:flutter/material.dart';
import 'package:bilitv/pages/qr_login.dart';
import 'package:bilitv/pages/user_info.dart';

class UserEntryPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const UserEntryPage(this._tappedListener, {super.key});

  @override
  State<UserEntryPage> createState() => _UserEntryPageState();
}

class _UserEntryPageState extends State<UserEntryPage> {
  @override
  void initState() {
    super.initState();
    loginInfoNotifier.addListener(_onLoginChanged);
  }

  @override
  void dispose() {
    loginInfoNotifier.removeListener(_onLoginChanged);
    super.dispose();
  }

  void _onLoginChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loginInfoNotifier.value.isLogin) {
      return const UserInfoPage();
    }
    return const QRLoginPage();
  }
}
