import 'package:flutter/material.dart';
import 'models.dart';

/// 添加/编辑药物对话框
///
/// 用于添加新药物或编辑现有药物信息的对话框组件
class AddMedicineDialog extends StatefulWidget {
  /// 要编辑的药物对象（可选）
  ///
  /// 如果提供该参数，则对话框处于编辑模式，否则为添加模式
  final Medicine? medicine;

  /// 创建AddMedicineDialog实例
  ///
  /// [key] - 组件的键值
  /// [medicine] - 要编辑的药物对象（可选）
  const AddMedicineDialog({super.key, this.medicine});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

/// AddMedicineDialog组件的状态类
///
/// 管理对话框中的表单控件和用户输入数据
class _AddMedicineDialogState extends State<AddMedicineDialog> {
  /// 药物名称控制器
  late final _nameController = TextEditingController(text: widget.medicine?.name ?? '');
  
  /// 药物剂量控制器
  late final _dosageController = TextEditingController(text: widget.medicine?.dosage ?? '');
  
  /// 服用说明控制器
  late final _scheduleController = TextEditingController(text: widget.medicine?.schedule ?? '');
  
  /// 选中的提醒时间
  late TimeOfDay _selectedTime = widget.medicine?.time ?? TimeOfDay(hour: 8, minute: 0);
  
  /// 每日次数
  late int _timesPerDay = widget.medicine?.timesPerDay ?? 1;
  
  /// 服药时间列表
  late List<TimeOfDay> _scheduleTimes = List<TimeOfDay>.from(widget.medicine?.scheduleTimes ?? [_selectedTime]);
  
  /// 是否饭前服用
  late bool _beforeMeal = widget.medicine?.beforeMeal ?? false;

  /// 显示时间选择器
  ///
  /// [context] - 当前上下文
  /// [initialTime] - 初始时间
  /// 允许用户选择药物提醒时间
  Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    return picked;
  }

  /// 更新指定索引的时间
  Future<void> _updateScheduleTime(int index) async {
    final TimeOfDay? picked = await _selectTime(context, _scheduleTimes[index]);
    if (picked != null) {
      setState(() {
        _scheduleTimes[index] = picked;
      });
    }
  }


  /// 删除指定索引的服药时间
  void _removeScheduleTime(int index) {
    if (_scheduleTimes.length > 1) {
      setState(() {
        _scheduleTimes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 判断当前是编辑模式还是添加模式
    final isEditing = widget.medicine != null;
    
    return AlertDialog(
      title: Text(isEditing ? '编辑药物' : '添加药物'),
      content: SingleChildScrollView(
        child: Column(
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
            // 每日次数选择
            ListTile(
              title: const Text('每日次数'),
              trailing: DropdownButton<int>(
                value: _timesPerDay,
                items: List.generate(5, (index) => index + 1).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value 次'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _timesPerDay = newValue;
                      // 调整时间列表大小以匹配次数
                      if (_scheduleTimes.length < _timesPerDay) {
                        // 添加更多时间项
                        while (_scheduleTimes.length < _timesPerDay) {
                          _scheduleTimes.add(TimeOfDay(hour: 8, minute: 0));
                        }
                      } else if (_scheduleTimes.length > _timesPerDay) {
                        // 移除多余的时间项
                        _scheduleTimes.removeRange(_timesPerDay, _scheduleTimes.length);
                      }
                    });
                  }
                },
              ),
            ),
            // 服药时间列表
            Column(
              children: List.generate(_timesPerDay, (index) {
                return ListTile(
                  title: Text('服药时间 ${index + 1}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_scheduleTimes[index].hour}:${_scheduleTimes[index].minute.toString().padLeft(2, '0')}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _updateScheduleTime(index),
                      ),
                      if (_timesPerDay > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () => _removeScheduleTime(index),
                        ),
                    ],
                  ),
                  onTap: () => _updateScheduleTime(index),
                );
              }),
            ),
            // 饭前饭后选择
            ListTile(
              title: const Text('服用时间'),
              trailing: ToggleButtons(
                isSelected: [_beforeMeal, !_beforeMeal],
                onPressed: (int index) {
                  setState(() {
                    _beforeMeal = index == 0;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('饭前'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('饭后'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            // 检查药物名称是否为空
            if (_nameController.text.isNotEmpty) {
              // 创建新的药物对象
              final newMedicine = Medicine(
                name: _nameController.text,
                dosage: _dosageController.text,
                schedule: _scheduleController.text,
                time: _selectedTime,
                timesPerDay: _timesPerDay,
                scheduleTimes: _scheduleTimes,
                beforeMeal: _beforeMeal,
              );
              // 返回新创建的药物对象
              Navigator.of(context).pop(newMedicine);
            }
          },
          child: Text(isEditing ? '更新' : '添加'),
        ),
      ],
    );
  }
}