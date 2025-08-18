import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'medicine_dialog.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 加载存储的药物数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载药物数据
    final medicinesJson = prefs.getString('medicines') ?? '[]';
    final medicinesList = json.decode(medicinesJson) as List;
    _medicines.clear();
    _medicines.addAll(medicinesList.map((e) => Medicine.fromJson(e)).toList());
    
    setState(() {});
  }

  // 保存药物数据
  Future<void> _saveMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = json.encode(_medicines.map((e) => e.toJson()).toList());
    await prefs.setString('medicines', medicinesJson);
  }

  void _addMedicine() {
    // 添加新药物的函数
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddMedicineDialog();
      },
    ).then((newMedicine) {
      if (newMedicine != null) {
        setState(() {
          _medicines.add(newMedicine);
        });
        _saveMedicines();
      }
    });
  }

  void _editMedicine(int index) {
    // 编辑药物的函数
    final medicineToEdit = _medicines[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMedicineDialog(medicine: medicineToEdit);
      },
    ).then((updatedMedicine) {
      if (updatedMedicine != null) {
        setState(() {
          _medicines[index] = updatedMedicine;
        });
        _saveMedicines();
      }
    });
  }

  void _deleteMedicine(int index) {
    // 删除药物的函数
    setState(() {
      _medicines.removeAt(index);
    });
    _saveMedicines();
  }

  void _showDeleteConfirmationDialog(int index) {
    final medicineName = _medicines[index].name;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除药物 "$medicineName" 吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMedicine(index);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 药物提醒部分
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '用药提醒',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addMedicine,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: _medicines.isEmpty
                    ? const Center(
                        child: Text('暂无用药提醒'),
                      )
                    : ListView.builder(
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) {
                          final medicine = _medicines[index];
                          return Card(
                            child: ListTile(
                              title: Text(medicine.name),
                              subtitle: Text(
                                  '${medicine.dosage} - ${medicine.schedule}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editMedicine(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _showDeleteConfirmationDialog(index),
                                  ),
                                ],
                              ),
                              leading: Text(
                                '${medicine.time.hour}:${medicine.time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}