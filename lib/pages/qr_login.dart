import 'dart:async';

import 'package:bilitv/apis/bilibili/auth.dart';
import 'package:bilitv/apis/bilibili/user.dart';
import 'package:bilitv/storages/auth.dart'
    show saveCookie, loginInfoNotifier, LoginInfo;
import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<bool?> showQrLoginDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _QrLoginDialog(),
  );
}

class _QrLoginDialog extends StatelessWidget {
  const _QrLoginDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const _QrLoginWidget(),
      ),
    );
  }
}

class _QrLoginWidget extends StatefulWidget {
  const _QrLoginWidget();

  @override
  State<_QrLoginWidget> createState() => _QrLoginWidgetState();
}

class _QrLoginWidgetState extends State<_QrLoginWidget> {
  QR? _qr;
  QRState _state = QRState.waiting;
  Timer? _pollTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshQR();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshQR() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _qr = null;
      _state = QRState.waiting;
    });

    _pollTimer?.cancel();

    try {
      final qr = await createQR();
      if (!mounted) return;

      setState(() {
        _qr = qr;
        _state = QRState.waiting;
        _isRefreshing = false;
      });

      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = QRState.error;
        _isRefreshing = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _check());
  }

  Future<void> _check() async {
    if (_qr == null) return;
    try {
      final status = await checkQRStatus(_qr!.key);
      if (!mounted) return;

      setState(() => _state = status.state);
      switch (status.state) {
        case QRState.confirmed:
          await _onLoginSuccess(status);
        case QRState.expired:
          _pollTimer?.cancel();
        default:
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = QRState.error;
      });
    }
  }

  Future<void> _onLoginSuccess(QRStatus status) async {
    _pollTimer?.cancel();

    try {
      await saveCookie(status.cookies, refreshToken: status.refreshToken ?? '');
      final info = await getMySelfInfo();
      loginInfoNotifier.value = LoginInfo.login(
        mid: info.mid,
        nickname: info.name,
        avatar: info.avatar,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = QRState.error;
      });
    }
  }

  Widget _buildQrCode() {
    final size = 260.0;

    if (_qr == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return DpadFocusable(
      autofocus: true,
      builder: FocusEffects.glow(
        glowColor: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(12),
        spreadRadius: 10,
      ),
      onSelect: _refreshQR,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: QrImageView(
          data: _qr!.url,
          size: size,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    switch (_state) {
      case QRState.waiting:
        return const Text(
          '等待扫码',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      case QRState.scanned:
        return const Text(
          '已扫码，请在手机端确认',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        );
      case QRState.confirmed:
        return const Text(
          '登录成功',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        );
      case QRState.expired:
        return const Text(
          '二维码已过期，请点击二维码刷新',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        );
      case QRState.error:
        return const Text(
          '发生错误，请点击二维码重试',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQrCode(),
        const SizedBox(height: 16),
        _buildStatusText(),
        const SizedBox(height: 8),
        Text(
          '使用哔哩哔哩 App 扫描二维码登录\n点击二维码可刷新',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ],
    );
  }
}
