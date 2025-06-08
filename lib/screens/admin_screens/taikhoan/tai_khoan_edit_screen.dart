import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_tai_khoan.dart';

class TaiKhoanEditScreen extends StatefulWidget {
  final TaiKhoan taiKhoan;
  TaiKhoanEditScreen({required this.taiKhoan});

  @override
  _TaiKhoanEditScreenState createState() => _TaiKhoanEditScreenState();
}

class _TaiKhoanEditScreenState extends State<TaiKhoanEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenDangNhapController;
  late TextEditingController _maNVController;
  late TextEditingController _maLoaiController;
  late TextEditingController _matKhauController;

  @override
  void initState() {
    super.initState();
    _tenDangNhapController =
        TextEditingController(text: widget.taiKhoan.tenDangNhap);
    _maNVController = TextEditingController(text: widget.taiKhoan.maNV);
    _maLoaiController = TextEditingController(text: widget.taiKhoan.maLoai);
    _matKhauController = TextEditingController(text: widget.taiKhoan.matKhau);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedTK = TaiKhoan(
        maTK: widget.taiKhoan.maTK,
        tenDangNhap: _tenDangNhapController.text,
        maNV: _maNVController.text,
        maLoai: _maLoaiController.text,
        matKhau: _matKhauController.text,
      );
      await ApiTaiKhoan.updateTaiKhoan(widget.taiKhoan.maTK, updatedTK);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[700], title: Text('Sửa tài khoản')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tenDangNhapController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Tên đăng nhập'),
              ),
              TextFormField(
                controller: _maNVController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Mã nhân viên'),
              ),
              TextFormField(
                controller: _maLoaiController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Mã loại tài khoản'),
              ),
              TextFormField(
                controller: _matKhauController,
                decoration: InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Không để trống' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _submit,
                  child: Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}
