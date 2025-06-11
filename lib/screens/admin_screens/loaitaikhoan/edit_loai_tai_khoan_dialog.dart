import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/services/api_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';

class EditLoaiTaiKhoanDialog {
  static Future<void> show({
    required BuildContext context,
    required LoaiTaiKhoan loaiTaiKhoan,
    required List<LoaiTaiKhoan> currentLoaiTaiKhoans,
    required VoidCallback onSuccess,
    required Function(bool) setLoading,
  }) async {
    final String tenLoaiUpper = loaiTaiKhoan.tenLoai.trim().toUpperCase();

    // Kiểm tra nếu loại tài khoản là TEMP hoặc ADMINISTRATOR thì không cho phép sửa
    if (tenLoaiUpper == 'TEMP' || tenLoaiUpper == 'ADMINISTRATOR') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Không thể chỉnh sửa loại tài khoản ${loaiTaiKhoan.tenLoai}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController tenLoaiController = TextEditingController(
      text: loaiTaiKhoan.tenLoai,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh Sửa Loại Tài Khoản'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Hiển thị mã loại (chỉ đọc)
                TextField(
                  controller: TextEditingController(text: loaiTaiKhoan.maLoai),
                  decoration: const InputDecoration(
                    labelText: 'Mã Loại',
                    prefixIcon: Icon(Icons.lock, size: 20),
                  ),
                  readOnly: true,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // Trường tên loại có thể chỉnh sửa
                TextField(
                  controller: tenLoaiController,
                  decoration: const InputDecoration(
                    labelText: 'Tên Loại *',
                    hintText: 'Nhập tên loại tài khoản',
                    prefixIcon: Icon(Icons.edit, size: 20),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chỉ có thể thay đổi tên loại, mã loại không thể sửa',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu Thay Đổi'),
              onPressed: () async {
                final tenLoai = tenLoaiController.text.trim();

                if (tenLoai.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập tên loại tài khoản')),
                  );
                  return;
                }

                // Kiểm tra không được đổi thành tên TEMP hoặc ADMINISTRATOR
                final tenLoaiUpper = tenLoai.toUpperCase();
                if (tenLoaiUpper == 'TEMP' || tenLoaiUpper == 'ADMINISTRATOR') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Không thể đặt tên loại tài khoản là $tenLoai'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Kiểm tra xem có thay đổi gì không
                if (tenLoai == loaiTaiKhoan.tenLoai) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Không có thay đổi nào để lưu')),
                  );
                  return;
                }

                // Kiểm tra tên trùng (trừ chính record này)
                if (_isNameDuplicate(tenLoai, currentLoaiTaiKhoans,
                    excludeMaLoai: loaiTaiKhoan.maLoai)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Tên loại "$tenLoai" đã tồn tại. Vui lòng chọn tên khác.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();

                setLoading(true);

                try {
                  // Tạo object với mã loại cũ, chỉ thay đổi tên
                  final updatedLoaiTaiKhoan = LoaiTaiKhoan(
                    maLoai: loaiTaiKhoan.maLoai, // Giữ nguyên mã loại cũ
                    tenLoai: tenLoai,
                  );

                  final apiService = ApiLoaiTaiKhoanService();
                  await apiService.updateLoaiTaiKhoan(
                      loaiTaiKhoan.maLoai, updatedLoaiTaiKhoan);

                  // Cập nhật chức vụ nhân viên tương tự logic trong delete
                  await _updateEmployeePositionsOfAccounts(
                      loaiTaiKhoan.maLoai, tenLoai);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Loại tài khoản đã được cập nhật thành công')),
                    );
                  }

                  onSuccess();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Lỗi khi cập nhật: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setLoading(false);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm kiểm tra tên loại có trùng không
  static bool _isNameDuplicate(
      String tenLoai, List<LoaiTaiKhoan> currentLoaiTaiKhoans,
      {String? excludeMaLoai}) {
    final normalizedName = tenLoai.trim().toLowerCase();
    return currentLoaiTaiKhoans.any((loai) =>
        loai.tenLoai.trim().toLowerCase() == normalizedName &&
        (excludeMaLoai == null || loai.maLoai != excludeMaLoai));
  }

  // Cập nhật chức vụ nhân viên của các tài khoản thuộc loại vừa sửa tên
  static Future<void> _updateEmployeePositionsOfAccounts(
      String maLoaiSua, String newPosition) async {
    final accounts = await ApiTaiKhoan.getAllTaiKhoan();
    final relatedAccounts =
        accounts.where((acc) => acc.maLoai == maLoaiSua).toList();

    if (relatedAccounts.isEmpty) return;

    final employeeIds = relatedAccounts
        .where((acc) => acc.maNV != null && acc.maNV!.trim().isNotEmpty)
        .map((acc) => acc.maNV!)
        .toSet();

    if (employeeIds.isEmpty) return;

    final allEmployees = await ApiNhanVien.fetchNhanViens();
    final employeesToUpdate =
        allEmployees.where((nv) => employeeIds.contains(nv.maNV)).toList();

    final chucVuToUpdate =
        (newPosition.trim().isNotEmpty) ? newPosition.trim() : "TEMP";

    for (final nv in employeesToUpdate) {
      final updatedNV = NhanVien(
        maNV: nv.maNV,
        tenNV: nv.tenNV,
        diaChi: nv.diaChi,
        ngaySinh: nv.ngaySinh,
        namVaoLam: nv.namVaoLam,
        chucVu: chucVuToUpdate,
        email: nv.email,
        gioiTinh: nv.gioiTinh,
        soDienThoai: nv.soDienThoai,
        taiKhoans: null,
      );
      await ApiNhanVien.updateNhanVien(nv.maNV!, updatedNV);
    }
  }
}
