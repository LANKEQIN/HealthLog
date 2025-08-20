import 'package:flutter/material.dart';

/// 药物信息数据模型
///
/// 用于存储和管理用户的药物信息，包括名称、剂量、服用说明和提醒时间
class Medicine {
  /// 药物名称
  final String name;
  
  /// 药物剂量
  final String dosage;
  
  /// 剂量单位
  final String dosageUnit;
  
  /// 服用说明
  final String schedule;
  
  /// 提醒时间
  final TimeOfDay time;

  /// 每日服用次数
  final int timesPerDay;

  /// 服药时间列表
  final List<TimeOfDay> scheduleTimes;

  /*
  /// 是否饭前服用
  final bool beforeMeal;
  */

  /// 用药开始日期
  final DateTime? startDate;

  /// 用药结束日期
  final DateTime? endDate;

  /// 详细的服药时间类型
  final List<MedicineScheduleType> scheduleTypes;
  
  /// 是否为处方药
  final bool isPrescription;

  /// 创建Medicine实例
  ///
  /// [name] - 药物名称
  /// [dosage] - 药物剂量
  /// [dosageUnit] - 剂量单位
  /// [schedule] - 服用说明
  /// [time] - 提醒时间
  /// [timesPerDay] - 每日服用次数
  /// [scheduleTimes] - 服药时间列表
  /// [beforeMeal] - 是否饭前服用
  /// [startDate] - 用药开始日期
  /// [endDate] - 用药结束日期
  /// [scheduleTypes] - 详细的服药时间类型列表
  /// [isPrescription] - 是否为处方药
  Medicine({
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.schedule,
    required this.time,
    this.timesPerDay = 1,
    List<TimeOfDay>? scheduleTimes,
    /* this.beforeMeal = false, */
    this.startDate,
    this.endDate,
    List<MedicineScheduleType>? scheduleTypes,
    this.isPrescription = false,
  }) : 
       scheduleTimes = scheduleTimes ?? [time],
       scheduleTypes = scheduleTypes ?? [];

  /// 将Medicine对象转换为JSON格式的Map
  ///
  /// 用于数据持久化存储
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'schedule': schedule,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'timesPerDay': timesPerDay,
      'scheduleTimes': scheduleTimes.map((time) => {
        'hour': time.hour,
        'minute': time.minute,
      }).toList(),
      /* 'beforeMeal': beforeMeal, */
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'scheduleTypes': scheduleTypes.map((type) => type.index).toList(),
      'isPrescription': isPrescription,
    };
  }

  /// 从JSON格式的Map创建Medicine对象
  ///
  /// 用于从存储中恢复数据
  /// [json] - 包含药物信息的JSON数据
  factory Medicine.fromJson(Map<String, dynamic> json) {
    List<TimeOfDay> times = [];
    if (json['scheduleTimes'] != null) {
      times = (json['scheduleTimes'] as List).map((timeJson) => TimeOfDay(
        hour: timeJson['hour'],
        minute: timeJson['minute'],
      )).toList();
    }

    List<MedicineScheduleType> types = [];
    if (json['scheduleTypes'] != null) {
      types = (json['scheduleTypes'] as List).map((typeIndex) => MedicineScheduleType.values[typeIndex]).toList();
    }

    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      dosageUnit: json['dosageUnit'] ?? '',
      schedule: json['schedule'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      timesPerDay: json['timesPerDay'] ?? 1,
      scheduleTimes: times,
      /* beforeMeal: json['beforeMeal'] ?? false, */
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      scheduleTypes: types,
      isPrescription: json['isPrescription'] ?? false,
    );
  }
}

/// 药物服用时间类型枚举
///
/// 定义药物在一天中的服用时间类型，包括早餐、午餐、晚餐前后等
enum MedicineScheduleType {
  /// 早餐前
  beforeBreakfast,
  
  /// 早餐后
  afterBreakfast,
  
  /// 午餐前
  beforeLunch,
  
  /// 午餐后
  afterLunch,
  
  /// 晚餐前
  beforeDinner,
  
  /// 晚餐后
  afterDinner,
  
  /// 睡前
  beforeSleep,
}

/// 健康记录数据模型
///
/// 用于存储和管理用户的健康信息，包括日期、身体状况、血压和血糖数据
class HealthRecord {
  /// 记录日期
  final DateTime date;
  
  /// 身体状况描述
  final String note;
  
  /// 血压值（可选）
  final double? bloodPressure;
  
  /// 血糖值（可选）
  final double? bloodSugar;

  /// 创建HealthRecord实例
  ///
  /// [date] - 记录日期
  /// [note] - 身体状况描述
  /// [bloodPressure] - 血压值（可选）
  /// [bloodSugar] - 血糖值（可选）
  HealthRecord({
    required this.date,
    required this.note,
    this.bloodPressure,
    this.bloodSugar,
  });

  /// 将HealthRecord对象转换为JSON格式的Map
  ///
  /// 用于数据持久化存储
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'note': note,
      'bloodPressure': bloodPressure,
      'bloodSugar': bloodSugar,
    };
  }

  /// 从JSON格式的Map创建HealthRecord对象
  ///
  /// 用于从存储中恢复数据
  /// [json] - 包含健康记录信息的JSON数据
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      date: DateTime.parse(json['date']),
      note: json['note'],
      bloodPressure: json['bloodPressure'],
      bloodSugar: json['bloodSugar'],
    );
  }
}

/// 应用主题模式枚举
///
/// 用于定义应用支持的主题模式：浅色、深色和跟随系统
enum AppThemeMode {
  /// 浅色主题
  light,
  
  /// 深色主题
  dark,
  
  /// 跟随系统设置
  system,
}

/// 预设药物模板列表
///
/// 包含常用药物的预设信息，方便用户快速添加
class MedicineTemplate {
  final String name;
  final String dosage;
  final String dosageUnit;
  final String schedule;
  final int timesPerDay;
  final List<TimeOfDay> scheduleTimes;
  final List<MedicineScheduleType> scheduleTypes;

  MedicineTemplate({
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.schedule,
    required this.timesPerDay,
    required this.scheduleTimes,
    required this.scheduleTypes,
  });

  /// 预设的常用药物模板
  static List<MedicineTemplate> get commonMedicines => [
    MedicineTemplate(
      name: '阿司匹林',
      dosage: '100',
      dosageUnit: '毫克',
      schedule: '饭后服用，避免空腹',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '阿托伐他汀',
      dosage: '20',
      dosageUnit: '毫克',
      schedule: '晚上服用，用水吞服',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 20, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeSleep],
    ),
    MedicineTemplate(
      name: '二甲双胍',
      dosage: '500',
      dosageUnit: '毫克',
      schedule: '随餐服用，分次服用',
      timesPerDay: 2,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast, MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '缬沙坦',
      dosage: '80',
      dosageUnit: '毫克',
      schedule: '早上服用，可与食物同服',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    MedicineTemplate(
      name: '氨氯地平',
      dosage: '5',
      dosageUnit: '毫克',
      schedule: '每天一次，早上服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
  ];
}
