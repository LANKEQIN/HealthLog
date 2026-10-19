import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../models.dart';

/// 备份文件格式版本号
///
/// 将来若调整备份结构，可据此识别并对旧文件做迁移；导入高于该版本的文件会被拒绝。
const int kBackupVersion = 1;

/// 备份相关的异常
///
/// [message] 为可直接展示给用户的中文原因。
class BackupException implements Exception {
  BackupException(this.message);

  /// 面向用户的错误说明
  final String message;

  @override
  String toString() => message;
}

/// 解析后的备份内容
class BackupPayload {
  BackupPayload({
    required this.medicines,
    required this.healthRecords,
    this.userProfile,
    this.exportedAt,
  });

  /// 用药提醒列表
  final List<Medicine> medicines;

  /// 健康记录列表
  final List<HealthRecord> healthRecords;

  /// 用户档案，可能为空
  final UserProfile? userProfile;

  /// 备份导出时间（原始字符串），仅用于展示
  final String? exportedAt;
}

/// 数据备份与恢复服务
class BackupService {
  BackupService._();

  /// 导出全部本地数据为 JSON 备份文件
  ///
  /// 返回保存到的文件路径；用户取消保存时返回 null。
  static Future<String?> exportToFile() async {
    final jsonString = await buildBackupJson();
    final fileName = 'healthlog_backup_${_timestamp()}.json';

    // 只导出业务数据，不导出主题等设备偏好
    String? initialDirectory;
    if (_isDesktop) {
      try {
        initialDirectory = (await getDownloadsDirectory())?.path;
      } catch (_) {
        // 取不到下载目录不影响后续流程，忽略即可
      }
    }

    try {
      final path = await FilePicker.saveFile(
        dialogTitle: '导出 HealthLog 备份',
        fileName: fileName,
        initialDirectory: initialDirectory,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );
      if (path == null) return null;
      // Android/iOS 由插件通过系统文件选择器直接写入；
      // 桌面端插件只返回路径、不负责写盘，因此这里需要自己落盘。
      if (!Platform.isAndroid && !Platform.isIOS) {
        await File(path).writeAsString(jsonString);
      }
      return path;
    } catch (_) {
      // 部分平台不支持保存对话框，降级为写入应用文档目录并提示完整路径
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsString(jsonString);
      return file.path;
    }
  }

  /// 生成备份 JSON 字符串
  static Future<String> buildBackupJson() async {
    final medicines = await loadMedicines();
    final records = await loadHealthRecords();
    final profile = await loadUserProfile();

    final payload = {
      'app': 'health_log',
      'version': kBackupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': {
        'medicines': medicines.map((e) => e.toJson()).toList(),
        'healthRecords': records.map((e) => e.toJson()).toList(),
        'userProfile': profile?.toJson(),
      },
    };
    // 缩进输出便于用户直接查看与手工编辑备份文件
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// 选择备份文件并解析
  ///
  /// 返回 null 表示用户取消了选择；文件不合法时抛出 [BackupException]。
  static Future<BackupPayload?> pickAndParse() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: '选择 HealthLog 备份文件',
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    String raw;
    if (file.bytes != null) {
      raw = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      raw = await File(file.path!).readAsString();
    } else {
      throw BackupException('无法读取所选文件的内容');
    }
    return parse(raw);
  }

  /// 解析并校验备份内容
  ///
  /// 采用「全量强校验」：任何一条数据不合法都整体拒绝，
  /// 避免出现只导入一半、本地数据变成半新半旧的尴尬状态。
  static BackupPayload parse(String raw) {
    dynamic decoded;
    try {
      decoded = json.decode(raw);
    } catch (_) {
      throw BackupException('备份文件格式不正确：不是有效的 JSON');
    }
    if (decoded is! Map) {
      throw BackupException('备份文件格式不正确：顶层应为对象');
    }
    final map = decoded.cast<String, dynamic>();

    if (map['app'] != 'health_log') {
      throw BackupException('这不是 HealthLog 的备份文件');
    }
    final version = map['version'];
    if (version is! int || version > kBackupVersion) {
      throw BackupException('备份文件版本（$version）高于当前应用支持的版本，请升级应用后再导入');
    }
    final data = map['data'];
    if (data is! Map) {
      throw BackupException('备份文件缺少 data 内容');
    }
    final dataMap = data.cast<String, dynamic>();

    final medicines = _parseList<Medicine>(
      dataMap['medicines'],
      '用药提醒',
      Medicine.fromJson,
    );
    final records = _parseList<HealthRecord>(
      dataMap['healthRecords'],
      '健康记录',
      HealthRecord.fromJson,
    );

    UserProfile? profile;
    final rawProfile = dataMap['userProfile'];
    if (rawProfile != null) {
      if (rawProfile is! Map) {
        throw BackupException('用户档案格式不正确');
      }
      try {
        profile = UserProfile.fromJson(rawProfile.cast<String, dynamic>());
      } catch (_) {
        throw BackupException('用户档案数据无法解析');
      }
    }

    return BackupPayload(
      medicines: medicines,
      healthRecords: records,
      userProfile: profile,
      // 用 toString 兜底，避免手工改过的备份文件里该字段类型不符时抛错
      exportedAt: map['exportedAt']?.toString(),
    );
  }

  /// 将备份内容写回本地存储
  ///
  /// 调用前请确保内容已通过 [parse] 的校验，这里不做二次校验。
  static Future<void> applyPayload(BackupPayload payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kKeyMedicines,
      json.encode(payload.medicines.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      kKeyHealthRecords,
      json.encode(payload.healthRecords.map((e) => e.toJson()).toList()),
    );
    final profile = payload.userProfile;
    if (profile == null) {
      // 备份中没有档案时直接清除本地档案，保证与备份一致
      await prefs.remove(kKeyUserProfile);
    } else {
      await prefs.setString(kKeyUserProfile, json.encode(profile.toJson()));
    }
  }

  /// 解析列表字段，逐条试跑反序列化
  static List<T> _parseList<T>(
    dynamic value,
    String label,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return <T>[];
    if (value is! List) {
      throw BackupException('$label 数据格式不正确');
    }
    final result = <T>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      if (item is! Map) {
        throw BackupException('$label 第 ${i + 1} 条格式不正确');
      }
      try {
        result.add(fromJson(item.cast<String, dynamic>()));
      } catch (_) {
        throw BackupException('$label 第 ${i + 1} 条数据无法解析（字段缺失或不合法）');
      }
    }
    return result;
  }

  /// 是否运行在桌面平台
  static bool get _isDesktop =>
      !kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// 生成用于文件名的时间戳，如 20261018_213000
  ///
  /// 手工格式化而不引入 intl，避免为一个文件名增加依赖。
  static String _timestamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}'
        '_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}
