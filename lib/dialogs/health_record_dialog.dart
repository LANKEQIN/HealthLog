import 'package:flutter/material.dart';
import '../models.dart';

/// 添加健康记录对话框
///
/// 用于添加新的健康记录，包括身体状况、血压和血糖等信息
class AddHealthRecordDialog extends StatefulWidget {
  /// 创建AddHealthRecordDialog实例
  ///
  /// [key] - 组件的键值
  const AddHealthRecordDialog({super.key});

  @override
  State<AddHealthRecordDialog> createState() => _AddHealthRecordDialogState();
}

/// AddHealthRecordDialog组件的状态类
///
/// 管理对话框中的表单控件和用户输入数据
class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  /// 身体状况文本控制器
  final _noteController = TextEditingController();
  
  /// 血压数值控制器
  final _bloodPressureController = TextEditingController();
  
  /// 血糖数值控制器
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
            // 设置键盘类型为数字键盘
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _bloodSugarController,
            decoration: const InputDecoration(
              labelText: '血糖 (可选)',
            ),
            // 设置键盘类型为数字键盘
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 取消添加，关闭对话框
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            // 创建新的健康记录对象
            final newRecord = HealthRecord(
              // 使用当前时间作为记录时间
              date: DateTime.now(),
              note: _noteController.text,
              // 如果输入了血压值，则尝试解析为double类型，否则设为null
              bloodPressure: _bloodPressureController.text.isNotEmpty
                  ? double.tryParse(_bloodPressureController.text)
                  : null,
              // 如果输入了血糖值，则尝试解析为double类型，否则设为null
              bloodSugar: _bloodSugarController.text.isNotEmpty
                  ? double.tryParse(_bloodSugarController.text)
                  : null,
            );
            // 返回新创建的健康记录对象
            Navigator.of(context).pop(newRecord);
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}