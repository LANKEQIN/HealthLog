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

  /// 显示时间选择器
  ///
  /// [context] - 当前上下文
  /// 允许用户选择药物提醒时间
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
    // 判断当前是编辑模式还是添加模式
    final isEditing = widget.medicine != null;
    
    return AlertDialog(
      title: Text(isEditing ? '编辑药物' : '添加药物'),
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
            // 检查药物名称是否为空
            if (_nameController.text.isNotEmpty) {
              // 创建新的药物对象
              final newMedicine = Medicine(
                name: _nameController.text,
                dosage: _dosageController.text,
                schedule: _scheduleController.text,
                time: _selectedTime,
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