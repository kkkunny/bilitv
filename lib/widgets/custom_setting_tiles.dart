import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class CustomSettingsTiles {
  // 下拉框
  static SettingsTile dropdown<T>({
    Widget? leading,
    required Widget title,
    required T value,
    required List<T> items,
    void Function(T)? onChanged,
  }) {
    return SettingsTile.navigation(
      leading: leading,
      title: title,
      trailing: DropdownButton(
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
        value: value,
        onChanged: (e) {
          if (e == null) return;
          onChanged?.call(e);
        },
      ),
    );
  }
}
