// lib/screens/student_account/student_account_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';

class StudentAccountDetailScreen extends StatefulWidget {
  final String token;
  final String accountId;

  const StudentAccountDetailScreen(
      {Key? key, required this.token, required this.accountId})
      : super(key: key);

  @override
  _StudentAccountDetailScreenState createState() =>
      _StudentAccountDetailScreenState();
}

class _StudentAccountDetailScreenState
    extends State<StudentAccountDetailScreen> {
  late ApiServiceTaiKhoanSinhVien _apiService;
  TaiKhoanSinhVien? _account;
  bool _isLoading = true;
  String _errorMessage = '';

  // Form controllers
  final TextEditingController _maTKSVController = TextEditingController();
  final TextEditingController _maSVController = TextEditingController();
  final TextEditingController _tenDangNhapController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _apiService = ApiServiceTaiKhoanSinhVien(widget.token);
    _loadAccountDetails();
  }

  Future<void> _loadAccountDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final account =
          await _apiService.getTaiKhoanSinhVienById(widget.accountId);
      setState(() {
        _account = account;
        _maTKSVController.text = account.maTKSV;
        _maSVController.text = account.maSV;
        _tenDangNhapController.text = account.tenDangNhap;
        _matKhauController.text = ''; // Intentionally left blank for security
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorDialog(_errorMessage);
    }
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedAccount = TaiKhoanSinhVien(
        maTKSV: _maTKSVController.text,
        maSV: _maSVController.text,
        tenDangNhap: _tenDangNhapController.text,
        matKhau: _matKhauController.text.isNotEmpty
            ? _matKhauController.text
            : _account!.matKhau,
      );

      final success = await _apiService.updateTaiKhoanSinhVien(
          _maTKSVController.text, updatedAccount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Cập nhật tài khoản thành công'
                : 'Cập nhật tài khoản thất bại')),
      );

      if (success) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Chi tiết tài khoản sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccountDetails,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã xảy ra lỗi',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAccountDetails,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _maTKSVController,
                          decoration: const InputDecoration(
                            labelText: 'Mã Tài Khoản Sinh Viên',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          enabled: false, // Disable editing of account ID
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mã tài khoản';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _maSVController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Mã Sinh Viên',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mã sinh viên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tenDangNhapController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tên Đăng Nhập',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên đăng nhập';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _matKhauController,
                          decoration: const InputDecoration(
                            labelText: 'Mật Khẩu Mới (Để trống nếu không đổi)',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _updateAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cập Nhật Tài Khoản'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _maTKSVController.dispose();
    _maSVController.dispose();
    _tenDangNhapController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }
}
