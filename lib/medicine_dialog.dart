import 'package:flutter/material.dart';
import 'models.dart';

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