import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const HealthLogApp());
}

class HealthLogApp extends StatelessWidget {
  const HealthLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthLog - 用药日志',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

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

class _MainScreenState extends State<MainScreen> {
  // 药物列表
  final List<Medicine> _medicines = [];

  // 健康记录列表
  final List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 加载存储的数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载药物数据
    final medicinesJson = prefs.getString('medicines') ?? '[]';
    final medicinesList = json.decode(medicinesJson) as List;
    _medicines.clear();
    _medicines.addAll(medicinesList.map((e) => Medicine.fromJson(e)).toList());
    
    // 加载健康记录数据
    final recordsJson = prefs.getString('healthRecords') ?? '[]';
    final recordsList = json.decode(recordsJson) as List;
    _healthRecords.clear();
    _healthRecords.addAll(recordsList.map((e) => HealthRecord.fromJson(e)).toList());
    
    setState(() {});
  }

  // 保存药物数据
  Future<void> _saveMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = json.encode(_medicines.map((e) => e.toJson()).toList());
    await prefs.setString('medicines', medicinesJson);
  }

  // 保存健康记录数据
  Future<void> _saveHealthRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = json.encode(_healthRecords.map((e) => e.toJson()).toList());
    await prefs.setString('healthRecords', recordsJson);
  }

  void _addMedicine() {
    // 添加新药物的函数
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMedicineDialog();
      },
    ).then((newMedicine) {
      if (newMedicine != null) {
        setState(() {
          _medicines.add(newMedicine);
        });
        _saveMedicines();
      }
    });
  }

  void _addHealthRecord() {
    // 添加健康记录的函数
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddHealthRecordDialog();
      },
    ).then((newRecord) {
      if (newRecord != null) {
        setState(() {
          _healthRecords.add(newRecord);
        });
        _saveHealthRecords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthLog'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 药物提醒部分
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '用药提醒',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addMedicine,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: _medicines.isEmpty
                    ? const Center(
                        child: Text('暂无用药提醒'),
                      )
                    : ListView.builder(
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) {
                          final medicine = _medicines[index];
                          return Card(
                            child: ListTile(
                              title: Text(medicine.name),
                              subtitle: Text(
                                  '${medicine.dosage} - ${medicine.schedule}'),
                              trailing: Text(
                                '${medicine.time.hour}:${medicine.time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              // 健康记录部分
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '健康记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addHealthRecord,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: _healthRecords.isEmpty
                    ? const Center(
                        child: Text('暂无健康记录'),
                      )
                    : ListView.builder(
                        itemCount: _healthRecords.length,
                        itemBuilder: (context, index) {
                          final record = _healthRecords[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(record.note),
                                  if (record.bloodPressure != null)
                                    Text('血压: ${record.bloodPressure}'),
                                  if (record.bloodSugar != null)
                                    Text('血糖: ${record.bloodSugar}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddMedicineDialog extends StatefulWidget {
  const AddMedicineDialog({super.key});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _scheduleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加药物'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '药物名称',
            ),
          ),
          TextField(
            controller: _dosageController,
            decoration: const InputDecoration(
              labelText: '剂量',
            ),
          ),
          TextField(
            controller: _scheduleController,
            decoration: const InputDecoration(
              labelText: '服用说明',
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('提醒时间'),
            trailing: Text(
              '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            ),
            onTap: () => _selectTime(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final newMedicine = Medicine(
                name: _nameController.text,
                dosage: _dosageController.text,
                schedule: _scheduleController.text,
                time: _selectedTime,
              );
              Navigator.of(context).pop(newMedicine);
            }
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}

class AddHealthRecordDialog extends StatefulWidget {
  const AddHealthRecordDialog({super.key});

  @override
  State<AddHealthRecordDialog> createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  final _noteController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _bloodSugarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加健康记录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '身体状况',
            ),
          ),
          TextField(
            controller: _bloodPressureController,
            decoration: const InputDecoration(
              labelText: '血压 (可选)',
            ),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _bloodSugarController,
            decoration: const InputDecoration(
              labelText: '血糖 (可选)',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final newRecord = HealthRecord(
              date: DateTime.now(),
              note: _noteController.text,
              bloodPressure: _bloodPressureController.text.isNotEmpty
                  ? double.tryParse(_bloodPressureController.text)
                  : null,
              bloodSugar: _bloodSugarController.text.isNotEmpty
                  ? double.tryParse(_bloodSugarController.text)
                  : null,
            );
            Navigator.of(context).pop(newRecord);
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}
