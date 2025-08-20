import 'package:flutter/material.dart';
import '../models.dart';

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
  
  /// 收缩压（高压）数值控制器
  late final TextEditingController _systolicPressureController;
  
  /// 舒张压（低压）数值控制器
  late final TextEditingController _diastolicPressureController;
  
  /// 血糖数值控制器
  late final TextEditingController _bloodSugarController;

  /// 体重数值控制器
  late final TextEditingController _weightController;

  /// 身高数值控制器
  late final TextEditingController _heightController;

  /// 心率数值控制器
  late final TextEditingController _heartRateController;

  /// 体温数值控制器
  late final TextEditingController _temperatureController;

  @override
  void initState() {
    super.initState();
    // 使用现有记录的数据初始化文本控制器
    _noteController = TextEditingController(text: widget.record.note);
    _systolicPressureController = TextEditingController(
      text: widget.record.systolicPressure?.toString() ?? '',
    );
    _diastolicPressureController = TextEditingController(
      text: widget.record.diastolicPressure?.toString() ?? '',
    );
    _bloodSugarController = TextEditingController(
      text: widget.record.bloodSugar?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.record.weight?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.record.height?.toString() ?? '',
    );
    _heartRateController = TextEditingController(
      text: widget.record.heartRate?.toString() ?? '',
    );
    _temperatureController = TextEditingController(
      text: widget.record.temperature?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    // 释放文本控制器资源
    _noteController.dispose();
    _systolicPressureController.dispose();
    _diastolicPressureController.dispose();
    _bloodSugarController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑健康记录'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '身体状况',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _systolicPressureController,
                    decoration: const InputDecoration(
                      labelText: '收缩压 (高压，可选)',
                    ),
                    // 设置键盘类型为数字键盘
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _diastolicPressureController,
                    decoration: const InputDecoration(
                      labelText: '舒张压 (低压，可选)',
                    ),
                    // 设置键盘类型为数字键盘
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _bloodSugarController,
              decoration: const InputDecoration(
                labelText: '血糖 (可选)',
              ),
              // 设置键盘类型为数字键盘
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: '体重 (kg，可选)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: '身高 (cm，可选)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heartRateController,
              decoration: const InputDecoration(
                labelText: '心率 (bpm，可选)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _temperatureController,
              decoration: const InputDecoration(
                labelText: '体温 (°C，可选)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
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
            // 连接监测仪器按钮（预留接口）
          },
          child: const Text('连接监测仪器'),
        ),
        TextButton(
          onPressed: () {
            // 创建更新后的健康记录对象
            final updatedRecord = HealthRecord(
              // 保持原始记录日期不变
              date: widget.record.date,
              note: _noteController.text,
              // 如果输入了收缩压值，则尝试解析为double类型，否则设为null
              systolicPressure: _systolicPressureController.text.isNotEmpty
                  ? double.tryParse(_systolicPressureController.text)
                  : null,
              // 如果输入了舒张压值，则尝试解析为double类型，否则设为null
              diastolicPressure: _diastolicPressureController.text.isNotEmpty
                  ? double.tryParse(_diastolicPressureController.text)
                  : null,
              // 如果输入了血糖值，则尝试解析为double类型，否则设为null
              bloodSugar: _bloodSugarController.text.isNotEmpty
                  ? double.tryParse(_bloodSugarController.text)
                  : null,
              // 如果输入了体重值，则尝试解析为double类型，否则设为null
              weight: _weightController.text.isNotEmpty
                  ? double.tryParse(_weightController.text)
                  : null,
              // 如果输入了身高值，则尝试解析为double类型，否则设为null
              height: _heightController.text.isNotEmpty
                  ? double.tryParse(_heightController.text)
                  : null,
              // 如果输入了心率值，则尝试解析为int类型，否则设为null
              heartRate: _heartRateController.text.isNotEmpty
                  ? int.tryParse(_heartRateController.text)
                  : null,
              // 如果输入了体温值，则尝试解析为double类型，否则设为null
              temperature: _temperatureController.text.isNotEmpty
                  ? double.tryParse(_temperatureController.text)
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