// 应用启动的冒烟测试：验证根组件能够正常构建并渲染出主导航标题。
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_log/main.dart';

void main() {
  testWidgets('HealthLog app smoke test', (WidgetTester tester) async {
    // 页面加载依赖 shared_preferences，测试环境需要注入空的初始值，
    // 否则会因缺少原生插件实现而抛异常。
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const HealthLogApp());
    await tester.pumpAndSettle();

    // 默认停留在「用药」页，标题栏与页面内的小标题都应出现
    expect(find.text('用药提醒'), findsWidgets);
  });
}
