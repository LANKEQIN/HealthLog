import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../dialogs/import_confirm_dialog.dart';
import '../models.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';

/// 设置页面
///
/// 提供应用设置功能，目前支持主题切换
class SettingsPage extends StatefulWidget {
  /// 主题模式变更回调函数
  final Function(AppThemeMode)? onThemeModeChanged;
  
  /// 创建SettingsPage实例
  ///
  /// [key] - 组件的键值
  const SettingsPage({super.key, this.onThemeModeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// SettingsPage组件的状态类
class _SettingsPageState extends State<SettingsPage> {
  /// 当前选中的主题模式
  AppThemeMode _themeMode = AppThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  /// 加载保存的主题设置
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(kKeyThemeMode) ?? 'system';
    
    setState(() {
      switch (themeModeString) {
        case 'light':
          _themeMode = AppThemeMode.light;
          break;
        case 'dark':
          _themeMode = AppThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = AppThemeMode.system;
          break;
      }
    });
  }

  /// 保存主题设置
  Future<void> _saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String modeString;
    
    switch (mode) {
      case AppThemeMode.light:
        modeString = 'light';
        break;
      case AppThemeMode.dark:
        modeString = 'dark';
        break;
      case AppThemeMode.system:
        modeString = 'system';
        break;
    }
    
    await prefs.setString(kKeyThemeMode, modeString);
  }

  /// 处理主题模式变更
  void _handleThemeModeChange(AppThemeMode? mode) {
    if (mode != null) {
      setState(() {
        _themeMode = mode;
      });
      _saveThemeMode(mode);
      
      // 通知主应用更新主题
      widget.onThemeModeChanged?.call(mode);
    }
  }

  /// 导出全部本地数据为 JSON 备份文件
  Future<void> _exportBackup() async {
    try {
      final path = await BackupService.exportToFile();
      if (!mounted) return;
      // 返回 null 表示用户在保存对话框中取消了操作
      if (path == null) return;
      _showSnackBar('备份已导出到：$path');
    } on BackupException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('导出失败：$e');
    }
  }

  /// 从 JSON 备份文件恢复数据
  Future<void> _importBackup() async {
    BackupPayload? picked;
    try {
      picked = await BackupService.pickAndParse();
    } on BackupException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
      return;
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('读取备份文件失败：$e');
      return;
    }
    // 为 null 表示用户取消了文件选择
    final payload = picked;
    if (payload == null || !mounted) return;

    // 覆盖前先让用户确认，避免误操作丢失现有数据
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ImportConfirmDialog(payload: payload),
    );
    if (confirmed != true || !mounted) return;

    try {
      await BackupService.applyPayload(payload);
      // 让所有页面丢弃缓存、重新读取刚写入的数据
      dataRevision.value++;
      // 用药数据已变，提醒需要按新数据整体重建
      await NotificationService.instance.syncAll(await loadMedicines());
      if (!mounted) return;
      _showSnackBar('数据已从备份恢复');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('导入失败：$e');
    }
  }

  /// 重新申请通知与精确闹钟权限
  ///
  /// 作为用户误拒权限后的兜底入口，系统对已授权/已拒绝的权限不会重复弹窗。
  Future<void> _requestNotificationPermission() async {
    await NotificationService.instance.requestPermissions();
    if (!mounted) return;
    _showSnackBar('已发起权限申请，请在系统弹窗中确认');
  }

  /// 统一的底部提示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // 不再自带 AppBar：标题栏由 MainScreen 统一提供，避免出现双层标题栏
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            title: const Text('主题设置'),
            subtitle: const Text('选择应用的主题模式'),
            leading: Icon(
              Icons.palette_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // 由 RadioGroup 统一管理选中值，RadioListTile 只声明自身取值
          RadioGroup<AppThemeMode>(
            groupValue: _themeMode,
            onChanged: _handleThemeModeChange,
            child: Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: const Text('浅色主题'),
                  value: AppThemeMode.light,
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('深色主题'),
                  value: AppThemeMode.dark,
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('跟随系统'),
                  value: AppThemeMode.system,
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('数据备份'),
            subtitle: const Text('导出或恢复本地数据'),
            leading: Icon(
              Icons.backup_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('导出数据备份'),
            subtitle: const Text('导出为 JSON 文件'),
            onTap: _exportBackup,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导入数据备份'),
            subtitle: const Text('从 JSON 文件恢复，将覆盖当前数据'),
            onTap: _importBackup,
          ),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('通知权限'),
            subtitle: const Text('重新申请通知与精确闹钟权限'),
            leading: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: _requestNotificationPermission,
          ),
        ],
      ),
    );
  }
}