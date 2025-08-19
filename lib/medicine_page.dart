import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'medicine_dialog.dart';

/// 药物管理页面
///
/// 显示用户的药物列表，支持添加、编辑和删除药物功能
class MedicinePage extends StatefulWidget {
  /// 创建MedicinePage实例
  ///
  /// [key] - 组件的键值
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

/// MedicinePage组件的状态类
///
/// 管理药物列表数据的加载、保存和界面更新
class _MedicinePageState extends State<MedicinePage> {
  /// 药物列表
  final List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    // 初始化时加载药物数据
    _loadData();
  }

  // 加载存储的药物数据
  /// 加载存储的药物数据
  ///
  /// 从SharedPreferences中读取药物数据并更新界面
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 从SharedPreferences加载药物数据，如果没有则返回空数组
    final medicinesJson = prefs.getString('medicines') ?? '[]';
    final medicinesList = json.decode(medicinesJson) as List;
    _medicines.clear();
    // 将JSON数据转换为Medicine对象并添加到列表中
    _medicines.addAll(medicinesList.map((e) => Medicine.fromJson(e)).toList());
    
    setState(() {});
  }

  // 保存药物数据
  /// 保存药物数据
  ///
  /// 将当前药物列表保存到SharedPreferences中
  Future<void> _saveMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    // 将药物列表转换为JSON格式并保存
    final medicinesJson = json.encode(_medicines.map((e) => e.toJson()).toList());
    await prefs.setString('medicines', medicinesJson);
  }

  /// 添加新药物
  ///
  /// 显示添加药物对话框，用户确认后将新药物添加到列表中
  void _addMedicine() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddMedicineDialog();
      },
    ).then((newMedicine) {
      // 如果用户确认添加药物，则更新列表并保存数据
      if (newMedicine != null) {
        setState(() {
          _medicines.add(newMedicine);
        });
        _saveMedicines();
      }
    });
  }

  /// 编辑药物
  ///
  /// [index] - 需要编辑的药物在列表中的索引
  /// 显示编辑药物对话框，用户确认后更新药物信息
  void _editMedicine(int index) {
    // 获取要编辑的药物对象
    final medicineToEdit = _medicines[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMedicineDialog(medicine: medicineToEdit);
      },
    ).then((updatedMedicine) {
      // 如果用户确认更新药物，则更新列表并保存数据
      if (updatedMedicine != null) {
        setState(() {
          _medicines[index] = updatedMedicine;
        });
        _saveMedicines();
      }
    });
  }

  /// 删除药物
  ///
  /// [index] - 需要删除的药物在列表中的索引
  /// 直接从列表中移除药物并保存更新后的数据
  void _deleteMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
    _saveMedicines();
  }

  /// 显示删除确认对话框
  ///
  /// [index] - 需要删除的药物在列表中的索引
  /// 在删除药物前提示用户确认操作
  void _showDeleteConfirmationDialog(int index) {
    final medicineName = _medicines[index].name;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除药物 "$medicineName" 吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMedicine(index);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
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
              // 药物提醒部分标题和添加按钮
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${medicine.dosage} - ${medicine.schedule}'),
                                  const SizedBox(height: 4),
                                  // 显示服药时间和饭前饭后信息
                                  Row(
                                    children: [
                                      Text(
                                        '${medicine.timesPerDay}次/天',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        medicine.beforeMeal ? '饭前' : '饭后',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // 显示服药时间列表
                                  SizedBox(
                                    height: 20,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: medicine.scheduleTimes.map((time) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editMedicine(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _showDeleteConfirmationDialog(index),
                                  ),
                                ],
                              ),
                              leading: Text(
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
            ],
          ),
        ),
      ),
    );
  }
}