// import 'package:flutter/material.dart';
// import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
// import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';

// class StudentAccountAddScreen extends StatefulWidget {
//   final String token;

//   const StudentAccountAddScreen({Key? key, required this.token})
//       : super(key: key);

//   @override
//   _StudentAccountAddScreenState createState() =>
//       _StudentAccountAddScreenState();
// }

// class _StudentAccountAddScreenState extends State<StudentAccountAddScreen> {
//   late ApiServiceTaiKhoanSinhVien _apiService;
//   bool _isLoading = false;

//   final _formKey = GlobalKey<FormState>();
//   final _idController = TextEditingController();
//   final _studentIdController = TextEditingController();
//   final _tenDN = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _apiService = ApiServiceTaiKhoanSinhVien(widget.token);
//   }

//   @override
//   void dispose() {
//     _idController.dispose();
//     _studentIdController.dispose();
//     _tenDN.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _createAccount() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final newAccount = TaiKhoanSinhVien(
//         maTKSV: _idController.text,
//         maSV: _studentIdController.text,
//         tenDangNhap: _tenDN.text,
//         matKhau: _passwordController.text,
//       );

//       await _apiService.createTaiKhoanSinhVien(newAccount);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Tạo tài khoản thành công')),
//       );

//       Navigator.pop(
//           context, true); // Return to previous screen with create success
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showErrorDialog('Lỗi khi tạo tài khoản: ${e.toString()}');
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Lỗi'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Đóng'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue[700],
//         title: const Text('Tạo tài khoản sinh viên mới'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _isLoading ? null : _createAccount,
//             tooltip: 'Tạo tài khoản',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     TextFormField(
//                       controller: _idController,
//                       decoration: const InputDecoration(
//                         labelText: 'Mã tài khoản',
//                         hintText: 'Nhập mã tài khoản',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Vui lòng nhập mã tài khoản';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _studentIdController,
//                       decoration: const InputDecoration(
//                         labelText: 'Mã sinh viên',
//                         hintText: 'Nhập mã sinh viên',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Vui lòng nhập mã sinh viên';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _tenDN,
//                       decoration: const InputDecoration(
//                         labelText: 'Tên đăng nhập',
//                         hintText: 'Nhập tên đăng nhập',
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Vui lòng nhập email';
//                         }
//                         if (!value.contains('@')) {
//                           return 'Email không hợp lệ';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: const InputDecoration(
//                         labelText: 'Mật khẩu',
//                         hintText: 'Nhập mật khẩu',
//                         border: OutlineInputBorder(),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Vui lòng nhập mật khẩu';
//                         }
//                         if (value.length < 6) {
//                           return 'Mật khẩu phải có ít nhất 6 ký tự';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton.icon(
//                       onPressed: _createAccount,
//                       icon: const Icon(Icons.save),
//                       label: const Text('Tạo tài khoản'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
