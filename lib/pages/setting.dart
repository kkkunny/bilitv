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
  late bool _ha = true;
  late bool _danmu = true;
  late VideoOutputDrivers _vo = VideoOutputDrivers.gpu;
  late HardwareVideoDecoder _hwdec = HardwareVideoDecoder.autoSafe;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _ha = await Settings.getBool(Settings.pathHASwitch) ?? true;
    _danmu = await Settings.getBool(Settings.pathDanmuSwitch) ?? true;
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(
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
      ),
    );
  }
}
