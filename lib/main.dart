import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'models.dart';
import 'pages/health_record_page.dart';
import 'pages/medicine_page.dart';
import 'pages/settings_page.dart';
import 'pages/statistics_page.dart';
import 'pages/user_profile_page.dart';
import 'services/notification_service.dart';

/// 应用程序入口点
///
/// 在构建界面之前先初始化通知服务（内部含时区设置）。通知要走原生通道，
/// 且初始化必须早于任何界面构建，因此这里是 async 的。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 通知服务内部含时区与插件初始化，必须在构建界面之前完成
  await NotificationService.instance.init();
  // 启动时按本地数据重建一次提醒，保证系统里的闹钟与本地记录一致
  await NotificationService.instance.syncAll(await loadMedicines());
  runApp(const HealthLogApp());
}

/// HealthLog应用程序的根组件
///
/// 这是一个有状态组件，用于配置应用程序的主题和主页
class HealthLogApp extends StatefulWidget {
  /// 创建HealthLogApp实例
  ///
  /// [key] - 组件的键值
  const HealthLogApp({super.key});

  @override
  State<HealthLogApp> createState() => _HealthLogAppState();
}

/// HealthLogApp组件的状态类
///
/// 管理应用的主题模式
class _HealthLogAppState extends State<HealthLogApp> {
  /// 当前应用的主题模式
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

  /// 更新主题模式
  void updateThemeMode(AppThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthLog - 用药日志',
      theme: ThemeData(
        // 浅色主题
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        // 深色主题
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: switch (_themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      // 设置主页为MainScreen
      home: MainScreen(
        onThemeModeChanged: updateThemeMode,
      ),
    );
  }
}

/// 应用程序的主页，包含底部导航栏
///
/// 这是一个有状态组件，用于在用药、记录、统计、档案和设置页面之间切换
class MainScreen extends StatefulWidget {
  /// 主题模式变更回调函数
  final Function(AppThemeMode) onThemeModeChanged;

  /// 创建MainScreen实例
  ///
  /// [key] - 组件的键值
  const MainScreen({super.key, required this.onThemeModeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// MainScreen组件的状态类
///
/// 管理当前选中的页面索引和页面切换逻辑
class _MainScreenState extends State<MainScreen> {
  /// 当前选中的页面索引
  int _currentIndex = 0;

  /// 各页面对应的标题
  ///
  /// 与下方导航项一一对应地集中定义，避免再次出现「标签与实际内容不符」的问题。
  static const List<String> _titles = [
    '用药提醒',
    '健康记录',
    '数据统计',
    '用户档案',
    '设置',
  ];

  /// 页面组件列表
  ///
  /// 与 [_titles] 及底部导航项顺序严格一一对应
  late final List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      const MedicinePage(),
      const HealthRecordPage(),
      const StatisticsPage(),
      const UserProfilePage(),
      SettingsPage(onThemeModeChanged: widget.onThemeModeChanged),
    ];
  }

  /// 底部导航栏点击事件处理函数
  ///
  /// [index] - 被点击的导航项索引
  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // 监听全局数据版本号：备份导入等批量改写数据的操作会将其自增，
      // key 随之变化会强制丢弃旧的 State 并重建子树，等价于让当前页重新加载数据。
      body: ValueListenableBuilder<int>(
        valueListenable: dataRevision,
        builder: (context, rev, _) => KeyedSubtree(
          key: ValueKey<int>(rev * 10 + _currentIndex),
          child: _children[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTappedBar,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: '用药',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '档案',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
