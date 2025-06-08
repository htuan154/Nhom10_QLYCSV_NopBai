import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_tai_khoan.dart';

class NhanVienFormScreen extends StatefulWidget {
  final NhanVien? nhanVien;
  NhanVienFormScreen({this.nhanVien});

  @override
  _NhanVienFormScreenState createState() => _NhanVienFormScreenState();
}

class _NhanVienFormScreenState extends State<NhanVienFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<LoaiTaiKhoan> loaiTaiKhoanList = [];
  LoaiTaiKhoan? selectedLoaiTaiKhoan;
  LoaiTaiKhoan? originalLoaiTaiKhoan; // Lưu chức vụ ban đầu để so sánh

  late String maNV;
  String tenNV = '',
      diaChi = '',
      email = '',
      gioiTinh = '',
      soDienThoai = '',
      chucVu = '';
  late DateTime ngaySinh;
  int namVaoLam = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    if (widget.nhanVien != null) {
      final nv = widget.nhanVien!;
      maNV = nv.maNV ?? '';
      tenNV = nv.tenNV ?? '';
      diaChi = nv.diaChi ?? '';
      email = nv.email ?? '';
      gioiTinh = nv.gioiTinh ?? '';
      soDienThoai = nv.soDienThoai ?? '';
      chucVu = nv.chucVu ?? '';
      ngaySinh = nv.ngaySinh ?? DateTime.now();
      namVaoLam = nv.namVaoLam ?? 2015;
    } else {
      maNV = '';
      tenNV = '';
      diaChi = '';
      email = '';
      gioiTinh = '';
      soDienThoai = '';
      chucVu = '';
      ngaySinh = DateTime.now();
      namVaoLam = DateTime.now().year;
    }

    _fetchLoaiTaiKhoans();
  }

  Future<void> _fetchLoaiTaiKhoans() async {
    final api = ApiLoaiTaiKhoanService();
    try {
      loaiTaiKhoanList = await api.getAllLoaiTaiKhoan();
      setState(() {
        selectedLoaiTaiKhoan = loaiTaiKhoanList.firstWhere(
          (ltk) => ltk.tenLoai == chucVu,
          orElse: () => loaiTaiKhoanList.first,
        );
        // Lưu chức vụ ban đầu để so sánh
        originalLoaiTaiKhoan = selectedLoaiTaiKhoan;
      });
    } catch (e) {
      print('Lỗi khi tải loại tài khoản: $e');
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Hàm kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Hàm kiểm tra số điện thoại hợp lệ (10 số)
  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  // Hàm cập nhật mã loại trong tài khoản của nhân viên
  Future<bool> _updateTaiKhoanMaLoai(String maNV, String newMaLoai) async {
    try {
      // Lấy danh sách tất cả tài khoản
      List<TaiKhoan> allTaiKhoans = await ApiTaiKhoan.getAllTaiKhoan();
      
      // Tìm tài khoản của nhân viên này
      TaiKhoan? taiKhoanCanUpdate = allTaiKhoans.firstWhere(
        (tk) => tk.maNV == maNV,
        orElse: () => TaiKhoan(maTK: '', tenDangNhap: '', matKhau: '', maNV: '', maLoai: '', nhanVien: null, loaiTaiKhoan: null),
      );
      
      if (taiKhoanCanUpdate.maTK!.isNotEmpty) {
        // Tạo tài khoản mới với mã loại đã cập nhật
        TaiKhoan updatedTaiKhoan = TaiKhoan(
          maTK: taiKhoanCanUpdate.maTK,
          tenDangNhap: taiKhoanCanUpdate.tenDangNhap,
          matKhau: taiKhoanCanUpdate.matKhau,
          maNV: taiKhoanCanUpdate.maNV,
          maLoai: newMaLoai, // Cập nhật mã loại mới
          nhanVien: taiKhoanCanUpdate.nhanVien,
          loaiTaiKhoan: taiKhoanCanUpdate.loaiTaiKhoan,
        );
        
        // Gọi API cập nhật
        return await ApiTaiKhoan.updateTaiKhoan(taiKhoanCanUpdate.maTK!, updatedTaiKhoan);
      }
      return false;
    } catch (e) {
      print('Lỗi khi cập nhật tài khoản: $e');
      return false;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Tạo maNV nếu là thêm mới
      final timestamp = DateTime.now();
      final formattedTime =
          '${timestamp.year}${_twoDigits(timestamp.month)}${_twoDigits(timestamp.day)}'
          '${_twoDigits(timestamp.hour)}${_twoDigits(timestamp.minute)}${_twoDigits(timestamp.second)}';
      final fixedMaNV =
          widget.nhanVien?.maNV ?? 'NV${email.hashCode}$formattedTime';

      final nv = NhanVien(
        maNV: fixedMaNV,
        tenNV: tenNV,
        diaChi: diaChi,
        email: email,
        gioiTinh: gioiTinh,
        soDienThoai: soDienThoai,
        chucVu: chucVu,
        ngaySinh: ngaySinh,
        namVaoLam: namVaoLam,
      );

      bool result;
      if (widget.nhanVien == null) {
        // Thêm mới nhân viên
        result = await ApiNhanVien.addNhanVien(nv);
        
        if (result) {
          // Tạo tài khoản khi thêm mới
          if (selectedLoaiTaiKhoan != null) {
            final maTaiKhoan =
                'TK${fixedMaNV.replaceAll(RegExp(r'^[A-Za-z]+'), '')}';
            final taiKhoan = TaiKhoan(
              maTK: maTaiKhoan,
              tenDangNhap: email,
              matKhau: '0123456789',
              maNV: fixedMaNV,
              maLoai: selectedLoaiTaiKhoan!.maLoai ?? '',
              nhanVien: null,
              loaiTaiKhoan: null,
            );

            final createTKResult = await ApiTaiKhoan.createTaiKhoan(taiKhoan);
            if (!createTKResult) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tạo tài khoản mặc định thất bại')),
              );
            }
          }
        }
      } else {
        // Cập nhật nhân viên
        result = await ApiNhanVien.updateNhanVien(fixedMaNV, nv);
        
        if (result) {
          // Kiểm tra xem chức vụ có thay đổi không
          bool chucVuChanged = originalLoaiTaiKhoan?.maLoai != selectedLoaiTaiKhoan?.maLoai;
          
          if (chucVuChanged && selectedLoaiTaiKhoan != null) {
            // Cập nhật mã loại trong tài khoản
            bool updateTKResult = await _updateTaiKhoanMaLoai(
              fixedMaNV, 
              selectedLoaiTaiKhoan!.maLoai ?? ''
            );
            
            if (!updateTKResult) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cập nhật nhân viên thành công nhưng cập nhật quyền tài khoản thất bại'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cập nhật nhân viên và quyền tài khoản thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }

      if (result) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thêm/Cập nhật nhân viên thất bại.')),
        );
      }
    }
  }

  Future<void> _pickNgaySinh(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ngaySinh,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => ngaySinh = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
            widget.nhanVien == null ? 'Thêm nhân viên' : 'Cập nhật nhân viên'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.nhanVien == null)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Mã NV'),
                  onSaved: (value) => maNV = value!,
                  readOnly: true,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên nhân viên'),
                initialValue: tenNV,
                onSaved: (value) => tenNV = value!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên nhân viên';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: gioiTinh.isNotEmpty ? gioiTinh : null,
                items: ['Nam', 'Nữ'].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    gioiTinh = newValue ?? '';
                  });
                },
                onSaved: (newValue) => gioiTinh = newValue ?? '',
                decoration: InputDecoration(labelText: 'Giới tính'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng chọn giới tính'
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Địa chỉ'),
                initialValue: diaChi,
                onSaved: (value) => diaChi = value!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                ),
                initialValue: email,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!_isValidEmail(value.trim())) {
                    return 'Email không hợp lệ. Vui lòng nhập đúng định dạng (example@email.com)';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: '0123456789',
                ),
                initialValue: soDienThoai,
                keyboardType: TextInputType.phone,
                onSaved: (value) => soDienThoai = value!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!_isValidPhoneNumber(value.trim())) {
                    return 'Số điện thoại phải có đúng 10 chữ số';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<LoaiTaiKhoan>(
                value: selectedLoaiTaiKhoan,
                items: loaiTaiKhoanList.map((ltk) {
                  return DropdownMenuItem<LoaiTaiKhoan>(
                    value: ltk,
                    child: Text(ltk.tenLoai ?? ''),
                  );
                }).toList(),
                onChanged: (LoaiTaiKhoan? newValue) {
                  setState(() {
                    selectedLoaiTaiKhoan = newValue;
                    chucVu = newValue?.tenLoai ?? '';
                  });
                },
                onSaved: (newValue) => chucVu = newValue?.tenLoai ?? '',
                decoration: InputDecoration(labelText: 'Chức vụ'),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn chức vụ' : null,
              ),
              ListTile(
                title: Text(
                    'Ngày sinh: ${ngaySinh.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickNgaySinh(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Năm vào làm'),
                initialValue: namVaoLam.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    namVaoLam = int.tryParse(value!) ?? DateTime.now().year,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập năm vào làm';
                  }
                  int? year = int.tryParse(value.trim());
                  if (year == null) {
                    return 'Năm vào làm phải là số';
                  }
                  if (year < 1900 || year > DateTime.now().year) {
                    return 'Năm vào làm không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // màu xanh dương
                ),
                onPressed: _submit,
                child: Text('Lưu'),
              )
            ],
          ),
        ),
      ),
    );
  }
}