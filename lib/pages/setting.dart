import 'package:bilitv/consts/settings.dart';
import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/storages/settings.dart';
import 'package:bilitv/widgets/custom_setting_tiles.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late bool _danmu;
  late int _danmuBlockWeight;
  late bool _ha;
  late VideoOutputDrivers _vo;
  late HardwareVideoDecoder _hwdec;

  Future<int> _loadSettings() async {
    _danmu = await Settings.getBool(Settings.pathDanmuSwitch) ?? true;
    _danmuBlockWeight =
        await Settings.getInt(Settings.pathDanmuBlockWeightSwitch) ?? 6;
    _ha = await Settings.getBool(Settings.pathHASwitch) ?? true;
    _vo =
        VideoOutputDrivers.parse(
          await Settings.getString(Settings.pathVOSwitch) ??
              VideoOutputDrivers.gpu.value,
        ) ??
        VideoOutputDrivers.gpu;
    _hwdec =
        HardwareVideoDecoder.parse(
          await Settings.getString(Settings.pathHwdecSwitch) ??
              HardwareVideoDecoder.autoSafe.value,
        ) ??
        HardwareVideoDecoder.autoSafe;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadSettings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          return SettingsList(
            sections: [
              SettingsSection(
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    leading: Icon(IconFont.danmushezhi),
                    title: Text('弹幕设置-是否开启弹幕'),
                    initialValue: _danmu,
                    onToggle: (value) => setState(() {
                      Settings.setBool(Settings.pathDanmuSwitch, value);
                      _danmu = value;
                    }),
                  ),
                  CustomSettingsTiles.dropdown(
                    leading: Icon(IconFont.danmushezhi),
                    title: Text('弹幕屏蔽权重：值越大弹幕越少'),
                    value: _danmuBlockWeight,
                    items: List<int>.generate(
                      11,
                      (int index) => index,
                      growable: false,
                    ),
                    onChanged: (value) => setState(() {
                      Settings.setInt(
                        Settings.pathDanmuBlockWeightSwitch,
                        value,
                      );
                      _danmuBlockWeight = value;
                    }),
                  ),
                  SettingsTile.switchTile(
                    leading: Icon(IconFont.ha),
                    title: Text('播放设置-是否开启硬解'),
                    initialValue: _ha,
                    onToggle: (value) => setState(() {
                      Settings.setBool(Settings.pathHASwitch, value);
                      _ha = value;
                    }),
                  ),
                  CustomSettingsTiles.dropdown(
                    leading: Icon(Icons.video_settings_rounded),
                    title: Text('播放设置-输出驱动'),
                    value: _vo,
                    items: VideoOutputDrivers.values,
                    onChanged: (value) => setState(() {
                      Settings.setString(Settings.pathVOSwitch, value.value);
                      _vo = value;
                    }),
                  ),
                  CustomSettingsTiles.dropdown(
                    leading: Icon(Icons.video_stable_rounded),
                    title: Text('播放设置-硬解方式'),
                    value: _hwdec,
                    items: HardwareVideoDecoder.values,
                    onChanged: (value) => setState(() {
                      Settings.setString(Settings.pathHwdecSwitch, value.value);
                      _hwdec = value;
                    }),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
