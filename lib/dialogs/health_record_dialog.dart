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
  
  /// 收缩压（高压）数值控制器
  final _systolicPressureController = TextEditingController();
  
  /// 舒张压（低压）数值控制器
  final _diastolicPressureController = TextEditingController();
  
  /// 血糖数值控制器
  final _bloodSugarController = TextEditingController();

  /// 体重数值控制器
  final _weightController = TextEditingController();

  /// 身高数值控制器
  final _heightController = TextEditingController();

  /// 心率数值控制器
  final _heartRateController = TextEditingController();

  /// 体温数值控制器
  final _temperatureController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加健康记录'),
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
            // 取消添加，关闭对话框
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
            // 创建新的健康记录对象
            final newRecord = HealthRecord(
              // 使用当前时间作为记录时间
              date: DateTime.now(),
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
            // 返回新创建的健康记录对象
            Navigator.of(context).pop(newRecord);
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}