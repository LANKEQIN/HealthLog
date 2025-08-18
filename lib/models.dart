import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final String dosage;
  final String schedule;
  final TimeOfDay time;

  Medicine({
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.time,
  });

  // 将Medicine对象转换为Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'schedule': schedule,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
    };
  }

  // 从Map创建Medicine对象
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      schedule: json['schedule'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
    );
  }
}

class HealthRecord {
  final DateTime date;
  final String note;
  final double? bloodPressure;
  final double? bloodSugar;

  HealthRecord({
    required this.date,
    required this.note,
    this.bloodPressure,
    this.bloodSugar,
  });

  // 将HealthRecord对象转换为Map
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'note': note,
      'bloodPressure': bloodPressure,
      'bloodSugar': bloodSugar,
    };
  }

  // 从Map创建HealthRecord对象
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      date: DateTime.parse(json['date']),
      note: json['note'],
      bloodPressure: json['bloodPressure'],
      bloodSugar: json['bloodSugar'],
    );
  }
}