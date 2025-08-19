import 'package:flutter/material.dart';

/// 药物信息数据模型
///
/// 用于存储和管理用户的药物信息，包括名称、剂量、服用说明和提醒时间
class Medicine {
  /// 药物名称
  final String name;
  
  /// 药物剂量
  final String dosage;
  
  /// 服用说明
  final String schedule;
  
  /// 提醒时间
  final TimeOfDay time;

  /// 每日服用次数
  final int timesPerDay;

  /// 服药时间列表
  final List<TimeOfDay> scheduleTimes;

  /// 是否饭前服用
  final bool beforeMeal;

  /// 创建Medicine实例
  ///
  /// [name] - 药物名称
  /// [dosage] - 药物剂量
  /// [schedule] - 服用说明
  /// [time] - 提醒时间
  /// [timesPerDay] - 每日服用次数
  /// [scheduleTimes] - 服药时间列表
  /// [beforeMeal] - 是否饭前服用
  Medicine({
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.time,
    this.timesPerDay = 1,
    List<TimeOfDay>? scheduleTimes,
    this.beforeMeal = false,
  }) : scheduleTimes = scheduleTimes ?? [time];

  /// 将Medicine对象转换为JSON格式的Map
  ///
  /// 用于数据持久化存储
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
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
      'beforeMeal': beforeMeal,
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

    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      schedule: json['schedule'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      timesPerDay: json['timesPerDay'] ?? 1,
      scheduleTimes: times,
      beforeMeal: json['beforeMeal'] ?? false,
    );
  }
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