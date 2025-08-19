import 'package:flutter/material.dart';
import 'medicine_page.dart';
import 'health_record_page.dart';

/// 应用程序入口点
///
/// 调用runApp函数启动HealthLogApp
void main() {
  runApp(const HealthLogApp());
}

/// HealthLog应用程序的根组件
///
/// 这是一个无状态组件，用于配置应用程序的主题和主页
class HealthLogApp extends StatelessWidget {
  /// 创建HealthLogApp实例
  ///
  /// [key] - 组件的键值
  const HealthLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthLog - 用药日志',
      theme: ThemeData(
        // 使用蓝色作为主题色
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 设置主页为MainScreen
      home: const MainScreen(),
    );
  }
}

/// 应用程序的主页，包含底部导航栏
///
/// 这是一个有状态组件，用于在药物页面和健康记录页面之间切换
class MainScreen extends StatefulWidget {
  /// 创建MainScreen实例
  ///
  /// [key] - 组件的键值
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// MainScreen组件的状态类
///
/// 管理当前选中的页面索引和页面切换逻辑
class _MainScreenState extends State<MainScreen> {
  /// 当前选中的页面索引
  int _currentIndex = 0;

  /// 页面组件列表
  ///
  /// 包含药物页面和健康记录页面
  final List<Widget> _children = [
    const MedicinePage(),
    const HealthRecordPage(),
  ];

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
        title: const Text('HealthLog'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTappedBar,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: '用药',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
      ),
    );
  }
}