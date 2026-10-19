import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models.dart';

/// 用药提醒通知服务
///
/// 负责通知插件的初始化、权限申请，以及按每种药物的服药时间做每日重复调度。
/// 采用单例，因为通知插件与调度状态在整个应用内是唯一的。
class NotificationService {
  NotificationService._();

  /// 全局唯一实例
  static final NotificationService instance = NotificationService._();

  /// 通知插件实例
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 是否已成功初始化
  ///
  /// 未初始化时所有调度方法直接返回，避免在通知不可用时抛异常影响主流程。
  bool _initialized = false;

  /// 通知渠道 ID
  static const String _channelId = 'medicine_reminder';

  /// 通知渠道名称
  static const String _channelName = '用药提醒';

  /// 通知渠道说明
  static const String _channelDescription = '按设定的服药时间提醒用户服药';

  /// Windows 通知激活回调所需的固定 GUID
  ///
  /// 必须是固定值（不能每次随机生成），否则系统无法把通知点击回调关联回本应用。
  static const String _windowsGuid = 'd7a1f3c2-8b45-4e91-9f6a-2c8e5b0d1a37';

  /// 通知显示详情
  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  /// 初始化插件与时区
  ///
  /// 任何环节失败都只记录日志而不抛出，避免因通知不可用导致整个应用无法启动。
  Future<void> init() async {
    try {
      // 时区库必须先加载，否则 zonedSchedule 无法把「本地时刻」解析成绝对时间
      tzdata.initializeTimeZones();
      await _setLocalTimeZone();

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // 初始化阶段不主动弹权限框，等用户进入用药页时再申请，避免开屏就打断
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'HealthLog'),
        windows: WindowsInitializationSettings(
          appName: 'HealthLog',
          appUserModelId: 'HealthLog.MedicineLog.V1',
          guid: _windowsGuid,
        ),
      );

      await _plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      _initialized = true;
    } catch (error) {
      debugPrint('通知服务初始化失败，提醒功能将不可用：$error');
    }
  }

  /// 设置时区库的本地时区
  ///
  /// tz 初始化后默认是 UTC。若不修正，用户设的「早 8 点」会被当成 UTC 8 点，
  /// 在 +8 时区实际会晚 8 小时触发，因此这一步是提醒时间正确的前提。
  Future<void> _setLocalTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // 少数平台可能给出 tz 数据库里不存在的时区名，退回按当前 UTC 偏移构造。
      // 注意 Etc/GMT 的符号与直觉相反：东八区对应 Etc/GMT-8。
      final offsetHours = DateTime.now().timeZoneOffset.inHours;
      final name = offsetHours == 0
          ? 'Etc/GMT'
          : 'Etc/GMT${offsetHours > 0 ? '-' : '+'}${offsetHours.abs()}';
      tz.setLocalLocation(tz.getLocation(name));
    }
  }

  /// 通知被点击时的回调
  void _onNotificationTap(NotificationResponse response) {
    // 目前点击通知只需打开应用，暂无额外跳转需求
    debugPrint('用户点击了用药提醒：${response.payload}');
  }

  /// 申请通知与精确闹钟权限
  ///
  /// 在用药页首次进入时调用。系统对已授权或已拒绝的权限不会重复弹窗，
  /// 因此可以安全地重复调用。
  Future<void> requestPermissions() async {
    if (!_initialized) return;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        // Android 12+ 精确闹钟属于特殊权限，需要单独申请
        await android.requestExactAlarmsPermission();
      }
    } catch (error) {
      debugPrint('申请通知权限失败：$error');
    }
  }

  /// 全量同步所有用药提醒
  ///
  /// 采用「先全部取消、再按当前列表重建」的策略：这样增/删/改都无需判断具体变化，
  /// 也不会因为列表索引漂移而残留无法回收的孤儿通知。
  Future<void> syncAll(List<Medicine> medicines) async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAllPendingNotifications();
      final scheduleMode = await _resolveScheduleMode();
      final now = tz.TZDateTime.now(tz.local);
      // 只取到「天」，用于判断用药周期是否已结束
      final today = DateTime(now.year, now.month, now.day);

      for (var i = 0; i < medicines.length; i++) {
        final medicine = medicines[i];
        // 用药周期已结束的药物不再提醒，否则疗程结束后仍会天天打扰
        if (medicine.endDate != null && medicine.endDate!.isBefore(today)) {
          continue;
        }
        for (var t = 0; t < medicine.scheduleTimes.length; t++) {
          await _scheduleOne(i, t, medicine, scheduleMode);
        }
      }
    } catch (error) {
      debugPrint('同步用药提醒失败：$error');
    }
  }

  /// 调度单条每日重复的服药提醒
  Future<void> _scheduleOne(
    int medicineIndex,
    int timeIndex,
    Medicine medicine,
    AndroidScheduleMode scheduleMode,
  ) async {
    final time = medicine.scheduleTimes[timeIndex];
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // 当天该时刻已过则顺延到明天，保证首次触发时间一定在未来
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _notificationId(medicineIndex, timeIndex),
      title: '服药提醒',
      body: '请服用 ${medicine.name} ${medicine.dosage}${medicine.dosageUnit}',
      scheduledDate: next,
      notificationDetails: _details,
      androidScheduleMode: scheduleMode,
      // 匹配「时刻」表示每天同一时间重复，Android 侧只占一条待触发通知
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 判断当前可用的调度模式
  ///
  /// Android 14+ 起精确闹钟默认不授予，此时精确模式会抛异常，
  /// 因此先探测再选择；未授权时退回非精确调度（可能晚几分钟，但不会漏提醒）。
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final canExact = await android?.canScheduleExactNotifications() ?? false;
      return canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  /// 通知 ID 约定：药品下标 * 100 + 当日服药时间点下标
  ///
  /// 之所以需要时间点下标：一种药一天可能服用多次，必须逐时间点区分。
  /// 之所以不新增持久化 id 字段：同步策略是「全量重排」，索引变化不会残留通知。
  int _notificationId(int medicineIndex, int timeIndex) =>
      medicineIndex * 100 + timeIndex;
}
