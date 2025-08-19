import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'health_record_dialog.dart';
import 'edit_health_record_dialog.dart';

/// 健康记录页面
///
/// 显示用户的健康记录列表，支持添加、编辑和删除健康记录功能
class HealthRecordPage extends StatefulWidget {
  /// 创建HealthRecordPage实例
  ///
  /// [key] - 组件的键值
  const HealthRecordPage({super.key});

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

/// HealthRecordPage组件的状态类
///
/// 管理健康记录列表数据的加载、保存和界面更新
class _HealthRecordPageState extends State<HealthRecordPage> {
  /// 健康记录列表
  final List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    // 初始化时加载健康记录数据
    _loadData();
  }

  /// 加载存储的健康记录数据
  ///
  /// 从SharedPreferences中读取健康记录数据并更新界面
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 从SharedPreferences加载健康记录数据，如果没有则返回空数组
    final recordsJson = prefs.getString('healthRecords') ?? '[]';
    final recordsList = json.decode(recordsJson) as List;
    _healthRecords.clear();
    // 将JSON数据转换为HealthRecord对象并添加到列表中
    _healthRecords.addAll(recordsList.map((e) => HealthRecord.fromJson(e)).toList());
    
    setState(() {});
  }

  /// 保存健康记录数据
  ///
  /// 将当前健康记录列表保存到SharedPreferences中
  Future<void> _saveHealthRecords() async {
    final prefs = await SharedPreferences.getInstance();
    // 将健康记录列表转换为JSON格式并保存
    final recordsJson = json.encode(_healthRecords.map((e) => e.toJson()).toList());
    await prefs.setString('healthRecords', recordsJson);
  }

  /// 添加健康记录
  ///
  /// 显示添加健康记录对话框，用户确认后将新记录添加到列表中
  void _addHealthRecord() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddHealthRecordDialog();
      },
    ).then((newRecord) {
      // 如果用户确认添加记录，则更新列表并保存数据
      if (newRecord != null) {
        setState(() {
          _healthRecords.add(newRecord);
        });
        _saveHealthRecords();
      }
    });
  }

  /// 编辑健康记录
  ///
  /// [index] - 需要编辑的健康记录在列表中的索引
  /// 显示编辑健康记录对话框，用户确认后更新记录信息
  void _editHealthRecord(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditHealthRecordDialog(record: _healthRecords[index]);
      },
    ).then((updatedRecord) {
      // 如果用户确认更新记录，则更新列表并保存数据
      if (updatedRecord != null) {
        setState(() {
          _healthRecords[index] = updatedRecord;
        });
        _saveHealthRecords();
      }
    });
  }

  /// 删除健康记录
  ///
  /// [index] - 需要删除的健康记录在列表中的索引
  /// 在删除前显示确认对话框，用户确认后从列表中移除记录并保存更新后的数据
  void _deleteHealthRecord(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('您确定要删除这条健康记录吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      // 如果用户确认删除，则更新列表并保存数据
      if (confirmed == true) {
        setState(() {
          _healthRecords.removeAt(index);
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
              // 健康记录部分标题和添加按钮
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editHealthRecord(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteHealthRecord(index),
                                  ),
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