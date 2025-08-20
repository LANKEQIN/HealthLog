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

  /// 格式化时间显示
  ///
  /// [time] - 需要格式化的时间
  /// 返回格式化后的时间字符串，如 "8:00"
  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期显示
  ///
  /// [date] - 需要格式化的日期
  /// 返回格式化后的日期字符串，如 "2023-01-01"
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 简化格式化日期显示
  ///
  /// [date] - 需要格式化的日期
  /// 返回格式化后的日期字符串，如 "8月1日"
  String _formatDateSimple(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.month}月${date.day}日';
  }

  /// 获取服药时间类型的显示文本
  ///
  /// [type] - 服药时间类型
  /// 返回对应的中文显示文本
  String _getScheduleTypeText(MedicineScheduleType type) {
    switch (type) {
      case MedicineScheduleType.beforeBreakfast:
        return '早餐前';
      case MedicineScheduleType.afterBreakfast:
        return '早餐后';
      case MedicineScheduleType.beforeLunch:
        return '午餐前';
      case MedicineScheduleType.afterLunch:
        return '午餐后';
      case MedicineScheduleType.beforeDinner:
        return '晚餐前';
      case MedicineScheduleType.afterDinner:
        return '晚餐后';
      case MedicineScheduleType.beforeSleep:
        return '睡前';
    }
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

  /// 显示药物操作选项对话框
  ///
  /// [context] - 对话框显示的上下文
  /// [index] - 被选中药品的索引
  void _showMedicineOptionsDialog(BuildContext context, int index) {
    final medicineName = _medicines[index].name;
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"$medicineName" 操作',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editMedicine(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(index);
                },
              ),
            ],
          ),
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
              _medicines.isEmpty
                  ? const Center(
                      child: Text('暂无用药提醒'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medicines.length,
                      itemBuilder: (context, index) {
                        final medicine = _medicines[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onLongPress: () {
                              _showMedicineOptionsDialog(context, index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 药物名称和剂量
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          medicine.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${medicine.dosage} ${medicine.dosageUnit}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // 服用说明
                                  if (medicine.schedule.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        medicine.schedule,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  if (medicine.schedule.isNotEmpty)
                                    const SizedBox(height: 12),
                                  
                                  // 服用时间列表
                                  const Text(
                                    '服药时间:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // 显示所有服用时间
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: medicine.scheduleTimes.map((time) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatTime(time),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // 时间类型标签
                                  if (medicine.scheduleTypes.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: medicine.scheduleTypes.map((type) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getScheduleTypeText(type),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  
                                  // 用药周期
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${_formatDateSimple(medicine.startDate)}至${_formatDateSimple(medicine.endDate)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}