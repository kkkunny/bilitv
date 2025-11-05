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
  final _loginNotifier = ValueNotifier(loginInfoNotifier.value.isLogin);

  @override
  void initState() {
    super.initState();
    _loginNotifier.addListener(_onLoginChanged);
  }

  @override
  void dispose() {
    _loginNotifier.removeListener(_onLoginChanged);
    super.dispose();
  }

  void _onLoginChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loginNotifier.value) {
      return UserInfoPage(_loginNotifier);
    }
    return QRLoginPage(_loginNotifier);
  }
}
