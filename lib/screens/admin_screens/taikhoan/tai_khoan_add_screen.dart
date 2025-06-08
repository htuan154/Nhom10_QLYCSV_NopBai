import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';
import 'package:doan_qlsv_nhom10/services/api_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart';

class TaiKhoanAddScreen extends StatefulWidget {
  @override
  _TaiKhoanAddScreenState createState() => _TaiKhoanAddScreenState();
}

class _TaiKhoanAddScreenState extends State<TaiKhoanAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenDangNhapController = TextEditingController();
  final _maNVController = TextEditingController();
  final _maLoaiController = TextEditingController();

  List<NhanVien> _dsNhanVien = [];
  NhanVien? _selectedNhanVien;

  List<LoaiTaiKhoan> _dsLoaiTaiKhoan = [];
  LoaiTaiKhoan? _selectedLoaiTaiKhoan;

  @override
  void initState() {
    super.initState();
    _loadNhanViens();
    _loadLoaiTaiKhoans();
  }

  void _loadLoaiTaiKhoans() async {
    try {
      final service = ApiLoaiTaiKhoanService();
      final loais = await service.getAllLoaiTaiKhoan();
      setState(() {
        _dsLoaiTaiKhoan = loais;
      });
    } catch (e) {
      print('Lỗi khi tải loại tài khoản: $e');
    }
  }

  void _loadNhanViens() async {
    try {
      final nhanViens = await ApiNhanVien.fetchNhanViens();
      setState(() {
        _dsNhanVien = nhanViens;
      });
    } catch (e) {
      print('Lỗi khi tải nhân viên: $e');
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final allTK = await ApiTaiKhoan.getAllTaiKhoan();
        final exists = allTK.any((tk) => tk.maNV == _maNVController.text);

        if (exists) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Thông báo'),
              content: Text('Nhân viên này đã có tài khoản.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        final maTaiKhoan =
            'TK${_maNVController.text.replaceAll(RegExp(r'^[A-Za-z]+'), '')}';
        final tk = TaiKhoan(
          maTK: maTaiKhoan,
          tenDangNhap: _tenDangNhapController.text,
          maNV: _maNVController.text,
          maLoai: _maLoaiController.text,
          matKhau: '0123456789',
        );

        await ApiTaiKhoan.createTaiKhoan(tk);
        Navigator.pop(context);
      } catch (e) {
        print('Lỗi khi thêm tài khoản: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Thêm tài khoản'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  DropdownButtonFormField<NhanVien>(
                    value: _selectedNhanVien,
                    items: _dsNhanVien.map((nv) {
                      return DropdownMenuItem<NhanVien>(
                        value: nv,
                        child: Text(
                          '${nv.email}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNhanVien = value;
                        _maNVController.text = value?.maNV ?? '';
                        _tenDangNhapController.text = value?.email ?? '';

                        if (value != null && value.chucVu != null) {
                          final foundLoai = _dsLoaiTaiKhoan.where(
                            (loai) => loai.tenLoai == value.chucVu,
                          );
                          if (foundLoai.isNotEmpty) {
                            _selectedLoaiTaiKhoan = foundLoai.first;
                            _maLoaiController.text =
                                _selectedLoaiTaiKhoan!.maLoai;
                          } else {
                            _selectedLoaiTaiKhoan = null;
                            _maLoaiController.text = '';
                          }
                        } else {
                          _selectedLoaiTaiKhoan = null;
                          _maLoaiController.text = '';
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Mã nhân viên',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn mã nhân viên' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _tenDangNhapController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập (Email - tự động)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<LoaiTaiKhoan>(
                    value: _selectedLoaiTaiKhoan,
                    items: _dsLoaiTaiKhoan.map((loai) {
                      return DropdownMenuItem<LoaiTaiKhoan>(
                        value: loai,
                        child: Text(
                          '${loai.tenLoai}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: null, // Tự động chọn, không cho chỉnh
                    decoration: InputDecoration(
                      labelText: 'Loại tài khoản (tự động)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn loại tài khoản' : null,
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        'Thêm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
