# HealthLog · 用药日志

> 一款基于 Flutter 开发的本地化「用药 · 健康」记录管理应用，界面为中文，数据全部保存在设备本地，无需联网。

HealthLog 面向需要长期规律服药、并对身体指标进行日常记录的用户（如高血压、糖尿病、高血脂、心脑血管慢病群体）。应用提供用药提醒、健康指标记录、数据统计可视化、多角色个人档案、数据备份与主题切换等能力。

---

## 功能特性

### 1. 用药提醒（用药）

- 以卡片列表展示已添加的药物，支持**添加 / 编辑 / 删除**（长按卡片弹出操作菜单）。
- 药物信息字段：名称、俗称（别名）、剂量 + 单位、服用说明、服药时间列表、服药时间类型、用药周期（开始 / 结束日期）、是否为处方药（红色「处方药」标记）。
- 服药时间类型：早餐前 / 早餐后 / 午餐前 / 午餐后 / 晚餐前 / 晚餐后 / 睡前。
- 添加 / 编辑采用 **三步向导（Stepper）**：基本信息 → 服药安排 → 用药周期，每步带必填校验。
- 内置**常用药物模板库**（20+ 种常用药，覆盖降压、降糖、降脂、心脑血管用药），支持按分类筛选与关键字搜索，可一键套用模板。
- **真正的本地通知提醒**：进入用药页时申请通知权限，之后按每种药物的服药时间每日定时推送本地通知；药物的增 / 删 / 改会立即重建提醒；用药周期（结束日期）已过的药物不再提醒；手机重启后提醒会自动恢复。

> 平台差异：Android / iOS 支持每日重复提醒；**Windows 桌面端不支持重复通知**（系统限制），且未打包为 MSIX 时取消通知不可靠，因此桌面端不作为提醒功能的验收环境。

### 2. 健康记录（记录）

- 记录并展示用户的健康指标，支持**添加 / 编辑 / 删除**（删除带二次确认）。
- 可记录字段：日期、身体状况描述、收缩压（高压）、舒张压（低压）、血糖、体重（kg）、身高（cm）、心率（bpm）、体温（°C）；除日期与描述外均为可选。

> 说明：界面中的「连接监测仪器」按钮为**预留接口**，尚未接入真实设备。

### 3. 数据统计（统计）

- 按**时间范围**（近 7 天 / 近 30 天 / 近 90 天 / 全部）查看指标。
- **指标概览卡片**：范围内最新一条记录的血压、血糖、体重、心率、体温，以及记录条数。
- **趋势折线图**：可切换血压（收缩压 / 舒张压双线）、血糖、体重、心率、体温 5 类指标，支持触摸查看具体数值与日期。
- 无数据时展示空状态提示；图表配色跟随应用主题（浅色 / 深色自动适配）。

### 4. 用户档案（档案）

- 支持三种用户角色：**患者 / 监护人 / 医师**，通过分段按钮切换，不同角色展示不同的扩展信息。
- 基本信息：姓名、电话、邮箱、身份证号。
- 患者信息：性别、出生日期、病史、过敏史。
- 监护人信息：与患者关系、紧急联系电话。
- 医师信息：医院、科室、医师执业证书编号、专业领域。
- 档案信息保存到本地，下次进入自动回填。

### 5. 设置（设置）

- **主题设置**：支持浅色 / 深色 / 跟随系统三种主题模式，选择后立即生效并持久化保存。
- **数据备份**：导出全部本地数据为 JSON 文件；从 JSON 文件导入恢复（导入前会展示内容概要并要求确认，导入将覆盖当前数据）。
- **通知权限**：误拒通知权限后，可在这里重新发起申请。

---

## 技术栈

| 项目 | 说明 |
| --- | --- |
| 框架 | Flutter（Dart SDK `^3.8.1`） |
| UI | Material 3（`useMaterial3: true`） |
| 本地存储 | [`shared_preferences`](https://pub.dev/packages/shared_preferences) `^2.3.2` |
| 图表 | [`fl_chart`](https://pub.dev/packages/fl_chart) `^1.2.0` |
| 本地通知 | [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) `^20.1.0` |
| 时区 | [`timezone`](https://pub.dev/packages/timezone) `^0.10.1`、[`flutter_timezone`](https://pub.dev/packages/flutter_timezone) `^5.1.1` |
| 备份文件 | [`path_provider`](https://pub.dev/packages/path_provider) `^2.1.5`、[`file_picker`](https://pub.dev/packages/file_picker) `^11.0.3` |
| 图标 | `cupertino_icons` `^1.0.8`、Material Icons |
| 代码规范 | `flutter_lints` `^5.0.0` |

> 依赖版本按 Dart 3.8 锁定：`flutter_local_notifications` 21+ 要求 Dart 3.10、`file_picker` 12+ 要求 Dart 3.10，故分别锁定在 20.x 与 11.x。若将来升级 Flutter SDK，可整体放开这些版本约束（注意 fln 20 与 21 的 API 参数形式不同）。

---

## 目录结构

```
HealthLog-1/
├── lib/
│   ├── main.dart                     # 应用入口、主题配置、底部导航主页
│   ├── models.dart                   # 数据模型（Medicine / HealthRecord / UserProfile 等）
│   ├── app_state.dart                # 存储键常量、全局数据版本号、统一读取方法
│   ├── pages/                        # 页面
│   │   ├── medicine_page.dart        # 用药提醒页
│   │   ├── health_record_page.dart   # 健康记录页
│   │   ├── statistics_page.dart      # 数据统计页（概览卡片 + 趋势图）
│   │   ├── user_profile_page.dart    # 用户档案页
│   │   └── settings_page.dart        # 设置页（主题 / 数据备份 / 通知权限）
│   ├── dialogs/                      # 弹窗组件
│   │   ├── medicine_dialog.dart              # 添加/编辑药物（三步向导 + 模板选择）
│   │   ├── health_record_dialog.dart         # 添加健康记录
│   │   ├── edit_health_record_dialog.dart    # 编辑健康记录
│   │   └── import_confirm_dialog.dart        # 导入备份前的确认弹窗
│   └── services/                     # 服务层
│       ├── notification_service.dart # 通知初始化、权限、每日提醒调度
│       └── backup_service.dart       # 备份导出 / 解析校验 / 恢复
├── android/ ios/ web/ windows/ macos/ linux/  # 各平台原生脚手架
├── test/                             # 测试目录
├── pubspec.yaml                      # 依赖与项目配置
├── .trae/rules/healthlog项目规则.md   # 本项目的开发规则
└── .trae/documents/                  # 方案与计划文档
```

底部导航共 5 个标签：**用药 / 记录 / 统计 / 档案 / 设置**，标题栏由 `MainScreen` 统一提供并随标签切换。

---

## 数据存储

业务数据通过 `shared_preferences` 以 JSON 字符串形式持久化在设备本地，不依赖任何后端服务。存储键如下：

| 键名 | 类型 | 说明 |
| --- | --- | --- |
| `medicines` | JSON 数组 | 用药提醒列表（`Medicine.toJson` / `fromJson`） |
| `healthRecords` | JSON 数组 | 健康记录列表（`HealthRecord.toJson` / `fromJson`） |
| `userProfile` | JSON 对象 | 用户档案（`UserProfile.toJson` / `fromJson`） |
| `theme_mode` | 字符串 | 主题模式：`light` / `dark` / `system` |

备份文件为带版本信封的 JSON，不包含 `theme_mode`（属于设备偏好而非业务数据）：

```json
{
  "app": "health_log",
  "version": 1,
  "exportedAt": "2026-10-18T21:30:00.000",
  "data": {
    "medicines": [],
    "healthRecords": [],
    "userProfile": {}
  }
}
```

导入时会做全量校验（应用标识、版本号、逐条反序列化），任意一条不合法即整体拒绝且不写入任何数据。

---

## 快速开始

### 环境要求

- 已安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（Dart `^3.8.1`，即 Flutter 3.32 及以上）
- 对应平台工具链（如 Android Studio、Visual Studio、Xcode 等）

### 运行步骤

```bash
# 1. 获取依赖
flutter pub get

# 2. 查看可用设备
flutter devices

# 3. 运行（以 Windows 桌面为例，也可指定 Android / Web 等）
flutter run -d windows

# 可选：代码静态检查
flutter analyze

# 可选：运行测试
flutter test
```

运行环境：当前开发环境为 **Windows 11**，已安装 Android Studio 与 Visual Studio，可使用 Android / Windows 目标进行调试。

> 用药提醒功能请在 **Android 真机或模拟器**上验证；Windows 桌面端仅可验证通知能够初始化与弹出一条。

> **Android 打包说明**：本机 Android 构建做了两处环境适配 ——
> ① 所有 Android 子工程统一使用本机已安装的 NDK `27.0.12077973`（见 `android/build.gradle.kts`），
> 避免 `jni` 插件默认拉取本机未安装的 Flutter 默认 NDK（`28.2.13676358`）；
> ② 关闭 Kotlin 增量编译（`android/gradle.properties` 中的 `kotlin.incremental=false`），
> 规避插件源码（C 盘 pub cache）与工程（D 盘）分处不同盘符时的增量缓存报错。
> 执行 `flutter build apk --release` 即可导出 APK，产物为 `build/app/outputs/flutter-apk/app-release.apk`。

---

## 已知限制与后续计划

- **Web 端不再支持**：本地通知与文件备份依赖原生能力，且部分实现引入了 `dart:io`，因此 `flutter build web` 当前不可用。若需恢复 Web 支持，需要为文件读写引入条件导入。
- **Windows 桌面端不支持重复通知**（系统限制），也未打包 MSIX 时取消通知不可靠，服药提醒需在 Android / iOS 上验收。
- **Android 精确闹钟权限**：Android 12+ 需用户授予「闹钟与提醒」特殊权限；未授权时应用会自动降级为非精确调度（可能晚几分钟），可在「设置 → 通知权限」重新申请。
- 部分国产 ROM（小米 / 华为 / OPPO 等）的后台限制可能导致定时通知不触发，需将应用加入后台白名单。
- 「连接监测仪器」为预留接口，后续可对接蓝牙血压计 / 血糖仪等设备。
- 药物模板中的「解热镇痛与感冒用药」「外用药物」两个分类暂无数据，可按需扩充。
- 尚未提供全局搜索与自动云备份。

---

## 更新维护约定

- 修改代码前请先阅读 [.trae/rules/healthlog项目规则.md](file:///d:/HealthLog-1/.trae/rules/healthlog项目规则.md)。
- 新增依赖、变更目录结构或数据存储格式时，请同步更新本 README。
