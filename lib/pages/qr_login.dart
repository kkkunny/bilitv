import 'dart:async';

import 'package:bilitv/apis/bilibili/auth.dart';
import 'package:bilitv/storages/cookie.dart' show saveCookie;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRLoginPage extends StatefulWidget {
  final ValueNotifier<bool> loginNotifier;

  const QRLoginPage(this.loginNotifier, {super.key});

  @override
  State<QRLoginPage> createState() => _QRLoginPageState();
}

class _QRLoginPageState extends State<QRLoginPage> {
  QR? _qr;
  QRState _state = QRState.waiting;
  Timer? _pollTimer;

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
    _qr = null;
    try {
      final qr = await createQR();
      setState(() {
        _qr = qr;
        _state = QRState.waiting;
      });

      _startPolling();
    } catch (e) {
      setState(() {
        _state = QRState.error;
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
      setState(() => _state = status.state);
      switch (status.state) {
        case QRState.confirmed:
          await _onLoginSuccess(status);
        case QRState.expired:
          _pollTimer?.cancel();
        default:
      }
    } catch (e) {
      setState(() => _state = QRState.error);
    }
  }

  Future<void> _onLoginSuccess(QRStatus status) async {
    final cookieHeader = status.cookies
        .map((c) => '${c.name}=${c.value}')
        .join('; ');
    await saveCookie(cookieHeader);
    widget.loginNotifier.value = true;
  }

  Widget _buildQRBox() {
    final size = 320.0;

    if (_qr == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return QrImageView(
      data: _qr!.url,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildStatusText() {
    switch (_state) {
      case QRState.waiting:
        return const Text('等待扫码', style: TextStyle(fontSize: 20));
      case QRState.scanned:
        return const Text(
          '已扫码，请在手机端确认',
          style: TextStyle(fontSize: 20, color: Colors.orange),
        );
      case QRState.confirmed:
        return const Text(
          '登录成功，正在跳转...',
          style: TextStyle(fontSize: 20, color: Colors.green),
        );
      case QRState.expired:
        return const Text(
          '二维码已过期，请刷新',
          style: TextStyle(fontSize: 20, color: Colors.red),
        );
      case QRState.error:
        return const Text(
          '发生错误，请重试',
          style: TextStyle(fontSize: 20, color: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQRBox(),
          const SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusText(),
              const SizedBox(height: 8),
              Text(
                '使用哔哩哔哩 App 扫描二维码登录',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _refreshQR();
                },
                child: const Text('刷新二维码'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
