import 'package:bilitv/pages/qr_login.dart';
import 'package:bilitv/pages/user_info.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:flutter/material.dart';

class UserEntryPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const UserEntryPage(this._tappedListener, {super.key});

  @override
  State<UserEntryPage> createState() => _UserEntryPageState();
}

class _UserEntryPageState extends State<UserEntryPage> {
  late final ValueNotifier<bool> _loginNotifier;

  @override
  void initState() {
    super.initState();
    _loginNotifier = ValueNotifier(loginInfoNotifier.value.isLogin);
    _loginNotifier.addListener(_onLoginChanged);
    widget._tappedListener.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget._tappedListener.removeListener(_onRefresh);
    _loginNotifier.removeListener(_onLoginChanged);
    super.dispose();
  }

  Future<void> _onRefresh() async {}

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
