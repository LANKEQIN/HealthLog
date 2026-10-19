# HealthLog 补完实施计划

## 背景（为什么做这件事）

用户在回顾旧项目时发现 HealthLog（Flutter 本地化用药/健康记录 App）尚未开发完成。经代码通读与需求确认，本次要补齐四项内容：

1. **统计可视化页** —— 现有「统计」tab 只是重复展示健康记录列表，并非统计，需要做成真正的指标概览 + 趋势图。
2. **真正的用药提醒推送** —— 现有「用药提醒」只做登记展示，不会触发系统提醒。
3. **数据备份 / 导入导出** —— 数据仅存本地，需要可导出与恢复的能力。
4. **修复现有 Bug** —— `main.dart` 中 `_children` 有 5 项但导航栏只有 4 项，`SettingsPage` 重复且不可达；导航标签「统计」与实际内容不符；档案页/设置页自带 AppBar 导致双标题栏。

预期结果：四项功能可用，导航与标签一致，数据可备份恢复，用药可真正定时提醒（Android 端验收），文档同步更新。

---

## 前置条件（必须先解决）

- **Flutter SDK 路径**：本机 `flutter` / `dart` 命令不可用，PATH 与常见目录均未找到 SDK。用户确认「已安装，稍后给路径」。**开始验证前需取得该路径**（形如 `X:\...\flutter\bin\flutter.bat`），用于 `pub get` / `analyze` / 构建。
- **依赖版本按 Dart 3.8 保守锁定**（`pubspec.lock` 约束为 `dart: >=3.8.1 <4.0.0`、`flutter: >=3.27.0`）。以下版本在 Dart 3.8 与 3.10 下均可用，无需随实际 Flutter 版本改动：

  | 依赖 | 版本 | 用途 |
  | --- | --- | --- |
  | `fl_chart` | `^1.2.0` | 统计页折线图 |
  | `flutter_local_notifications` | `^20.1.0` | 本地通知 |
  | `timezone` | `^0.10.1` | `zonedSchedule` 时区支持 |
  | `flutter_timezone` | `^5.1.1` | 读取设备本地时区（已获同意） |
  | `path_provider` | `^2.1.5` | 备份默认目录 / 桌面导出兜底 |
  | `file_picker` | `^11.0.3` | 选择导出目标 / 选择导入文件 |

  Android 工程 AGP 8.7.3 / Kotlin 2.1.0 / Gradle 8.12 已满足通知插件要求，无需升级。

> 依赖与目录结构变更属于规则第八条范畴，完成后需同步更新 README 与项目规则文件。

---

## 阶段一：导航重构与 Bug 修复（低风险，先行）

**导航方案：5 tab + 单 AppBar**（用户已确认）

```
用药(Icons.medication)      → MedicinePage
记录(Icons.monitor_heart)   → HealthRecordPage
统计(Icons.bar_chart)       → StatisticsPage（新增）
档案(Icons.person)          → UserProfilePage
设置(Icons.settings)        → SettingsPage
```

改动文件：

- `lib/main.dart`
  - 删除重复且不可达的 `const SettingsPage()`，`_children` 收敛为 5 项。
  - 新增 `_titles` 列表，`AppBar.title` 随 `_currentIndex` 变化，杜绝「标签是统计、内容是记录」。
  - `body` 包一层 `ValueListenableBuilder` + `KeyedSubtree(key: ValueKey(rev * 10 + _currentIndex))`，实现导入后的界面刷新（见阶段四）。
- `lib/pages/user_profile_page.dart`、`lib/pages/settings_page.dart`
  - 移除各自 `Scaffold` 的 `appBar:`，与 `MedicinePage`/`HealthRecordPage`「不自带 AppBar」的既有约定统一，消除双 AppBar。

---

## 阶段二：统计可视化页（可在桌面端完整验证）

新增 `lib/pages/statistics_page.dart`（不含 appBar，由 MainScreen 提供）：

- 时间范围切换：`SegmentedButton`（近 7 天 / 近 30 天 / 近 90 天 / 全部）。
- 概览卡片区：取范围内**最新一条**记录的收缩压/舒张压、血糖、体重、心率、体温（各带日期与单位）+ 范围内记录条数。
- 指标切换：横向滚动 `ChoiceChip`（血压 / 血糖 / 体重 / 心率 / 体温）。
- 图表区：`SizedBox(height: 240)` 包裹 `LineChart`（fl_chart 在无界高度下会报错，必须限高）。血压用**双线共轴**（收缩压 + 舒张压），其余为单线；fl_chart 无内置图例，用 `Row` + 色块自绘。
- 取数：复用阶段四的 `lib/app_state.dart` 统一读取方法，按 `date` 升序排列，x 轴用序号（点等距，无需引入 `intl` 做刻度格式化）。
- 取色全部走 `Theme.of(context).colorScheme`（线用 `primary`/`tertiary`/`secondary`，网格 `outlineVariant`，刻度 `onSurfaceVariant`），零硬编码颜色。
- Y 轴范围按数据自适应并留安全余量（血压 ±10、体温 ±0.5、体重 ±2、血糖 ±1、心率 ±10）。
- 空状态：范围内无数据 → 「该时间范围内暂无记录」；完全无记录 → 「暂无健康记录，请先到记录页添加」；`n == 0` 时不画图，避免非法轴范围。
- x 轴刻度按 `interval = max(1, n ~/ 5)` 抽稀，防止「全部」范围下标签重叠。

---

## 阶段三：本地通知提醒

新增 `lib/services/notification_service.dart`（单例 `NotificationService.instance`）。

**初始化**（`lib/main.dart` 的 `main()` 中，`runApp` 之前）：

```dart
WidgetsFlutterBinding.ensureInitialized();
await NotificationService.instance.init();   // 含时区初始化 + 插件初始化（含 Windows 分支）
runApp(const HealthLogApp());
```

- `InitializationSettings` 必须同时给出 `android` / `iOS` / `windows` / `macOS` / `linux` 分支；**Windows 分支必须传 `appName` + `appUserModelId` + 固定 `guid`**，否则桌面端初始化即崩溃。
- 时区：`FlutterTimezone.getLocalTimezone()`（5.x 返回 `TimezoneInfo`，取 `.identifier`）→ `tz.setLocalLocation(...)`；异常时按当前 UTC 偏移用 `Etc/GMT` 兜底，保证「几点服药」的墙钟语义不整体偏移。

**权限**（在 `MedicinePage` 首次进入时请求一次）：`requestNotificationsPermission()`（Android 13+）+ `requestExactAlarmsPermission()`（Android 12+）；重复调用无害。设置页可加一个「通知权限」入口作为误拒后的兜底。

**调度**：`zonedSchedule` + `matchDateTimeComponents: DateTimeComponents.time` 实现每日同一时刻重复。

**通知 ID**（不新增模型字段）：`medicineIndex * 100 + timeIndex`，配合「变更即全量重排」策略——`cancelAllPendingNotifications()` 后按当前列表重建，删除/编辑导致的索引漂移不会留下孤儿通知。**不使用 `hashCode` 派生 ID**（跨运行不稳定）。

**同步调用点（仅 1 处）**：`lib/pages/medicine_page.dart` 的 `_saveMedicines()` 末尾追加 `await NotificationService.instance.syncAll(_medicines);`。增/改/删三条路径都经过该方法，一处改动覆盖全部。

**按用药周期过滤**（用户已确认）：`if (m.endDate != null && m.endDate!.isBefore(今天)) continue;`

**Android 配置**：

- `android/app/build.gradle.kts`：`compileOptions { isCoreLibraryDesugaringEnabled = true }`；`dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }`；`defaultConfig { multiDexEnabled = true }`。若构建报 Java 版本要求，再将 `sourceCompatibility`/`targetCompatibility`/`jvmTarget` 提升到 17。
- `android/app/src/main/AndroidManifest.xml`：新增权限 `POST_NOTIFICATIONS`、`RECEIVE_BOOT_COMPLETED`、`SCHEDULE_EXACT_ALARM`；在 `<application>` 内新增 `ScheduledNotificationReceiver` 与带 `BOOT_COMPLETED`/`MY_PACKAGE_REPLACED` intent-filter 的 `ScheduledNotificationBootReceiver`（`exported="false"`）。重启后由 boot receiver 自动恢复调度，无需自写重建逻辑。

**降级**：Android 14+ 可能未授予精确闹钟权限，先 `canScheduleExactNotifications()` 探测，未授权时退回 `AndroidScheduleMode.inexactAllowWhileIdle`。

**Windows 限制（重要）**：Windows 端**不支持重复通知**，未打包 MSIX 时 `cancel()` 亦不可靠，因此**通知功能只能在 Android 真机/模拟器验收**；Windows 仅验证「能初始化、能弹一条」。

---

## 阶段四：数据备份 / 导入导出

新增 `lib/services/backup_service.dart` 与 `lib/dialogs/import_confirm_dialog.dart`；`lib/app_state.dart` 统一存储键与读取方法、暴露 `dataRevision`。

**备份文件格式**（带版本信封）：

```json
{ "app": "health_log", "version": 1, "exportedAt": "<ISO>",
  "data": { "medicines": [...], "healthRecords": [...], "userProfile": {...} } }
```

不导出 `theme_mode`（设备偏好，非业务数据）。

**导出**：`BackupService.buildBackupJson()` → `FilePicker.saveFile(..., bytes: utf8.encode(json))` 让用户选位置（Android 走系统 SAF，用户可存到「下载」；桌面端插件只返回路径不写盘，需自己 `File(path).writeAsString`）。桌面端 `initialDirectory` 用 `getDownloadsDirectory()`。`saveFile` 抛 `UnsupportedError` 时降级为「写入 `getApplicationDocumentsDirectory()` + SnackBar 提示路径」。

**导入**：`FilePicker.pickFiles(type: custom, allowedExtensions: ['json'], withData: true)` → 全量强校验（顶层 Map、`app == 'health_log'`、`version <= 1`、medicines/healthRecords 逐条试跑 `fromJson` 不抛异常、userProfile 为 null 或可解析）→ **任一条失败整体拒绝且零写入** → `ImportConfirmDialog` 展示「将导入 N 条用药 / M 条健康记录 / 档案有无；导出时间 xxx」并提示**将覆盖当前数据** → 确认后写入三个键。

**导入后刷新**：`dataRevision.value++`（阶段一的 `KeyedSubtree` 机制生效），并 `NotificationService.instance.syncAll(...)` 重建通知。

**设置页新增区块**（沿用现有 `ListTile` 风格）：数据备份标题 + 「导出数据备份」+「导入数据备份」。

> 不含「导入前自动快照」——属需求外行为，遵循「不生成任务之外的东西」。

---

## 文档同步（规则第八条要求）

- `README.md`：技术栈新增 6 个依赖；目录结构补 `lib/services/`、`lib/app_state.dart`、`statistics_page.dart`、`import_confirm_dialog.dart`；功能特性改写统计页与用药提醒（Android 已支持真实提醒、Windows 有重复通知限制）；新增「数据备份」章节；「已知问题」删除已修复项、新增 Windows 限制与 Android 精确闹钟授权说明。
- `.trae/rules/healthlog项目规则.md`：目录结构补 `lib/services/`；补充「图表取色一律走 colorScheme」。

---

## 验证方式

需用户提供 Flutter SDK 路径后执行：

```
<flutter>\bin\flutter.bat pub get
<flutter>\bin\flutter.bat analyze
<flutter>\bin\flutter.bat run -d windows      # 验证 阶段一/二/四 + 通知可初始化
<flutter>\bin\flutter.bat run -d <android-id> # 通知必须在此验收
<flutter>\bin\flutter.bat build apk --release # desugaring 问题通常只在 release 暴露
```

- **桌面端手工项**：5 个 tab 可切换且标题与内容一致、无双 AppBar；统计页切范围/切指标/血压双线/空状态正常；导出→改数据→导入→数据回滚且各 tab 显示新数据；启动不崩溃（验证 Windows 通知三参数正确）。
- **Android 手工项**：进「用药」页弹权限申请；添加药物并把时间设为当前 1~2 分钟后（验证完改回，不写测试代码）→ 后台等待通知弹出；改时间后旧时间不再提醒、新时间准时提醒；删除后不再提醒；重启手机后仍生效；`adb shell dumpsys alarm | findstr health_log` 辅助确认。

---

## 风险与降级

| 风险 | 降级方案 |
| --- | --- |
| `pub get` 版本冲突（国内镜像滞后） | 逐个下调版本；`timezone` 交给 pub 自动选 |
| Java 11 不满足插件要求 | 提升到 Java 17（Gradle 8.12 兼容） |
| Android 14+ 未授予精确闹钟 | 已设计探测 + 非精确调度降级 + 设置页授权入口 |
| 国产 ROM 后台限制 | 插件层无法绕过，UI/文档提示加入后台白名单 |
| Windows 不支持重复通知 | 明确以 Android 为验收环境 |
| 统计页数据点过多 | x 轴刻度抽稀；单序列 > 180 点退化为按周取平均 |
| 导入文件损坏 | 全量强校验 + 失败零写入 |
