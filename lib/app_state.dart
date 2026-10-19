import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// 本地存储使用的键名常量
///
/// 集中定义可以避免各页面各写一份字符串字面量，出现拼写不一致导致读不到数据。
const String kKeyMedicines = 'medicines';
const String kKeyHealthRecords = 'healthRecords';
const String kKeyUserProfile = 'userProfile';
const String kKeyThemeMode = 'theme_mode';

/// 全局数据版本号
///
/// 任何「批量改写本地数据」的操作（如备份导入）完成后将其自增，
/// 界面据此丢弃缓存重新读取。这样各页面无需各自维护刷新回调，
/// 也不会因为忘记注销监听而泄漏。
final ValueNotifier<int> dataRevision = ValueNotifier<int>(0);

/// 读取用药提醒列表
///
/// 统一封装读取与反序列化，避免每个页面重复写一遍 json.decode。
Future<List<Medicine>> loadMedicines() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(kKeyMedicines) ?? '[]';
  final list = json.decode(raw) as List;
  return list.map((e) => Medicine.fromJson(e as Map<String, dynamic>)).toList();
}

/// 读取健康记录列表
Future<List<HealthRecord>> loadHealthRecords() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(kKeyHealthRecords) ?? '[]';
  final list = json.decode(raw) as List;
  return list.map((e) => HealthRecord.fromJson(e as Map<String, dynamic>)).toList();
}

/// 读取用户档案，从未保存过时返回 null
Future<UserProfile?> loadUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(kKeyUserProfile);
  if (raw == null) return null;
  return UserProfile.fromJson(json.decode(raw) as Map<String, dynamic>);
}
