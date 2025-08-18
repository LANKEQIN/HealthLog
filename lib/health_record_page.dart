import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'health_record_dialog.dart';

class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  // 健康记录列表
  final List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 加载存储的健康记录数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载健康记录数据
    final recordsJson = prefs.getString('healthRecords') ?? '[]';
    final recordsList = json.decode(recordsJson) as List;
    _healthRecords.clear();
    _healthRecords.addAll(recordsList.map((e) => HealthRecord.fromJson(e)).toList());
    
    setState(() {});
  }

  // 保存健康记录数据
  Future<void> _saveHealthRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = json.encode(_healthRecords.map((e) => e.toJson()).toList());
    await prefs.setString('healthRecords', recordsJson);
  }

  void _addHealthRecord() {
    // 添加健康记录的函数
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddHealthRecordDialog();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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