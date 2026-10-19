# HealthLog 项目规则

> 本文件是本项目的开发协作规则，供开发者与 AI 助手共同遵守。开始任何编码任务前请先阅读本文件与 [README.md](file:///d:/HealthLog-1/README.md)。

---

## 一、项目定位

- **项目名**：HealthLog · 用药日志（`health_log`）
- **类型**：基于 Flutter 的本地化「用药 + 健康记录」管理应用
- **用户**：需要长期规律服药并记录身体指标的慢病人群
- **形态**：纯本地应用，数据全部存储在设备端，不依赖后端服务

四个核心模块：用药提醒、健康记录、用户档案、主题设置。

---

## 二、语言与沟通

1. 与用户沟通、代码注释、文档、UI 文案一律使用**中文**。
2. 代码中的**注释必须使用中文**，且要解释「为什么」而非重复「做什么」。
3. 每个回复开头称呼用户为 **「幽幽子大人」**。

---

## 三、技术栈与约束

- 框架：Flutter（Dart SDK `^3.8.1`），UI 使用 **Material 3**。
- 本地存储：`shared_preferences`（JSON 字符串），**不得引入新的后端或云存储依赖**。
- 引入新的第三方依赖前必须先在回复中说明用途并征得用户同意。
- 当前已批准的第三方依赖（版本按 Dart 3.8 锁定，不要随意升到要求 Dart 3.10 的新版本）：
  - `fl_chart ^1.2.0` — 统计页折线图
  - `flutter_local_notifications ^20.1.0` — 本地用药提醒（20.x 为具名参数，21+ 需 Dart 3.10）
  - `timezone ^0.10.1` + `flutter_timezone ^5.1.1` — 通知按本地时区调度
  - `path_provider ^2.1.5` + `file_picker ^11.0.3` — 数据备份导出 / 导入（11.x 为静态方法 API，12+ 需 Dart 3.10）
- 支持的平台：Android / iOS / Web / Windows / macOS / Linux，改动应尽量保持跨平台兼容。
  - 注意：本地通知与文件备份依赖原生能力，且 `lib/services/backup_service.dart` 引入了 `dart:io`，因此 Web 目标当前不可构建。
- 开发环境：Windows 11，已安装 Android Studio 与 Visual Studio。

---

## 四、代码规范

1. **文档先行**：每一次开始写代码之前，先阅读与该任务相关的文档与源文件。
2. **冲突上报**：若现有文档约束与目标任务存在冲突，先向用户说明，不要盲目强干。
3. **不越界**：只完成被明确要求的任务，不要擅自生成测试、示例、脚手架或其他无关内容（除非用户明确要求）。
4. **文件规模**：单个文件代码量尽量控制在 **2000 行以内**；若超出，应按职责拆分为多个文件。
5. 遵循 `flutter_lints` 规则，提交前尽量保证 `flutter analyze` 无新增告警。
6. 保持代码整洁：不遗留 `TODO` / 占位符 / 注释掉的死代码，交付的代码应可直接运行。

---

## 五、目录与文件组织

```
lib/
├── main.dart        → 入口 + 主题 + 底部导航
├── models.dart      → 全部数据模型（含 toJson / fromJson）
├── app_state.dart   → 存储键常量、全局数据版本号、统一读取方法
├── pages/           → 页面级组件（每页一个文件）
├── dialogs/         → 弹窗级组件（每弹窗一个文件）
└── services/        → 服务层（通知调度、数据备份等跨页面能力）
```

- 新增页面放 `lib/pages/`，新增弹窗放 `lib/dialogs/`，新增服务放 `lib/services/`，数据模型统一放 `lib/models.dart`。
- 读取 `shared_preferences` 一律使用 `lib/app_state.dart` 中的键名常量与 `load*` 方法，不要在各页面里重复写字符串字面量与反序列化逻辑。
- 命名：文件用 `snake_case.dart`，类用 `UpperCamelCase`，变量/方法用 `lowerCamelCase`。
- 类与公开成员需提供中文文档注释（`///`）。

---

## 六、数据与持久化

- 所有持久化统一走 `shared_preferences`，键名固定为：

  | 键名 | 说明 |
  | --- | --- |
  | `medicines` | 用药提醒列表（JSON 数组） |
  | `healthRecords` | 健康记录列表（JSON 数组） |
  | `userProfile` | 用户档案（JSON 对象） |
  | `theme_mode` | 主题模式 `light` / `dark` / `system` |

- 新增字段时**必须同步维护对应模型的 `toJson()` 与 `fromJson()`**，并对旧数据做兼容处理（缺失字段给默认值），避免历史数据反序列化失败。
- 模型定义集中在 `lib/models.dart`，不要在页面里私自定义重复模型。
- 枚举（如 `MedicineScheduleType`、`UserRole`、`Gender`）持久化时存 `index`，**不要调整已有枚举成员的顺序**，否则会破坏历史数据。

---

## 七、UI 与主题规范

- 一律使用 `Theme.of(context).colorScheme` 取色，**避免硬编码颜色**（除语义色如处方药红色警示外）。
- 主题通过 `main.dart` 的 `AppThemeMode` 控制，主题变更需持久化到 `theme_mode`。
- 新增设置项时，沿用 `settings_page.dart` 中 `RadioListTile` 的交互风格。

---

## 八、变更与提交约定

1. 修改涉及**依赖、目录结构或数据存储格式**时，同步更新 `README.md`。
2. 修改涉及**团队协作方式或技术约束**时，同步更新本规则文件。
3. 未经用户明确要求，**不要执行 `git commit` / `git push`** 等提交操作。
