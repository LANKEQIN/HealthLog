import 'package:flutter/material.dart';

/// 药物信息数据模型
///
/// 用于存储和管理用户的药物信息，包括名称、剂量、服用说明和提醒时间
class Medicine {
  /// 药物名称
  final String name;
  
  /// 药物俗称
  final String? commonName;
  
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
  /// [commonName] - 药物俗称
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
    this.commonName,
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
      'commonName': commonName,
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
      commonName: json['commonName'],
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
  
  /// 收缩压（高压，可选）
  final double? systolicPressure;
  
  /// 舒张压（低压，可选）
  final double? diastolicPressure;
  
  /// 血糖值（可选）
  final double? bloodSugar;

  /// 体重（可选）
  final double? weight;

  /// 身高（可选）
  final double? height;

  /// 心率（可选）
  final int? heartRate;

  /// 体温（可选）
  final double? temperature;

  /// 创建HealthRecord实例
  ///
  /// [date] - 记录日期
  /// [note] - 身体状况描述
  /// [systolicPressure] - 收缩压（高压，可选）
  /// [diastolicPressure] - 舒张压（低压，可选）
  /// [bloodSugar] - 血糖值（可选）
  /// [weight] - 体重（可选）
  /// [height] - 身高（可选）
  /// [heartRate] - 心率（可选）
  /// [temperature] - 体温（可选）
  HealthRecord({
    required this.date,
    required this.note,
    this.systolicPressure,
    this.diastolicPressure,
    this.bloodSugar,
    this.weight,
    this.height,
    this.heartRate,
    this.temperature,
  });

  /// 将HealthRecord对象转换为JSON格式的Map
  ///
  /// 用于数据持久化存储
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'note': note,
      'systolicPressure': systolicPressure,
      'diastolicPressure': diastolicPressure,
      'bloodSugar': bloodSugar,
      'weight': weight,
      'height': height,
      'heartRate': heartRate,
      'temperature': temperature,
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
      systolicPressure: json['systolicPressure'],
      diastolicPressure: json['diastolicPressure'],
      bloodSugar: json['bloodSugar'],
      weight: json['weight'],
      height: json['height'],
      heartRate: json['heartRate'],
      temperature: json['temperature'],
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
      dosage: '1',
      dosageUnit: '片',
      schedule: '饭后服用，避免空腹',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '阿托伐他汀',
      dosage: '2',
      dosageUnit: '片',
      schedule: '晚上服用，用水吞服',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 20, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeSleep],
    ),
    MedicineTemplate(
      name: '二甲双胍',
      dosage: '5',
      dosageUnit: '片',
      schedule: '随餐服用，分次服用',
      timesPerDay: 2,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast, MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '缬沙坦',
      dosage: '1',
      dosageUnit: '片',
      schedule: '早上服用，可与食物同服',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    MedicineTemplate(
      name: '氨氯地平',
      dosage: '1',
      dosageUnit: '片',
      schedule: '每天一次，早上服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    // 高血压药物 (降压药)
    MedicineTemplate(
      name: '硝苯地平',
      dosage: '1',
      dosageUnit: '片',
      schedule: '每日一次，空腹服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast],
    ),
    MedicineTemplate(
      name: '美托洛尔',
      dosage: '1',
      dosageUnit: '片',
      schedule: '每日两次，饭后服用',
      timesPerDay: 2,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast, MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '卡托普利',
      dosage: '1',
      dosageUnit: '片',
      schedule: '饭前服用，每日2-3次',
      timesPerDay: 2,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 30), TimeOfDay(hour: 18, minute: 30)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast, MedicineScheduleType.beforeDinner],
    ),
    MedicineTemplate(
      name: '厄贝沙坦',
      dosage: '1',
      dosageUnit: '片',
      schedule: '每日一次，空腹服用效果更佳',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast],
    ),
    MedicineTemplate(
      name: '替米沙坦',
      dosage: '1',
      dosageUnit: '片',
      schedule: '每日一次，可在任何时间服用但应在每天同一时间服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    // 糖尿病药物 (降糖药)
    MedicineTemplate(
      name: '格列美脲',
      dosage: '2',
      dosageUnit: '毫克',
      schedule: '每日一次，早餐前服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast],
    ),
    MedicineTemplate(
      name: '瑞格列奈',
      dosage: '1',
      dosageUnit: '毫克',
      schedule: '餐前15分钟服用，不进餐则不服用',
      timesPerDay: 3,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 18, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast, MedicineScheduleType.beforeLunch, MedicineScheduleType.beforeDinner],
    ),
    MedicineTemplate(
      name: '西格列汀',
      dosage: '100',
      dosageUnit: '毫克',
      schedule: '每日一次，可在每天任意时间服用，不受进餐影响',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    MedicineTemplate(
      name: '恩格列净',
      dosage: '10',
      dosageUnit: '毫克',
      schedule: '每日清晨服用，餐前或餐后均可',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast],
    ),
    MedicineTemplate(
      name: '胰岛素',
      dosage: '10',
      dosageUnit: '单位',
      schedule: '根据医生建议和血糖情况调整剂量',
      timesPerDay: 2,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 21, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast, MedicineScheduleType.beforeSleep],
    ),
    // 高血脂药物 (降脂药)
    MedicineTemplate(
      name: '阿托伐他汀钙',
      dosage: '20',
      dosageUnit: '毫克',
      schedule: '每日一次，晚上服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 20, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeSleep],
    ),
    MedicineTemplate(
      name: '瑞舒伐他汀',
      dosage: '10',
      dosageUnit: '毫克',
      schedule: '每日一次，空腹服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast],
    ),
    MedicineTemplate(
      name: '辛伐他汀',
      dosage: '20',
      dosageUnit: '毫克',
      schedule: '每日一次，晚餐时服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '非诺贝特',
      dosage: '200',
      dosageUnit: '毫克',
      schedule: '每日一次，与餐同服',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    MedicineTemplate(
      name: '依折麦布',
      dosage: '10',
      dosageUnit: '毫克',
      schedule: '每日一次，可在一天内任何时间服用，可与食物同服或分开服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast],
    ),
    // 心脑血管疾病药物
    MedicineTemplate(
      name: '硫酸氢氯吡格雷',
      dosage: '75',
      dosageUnit: '毫克',
      schedule: '每日一次，空腹服用',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast],
    ),
    MedicineTemplate(
      name: '华法林',
      dosage: '2.5',
      dosageUnit: '毫克',
      schedule: '每日固定时间服用，避免漏服',
      timesPerDay: 1,
      scheduleTimes: [TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '银杏叶提取物',
      dosage: '40',
      dosageUnit: '毫克',
      schedule: '每日三次，饭前服用',
      timesPerDay: 3,
      scheduleTimes: [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 18, minute: 0)],
      scheduleTypes: [MedicineScheduleType.beforeBreakfast, MedicineScheduleType.beforeLunch, MedicineScheduleType.beforeDinner],
    ),
    MedicineTemplate(
      name: '曲美他嗪',
      dosage: '20',
      dosageUnit: '毫克',
      schedule: '每日三次，饭后服用',
      timesPerDay: 3,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 13, minute: 0), TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast, MedicineScheduleType.afterLunch, MedicineScheduleType.afterDinner],
    ),
    MedicineTemplate(
      name: '尼莫地平',
      dosage: '30',
      dosageUnit: '毫克',
      schedule: '每日三次，饭后服用',
      timesPerDay: 3,
      scheduleTimes: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 13, minute: 0), TimeOfDay(hour: 19, minute: 0)],
      scheduleTypes: [MedicineScheduleType.afterBreakfast, MedicineScheduleType.afterLunch, MedicineScheduleType.afterDinner],
    ),
  ];
}

/// 用户角色枚举
///
/// 定义系统的三种用户角色：患者、监护人、医师
enum UserRole {
  /// 患者角色
  patient,
  
  /// 监护人角色
  guardian,
  
  /// 医师角色
  doctor,
}

/// 性别枚举
///
/// 定义用户性别
enum Gender {
  /// 男性
  male,
  
  /// 女性
  female,
}

/// 用户档案数据模型
///
/// 用于存储和管理用户的基本信息和角色相关信息
class UserProfile {
  /// 用户角色
  final UserRole role;
  
  /// 姓名
  final String name;
  
  /// 电话
  final String phone;
  
  /// 邮箱
  final String email;
  
  /// 身份证号
  final String idNumber;
  
  /// 患者特有信息
  final PatientInfo? patientInfo;
  
  /// 监护人特有信息
  final GuardianInfo? guardianInfo;
  
  /// 医师特有信息
  final DoctorInfo? doctorInfo;

  /// 创建UserProfile实例
  ///
  /// [role] - 用户角色
  /// [name] - 姓名
  /// [phone] - 电话
  /// [email] - 邮箱
  /// [idNumber] - 身份证号
  /// [patientInfo] - 患者特有信息（可选）
  /// [guardianInfo] - 监护人特有信息（可选）
  /// [doctorInfo] - 医师特有信息（可选）
  UserProfile({
    required this.role,
    required this.name,
    required this.phone,
    required this.email,
    required this.idNumber,
    this.patientInfo,
    this.guardianInfo,
    this.doctorInfo,
  });

  /// 将UserProfile对象转换为JSON格式的Map
  ///
  /// 用于数据持久化存储
  Map<String, dynamic> toJson() {
    return {
      'role': role.index,
      'name': name,
      'phone': phone,
      'email': email,
      'idNumber': idNumber,
      'patientInfo': patientInfo?.toJson(),
      'guardianInfo': guardianInfo?.toJson(),
      'doctorInfo': doctorInfo?.toJson(),
    };
  }

  /// 从JSON格式的Map创建UserProfile对象
  ///
  /// 用于从存储中恢复数据
  /// [json] - 包含用户档案信息的JSON数据
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      role: UserRole.values[json['role']],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      idNumber: json['idNumber'],
      patientInfo: json['patientInfo'] != null 
          ? PatientInfo.fromJson(json['patientInfo']) 
          : null,
      guardianInfo: json['guardianInfo'] != null 
          ? GuardianInfo.fromJson(json['guardianInfo']) 
          : null,
      doctorInfo: json['doctorInfo'] != null 
          ? DoctorInfo.fromJson(json['doctorInfo']) 
          : null,
    );
  }
}

/// 患者特有信息
class PatientInfo {
  /// 性别
  final Gender gender;
  
  /// 出生日期
  final DateTime dateOfBirth;
  
  /// 病史
  final String medicalHistory;
  
  /// 过敏史
  final String allergies;

  /// 创建PatientInfo实例
  PatientInfo({
    required this.gender,
    required this.dateOfBirth,
    required this.medicalHistory,
    required this.allergies,
  });

  /// 将PatientInfo对象转换为JSON格式的Map
  Map<String, dynamic> toJson() {
    return {
      'gender': gender.index,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'medicalHistory': medicalHistory,
      'allergies': allergies,
    };
  }

  /// 从JSON格式的Map创建PatientInfo对象
  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      gender: Gender.values[json['gender']],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
    );
  }
}

/// 监护人特有信息
class GuardianInfo {
  /// 与患者关系
  final String relationship;
  
  /// 紧急联系电话
  final String emergencyContact;

  /// 创建GuardianInfo实例
  GuardianInfo({
    required this.relationship,
    required this.emergencyContact,
  });

  /// 将GuardianInfo对象转换为JSON格式的Map
  Map<String, dynamic> toJson() {
    return {
      'relationship': relationship,
      'emergencyContact': emergencyContact,
    };
  }

  /// 从JSON格式的Map创建GuardianInfo对象
  factory GuardianInfo.fromJson(Map<String, dynamic> json) {
    return GuardianInfo(
      relationship: json['relationship'],
      emergencyContact: json['emergencyContact'],
    );
  }
}

/// 医师特有信息
class DoctorInfo {
  /// 医院
  final String hospital;
  
  /// 科室
  final String department;
  
  /// 医师执业证书编号
  final String licenseNumber;
  
  /// 专业领域
  final String specialty;

  /// 创建DoctorInfo实例
  DoctorInfo({
    required this.hospital,
    required this.department,
    required this.licenseNumber,
    required this.specialty,
  });

  /// 将DoctorInfo对象转换为JSON格式的Map
  Map<String, dynamic> toJson() {
    return {
      'hospital': hospital,
      'department': department,
      'licenseNumber': licenseNumber,
      'specialty': specialty,
    };
  }

  /// 从JSON格式的Map创建DoctorInfo对象
  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      hospital: json['hospital'],
      department: json['department'],
      licenseNumber: json['licenseNumber'],
      specialty: json['specialty'],
    );
  }
}
