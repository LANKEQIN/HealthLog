import 'package:flutter/material.dart';
import '../models.dart';

/// 用户档案页面
///
/// 用于管理三种用户角色：患者、监护人、医师
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // 当前选中的角色类型
  UserRole _selectedRole = UserRole.patient;
  
  // 表单控制器
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  
  // 患者特有信息
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  DateTime? _dateOfBirth;
  Gender? _gender;
  
  // 监护人特有信息
  final _relationshipController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  // 医师特有信息
  final _hospitalController = TextEditingController();
  final _departmentController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _specialtyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _relationshipController.dispose();
    _emergencyContactController.dispose();
    _hospitalController.dispose();
    _departmentController.dispose();
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  /// 保存用户档案信息
  void _saveProfile() {
    // TODO: 实现保存逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户档案已保存')),
    );
  }

  /// 选择出生日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户档案'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 角色选择部分
            const Text(
              '选择角色类型',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(value: UserRole.patient, label: Text('患者')),
                ButtonSegment(value: UserRole.guardian, label: Text('监护人')),
                ButtonSegment(value: UserRole.doctor, label: Text('医师')),
              ],
              selected: {_selectedRole},
              onSelectionChanged: (Set<UserRole> newSelection) {
                setState(() {
                  _selectedRole = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // 基本信息表单
            const Text(
              '基本信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(_nameController, '姓名', Icons.person),
            const SizedBox(height: 10),
            _buildTextField(_phoneController, '电话', Icons.phone),
            const SizedBox(height: 10),
            _buildTextField(_emailController, '邮箱', Icons.email),
            const SizedBox(height: 10),
            _buildTextField(_idController, '身份证号', Icons.badge),
            const SizedBox(height: 10),
            
            // 根据角色类型显示不同的额外信息
            if (_selectedRole == UserRole.patient) ...[
              const Text(
                '患者信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildGenderSelector(),
              const SizedBox(height: 10),
              _buildDateSelector(),
              const SizedBox(height: 10),
              _buildTextField(
                _medicalHistoryController, 
                '病史', 
                Icons.local_hospital,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _allergiesController, 
                '过敏史', 
                Icons.warning,
                maxLines: 2,
              ),
            ] else if (_selectedRole == UserRole.guardian) ...[
              const Text(
                '监护人信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildTextField(_relationshipController, '与患者关系', Icons.family_restroom),
              const SizedBox(height: 10),
              _buildTextField(_emergencyContactController, '紧急联系电话', Icons.contact_phone),
            ] else ...[
              const Text(
                '医师信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildTextField(_hospitalController, '医院', Icons.local_hospital),
              const SizedBox(height: 10),
              _buildTextField(_departmentController, '科室', Icons.business),
              const SizedBox(height: 10),
              _buildTextField(_licenseNumberController, '医师执业证书编号', Icons.badge),
              const SizedBox(height: 10),
              _buildTextField(_specialtyController, '专业领域', Icons.science),
            ],
            
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('保存档案', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文本输入框
  Widget _buildTextField(
    TextEditingController controller, 
    String labelText, 
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  /// 构建性别选择器
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别', style: TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('男'),
                leading: Radio<Gender>(
                  value: Gender.male,
                  groupValue: _gender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('女'),
                leading: Radio<Gender>(
                  value: Gender.female,
                  groupValue: _gender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建日期选择器
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('出生日期', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: _dateOfBirth == null 
                    ? '请选择出生日期' 
                    : '${_dateOfBirth!.year}-${_dateOfBirth!.month}-${_dateOfBirth!.day}',
                prefixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}