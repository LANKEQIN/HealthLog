import 'package:flutter/material.dart';
import 'models.dart';

class AddMedicineDialog extends StatefulWidget {
  final Medicine? medicine; // 添加可选的medicine参数用于编辑

  const AddMedicineDialog({super.key, this.medicine});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  late final _nameController = TextEditingController(text: widget.medicine?.name ?? '');
  late final _dosageController = TextEditingController(text: widget.medicine?.dosage ?? '');
  late final _scheduleController = TextEditingController(text: widget.medicine?.schedule ?? '');
  late TimeOfDay _selectedTime = widget.medicine?.time ?? TimeOfDay(hour: 8, minute: 0);

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
          child: Text(isEditing ? '更新' : '添加'),
        ),
      ],
    );
  }
}