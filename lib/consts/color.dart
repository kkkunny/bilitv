import 'package:flutter/material.dart';

// 浅粉色
const lightPink = Color(0xFFFFECEC);

// 哔哩哔哩粉
const biliPink = Color(0xFFFB7299);

// 粉色渐变起点（浅）
const biliPinkLight = Color(0xFFFF7BA8);

// 粉色渐变终点（深）
const biliPinkDeep = Color(0xFFF54E86);

// 页面背景渐变起点
const detailBackgroundStart = Color(0xFFFCDDEA);

// 页面背景渐变终点
const detailBackgroundEnd = Color(0xFFFCEDF2);

// 统一的粉色渐变（强调按钮/选中项/图标底色）
const pinkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [biliPinkLight, biliPinkDeep],
);

// 统一的页面背景渐变（主页/详情页）
const pageBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [detailBackgroundStart, detailBackgroundEnd],
);
