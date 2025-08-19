import 'package:flutter/material.dart';
import 'models.dart';

/// 编辑健康记录对话框
///
/// 用于编辑现有的健康记录，包括身体状况、血压和血糖等信息
class EditHealthRecordDialog extends StatefulWidget {
  /// 需要编辑的健康记录对象
  final HealthRecord record;

  /// 创建EditHealthRecordDialog实例
  ///
  /// [key] - 组件的键值
  /// [record] - 需要编辑的健康记录对象
  const EditHealthRecordDialog({super.key, required this.record});

  @override
  State<EditHealthRecordDialog> createState() => _EditHealthRecordDialogState();
}

/// EditHealthRecordDialog组件的状态类
///
/// 管理对话框中的表单控件和用户输入数据
class _EditHealthRecordDialogState extends State<EditHealthRecordDialog> {
  /// 身体状况文本控制器
  late final TextEditingController _noteController;
  
  /// 血压数值控制器
  late final TextEditingController _bloodPressureController;
  
  /// 血糖数值控制器
  late final TextEditingController _bloodSugarController;

  @override
  void initState() {
    super.initState();
    // 使用现有记录的数据初始化文本控制器
    _noteController = TextEditingController(text: widget.record.note);
    _bloodPressureController = TextEditingController(
      text: widget.record.bloodPressure?.toString() ?? '',
    );
    _bloodSugarController = TextEditingController(
      text: widget.record.bloodSugar?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    // 释放文本控制器资源
    _noteController.dispose();
    _bloodPressureController.dispose();
    _bloodSugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑健康记录'),
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
            // 取消编辑，关闭对话框
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            // 创建更新后的健康记录对象
            final updatedRecord = HealthRecord(
              // 保持原始记录日期不变
              date: widget.record.date,
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
            // 返回更新后的健康记录对象
            Navigator.of(context).pop(updatedRecord);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}