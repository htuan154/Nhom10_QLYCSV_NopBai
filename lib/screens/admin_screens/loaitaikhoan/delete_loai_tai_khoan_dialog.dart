import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/services/api_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';
// đã sửa
class DeleteLoaiTaiKhoanDialog {
  static void show({
    required BuildContext context,
    required LoaiTaiKhoan loaiTaiKhoan,
    required VoidCallback onSuccess,
    required Function(bool) setLoading,
  }) {
    if (!_canDeleteLoaiTaiKhoan(loaiTaiKhoan)) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text('Không thể xóa'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Loại tài khoản "${loaiTaiKhoan.tenLoai}" không thể bị xóa.'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange[600], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Đây là loại tài khoản hệ thống, không được phép xóa.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Đã hiểu'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc muốn xóa loại tài khoản sau?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tên: ${loaiTaiKhoan.tenLoai}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Mã: ${loaiTaiKhoan.maLoai}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Các thay đổi sẽ được thực hiện:',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Tất cả tài khoản thuộc loại này sẽ được chuyển sang loại TEMP',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                    Text(
                      '• Chức vụ của nhân viên liên quan sẽ được cập nhật thành tên chức vụ của loại TEMP',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hành động này không thể hoàn tác!',
                style: TextStyle(
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                setLoading(true);
                try {
                  await _deleteLoaiTaiKhoan(context, loaiTaiKhoan);
                  onSuccess();
                } catch (e) {
                  print('Lỗi khi xóa loại tài khoản: $e');
                } finally {
                  setLoading(false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  static bool _canDeleteLoaiTaiKhoan(LoaiTaiKhoan loaiTaiKhoan) {
    return loaiTaiKhoan.tenLoai.trim().toUpperCase() != "TEMP";
  }

  static Future<LoaiTaiKhoan?> _findTempLoaiTaiKhoan() async {
    try {
      final apiService = ApiLoaiTaiKhoanService();
      final loaiTaiKhoans = await apiService.getAllLoaiTaiKhoan();
      final tempLoai = loaiTaiKhoans.firstWhere(
        (loai) => loai.tenLoai.trim().toUpperCase() == "TEMP",
        orElse: () => throw Exception('Không tìm thấy loại TEMP'),
      );
      return tempLoai;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _deleteLoaiTaiKhoan(
      BuildContext context, LoaiTaiKhoan loaiTaiKhoan) async {
    final accounts = await ApiTaiKhoan.getAllTaiKhoan();
    final relatedAccounts =
        accounts.where((acc) => acc.maLoai == loaiTaiKhoan.maLoai).toList();

    // Tìm loại TEMP để lấy mã và tên chức vụ mới
    final tempLoai = await _findTempLoaiTaiKhoan();
    if (tempLoai == null) {
      throw Exception('Không tìm thấy loại tài khoản TEMP');
    }

    // Cập nhật chức vụ nhân viên thành tên loại TEMP mới
    await _updateEmployeePositions(relatedAccounts, tempLoai.tenLoai);

    // Cập nhật tài khoản sang loại TEMP
    for (final acc in relatedAccounts) {
      final updatedAcc = acc.copyWith(maLoai: tempLoai.maLoai);
      await ApiTaiKhoan.updateTaiKhoan(acc.maTK!, updatedAcc);
    }

    // Xóa loại tài khoản ban đầu
    await ApiLoaiTaiKhoanService().deleteLoaiTaiKhoan(loaiTaiKhoan.maLoai);
  }

  static Future<void> _updateEmployeePositions(
      List<TaiKhoan> accountsToUpdate, String newPosition) async {
    final employeeIds = accountsToUpdate
        .where((account) =>
            account.maNV != null && account.maNV!.trim().isNotEmpty)
        .map((account) => account.maNV!)
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
