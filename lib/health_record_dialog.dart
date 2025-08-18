import 'package:flutter/material.dart';
import 'models.dart';

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