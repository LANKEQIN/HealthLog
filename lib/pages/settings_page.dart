import 'package:flutter/material.dart';
import '../models.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    
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
    
    await prefs.setString('theme_mode', modeString);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
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
          RadioListTile<AppThemeMode>(
            title: const Text('浅色主题'),
            value: AppThemeMode.light,
            groupValue: _themeMode,
            onChanged: _handleThemeModeChange,
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('深色主题'),
            value: AppThemeMode.dark,
            groupValue: _themeMode,
            onChanged: _handleThemeModeChange,
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('跟随系统'),
            value: AppThemeMode.system,
            groupValue: _themeMode,
            onChanged: _handleThemeModeChange,
          ),
        ],
      ),
    );
  }
}