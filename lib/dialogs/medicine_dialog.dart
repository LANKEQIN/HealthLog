import 'package:flutter/material.dart';
import '../models.dart';

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
  
  /// 药物俗称控制器
  late final _commonNameController = TextEditingController(text: widget.medicine?.commonName ?? '');
  
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
  // late bool _beforeMeal = widget.medicine?.beforeMeal ?? false;
  
  /// 剂量单位
  late String _dosageUnit = widget.medicine?.dosageUnit ?? '毫克';

  /// 用药开始日期
  late DateTime? _startDate = widget.medicine?.startDate;

  /// 用药结束日期
  late DateTime? _endDate = widget.medicine?.endDate;

  /// 详细的服药时间类型列表
  late List<MedicineScheduleType> _scheduleTypes = List<MedicineScheduleType>.from(widget.medicine?.scheduleTypes ?? []);
  
  /// 是否为处方药
  late bool _isPrescription = widget.medicine?.isPrescription ?? false;

  /// 预定义的剂量单位列表
  final List<String> _dosageUnits = ['毫克', '克', '片', '剂', '其他'];

  @override
  void initState() {
    super.initState();
    _initializeScheduleTimes();
  }

  /// 初始化服药时间列表
  void _initializeScheduleTimes() {
    if (widget.medicine == null) {
      // 添加模式，初始化默认时间
      _scheduleTimes = List.generate(_timesPerDay, (index) => TimeOfDay(hour: 8 + index, minute: 0));
    } else {
      // 编辑模式，使用现有数据
      _scheduleTimes = List<TimeOfDay>.from(widget.medicine!.scheduleTimes);
    }
  }

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
        _timesPerDay--;
      });
    }
  }

  /// 添加新的服药时间
  void _addScheduleTime() {
    setState(() {
      _scheduleTimes.add(TimeOfDay(hour: 8, minute: 0));
      _timesPerDay++;
    });
  }

  /// 选择开始日期
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // 确保结束日期不早于开始日期
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  /// 选择结束日期
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  /// 切换服药时间类型选择
  void _toggleScheduleType(MedicineScheduleType type) {
    setState(() {
      if (_scheduleTypes.contains(type)) {
        _scheduleTypes.remove(type);
      } else {
        _scheduleTypes.add(type);
      }
    });
  }

  /// 获取服药时间类型的显示文本
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

  /// 从模板创建药物
  void _createFromTemplate(MedicineTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _dosageController.text = template.dosage;
      _dosageUnit = template.dosageUnit;
      _scheduleController.text = template.schedule;
      _timesPerDay = template.timesPerDay;
      _scheduleTimes = List<TimeOfDay>.from(template.scheduleTimes);
      _scheduleTypes = List<MedicineScheduleType>.from(template.scheduleTypes);
    });
  }

  /// 显示模板选择对话框
  void _showTemplateSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '选择药物模板',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: MedicineTemplate.commonMedicines.length,
                  itemBuilder: (context, index) {
                    final template = MedicineTemplate.commonMedicines[index];
                    return ListTile(
                      title: Text(template.name),
                      subtitle: Text('${template.dosage} ${template.dosageUnit}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).pop();
                        _createFromTemplate(template);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加从模板选择的按钮
            if (!isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showTemplateSelectionDialog(context);
                  },
                  icon: const Icon(Icons.library_books),
                  label: const Text('从模板选择'),
                ),
              ),
              const Divider(),
            ],
            // 药物名称输入框
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '药物名称 *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 药物俗称输入框
            TextField(
              controller: _commonNameController,
              decoration: const InputDecoration(
                labelText: '药物俗称（别名）',
                border: OutlineInputBorder(),
                hintText: '如：扑热息痛（对乙酰氨基酚）',
              ),
            ),
            const SizedBox(height: 16),
            
            // 药物剂量输入框
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: '剂量',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _dosageUnit,
                    items: _dosageUnits.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _dosageUnit = newValue;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: '单位',
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _scheduleController,
              decoration: const InputDecoration(
                labelText: '服用说明',
              ),
            ),
            const SizedBox(height: 10),
            // 用药周期选择
            const Text(
              '用药周期',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '开始日期',
                      ),
                      child: Text(
                        _startDate == null
                            ? '未选择'
                            : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '结束日期',
                      ),
                      child: Text(
                        _endDate == null
                            ? '未选择'
                            : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
              ],
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
              children: List.generate(_scheduleTimes.length, (index) {
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
                      if (_scheduleTimes.length > 1)
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
            const SizedBox(height: 10),
            // 细化的服药时间类型选择
            const Text(
              '服药时间类型',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: MedicineScheduleType.values.map((type) {
                final isSelected = _scheduleTypes.contains(type);
                return FilterChip(
                  label: Text(_getScheduleTypeText(type)),
                  selected: isSelected,
                  onSelected: (_) => _toggleScheduleType(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // 处方药选择
            const Text(
              '药物类型',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('处方药'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _isPrescription,
                      onChanged: (value) {
                        setState(() {
                          _isPrescription = value!;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _isPrescription = true;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('非处方药'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _isPrescription,
                      onChanged: (value) {
                        setState(() {
                          _isPrescription = value!;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _isPrescription = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 饭前饭后选择（保留以保持向后兼容性）

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
            if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
              // 如果必填字段为空，显示提示信息
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请填写必填字段')),
              );
              return;
            }
            
            // 创建新的药物对象并返回
            final newMedicine = Medicine(
              name: _nameController.text,
              commonName: _commonNameController.text.isEmpty ? null : _commonNameController.text,
              dosage: _dosageController.text,
              dosageUnit: _dosageUnit,
              schedule: _scheduleController.text,
              time: _selectedTime,
              timesPerDay: _timesPerDay,
              scheduleTimes: _scheduleTimes,
              startDate: _startDate,
              endDate: _endDate,
              scheduleTypes: _scheduleTypes,
              isPrescription: _isPrescription,
            );
            
            Navigator.of(context).pop(newMedicine);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}