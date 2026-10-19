import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
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
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 加载用户档案信息
  Future<void> _loadProfile() async {
    UserProfile? profile;
    try {
      // 统一走 app_state 的读取方法，避免各处重复写反序列化逻辑
      profile = await loadUserProfile();
    } catch (_) {
      // 本地档案数据损坏时忽略，保持空白表单
      return;
    }
    final loaded = profile;
    if (loaded == null || !mounted) return;

    setState(() {
      _selectedRole = loaded.role;
      _nameController.text = loaded.name;
      _phoneController.text = loaded.phone;
      _emailController.text = loaded.email;
      _idController.text = loaded.idNumber;

      if (loaded.patientInfo != null) {
        _gender = loaded.patientInfo!.gender;
        _dateOfBirth = loaded.patientInfo!.dateOfBirth;
        _medicalHistoryController.text = loaded.patientInfo!.medicalHistory;
        _allergiesController.text = loaded.patientInfo!.allergies;
      }

      if (loaded.guardianInfo != null) {
        _relationshipController.text = loaded.guardianInfo!.relationship;
        _emergencyContactController.text = loaded.guardianInfo!.emergencyContact;
      }

      if (loaded.doctorInfo != null) {
        _hospitalController.text = loaded.doctorInfo!.hospital;
        _departmentController.text = loaded.doctorInfo!.department;
        _licenseNumberController.text = loaded.doctorInfo!.licenseNumber;
        _specialtyController.text = loaded.doctorInfo!.specialty;
      }
    });
  }

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
  void _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    final profile = UserProfile(
      role: _selectedRole,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      idNumber: _idController.text,
      patientInfo: _selectedRole == UserRole.patient && _gender != null && _dateOfBirth != null
          ? PatientInfo(
              gender: _gender!,
              dateOfBirth: _dateOfBirth!,
              medicalHistory: _medicalHistoryController.text,
              allergies: _allergiesController.text,
            )
          : null,
      guardianInfo: _selectedRole == UserRole.guardian
          ? GuardianInfo(
              relationship: _relationshipController.text,
              emergencyContact: _emergencyContactController.text,
            )
          : null,
      doctorInfo: _selectedRole == UserRole.doctor
          ? DoctorInfo(
              hospital: _hospitalController.text,
              department: _departmentController.text,
              licenseNumber: _licenseNumberController.text,
              specialty: _specialtyController.text,
            )
          : null,
    );
    
    final profileJson = json.encode(profile.toJson());
    await prefs.setString(kKeyUserProfile, profileJson);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户档案已保存')),
      );
    }
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
    // 不再自带 AppBar：标题栏由 MainScreen 统一提供，避免出现双层标题栏
    return Scaffold(
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
        // 由 RadioGroup 统一管理选中值，Radio 只声明自身取值
        RadioGroup<Gender>(
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('男'),
                  leading: const Radio<Gender>(value: Gender.male),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('女'),
                  leading: const Radio<Gender>(value: Gender.female),
                ),
              ),
            ],
          ),
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