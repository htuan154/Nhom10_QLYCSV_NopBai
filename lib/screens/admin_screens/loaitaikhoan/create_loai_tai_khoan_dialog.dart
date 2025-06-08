import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart';

class CreateLoaiTaiKhoanDialog {
  static Future<void> show({
    required BuildContext context,
    required List<LoaiTaiKhoan> currentLoaiTaiKhoans,
    required VoidCallback onSuccess,
    required Function(bool) setLoading,
  }) async {
    final TextEditingController tenLoaiController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm Loại Tài Khoản'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: tenLoaiController,
                  decoration: const InputDecoration(
                    labelText: 'Tên Loại *',
                    hintText: 'Nhập tên loại tài khoản',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mã loại sẽ được tạo tự động',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
              child: const Text('Thêm'),
              onPressed: () async {
                final tenLoai = tenLoaiController.text.trim();

                if (tenLoai.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập tên loại tài khoản')),
                  );
                  return;
                }

                // Kiểm tra tên trùng
                if (_isNameDuplicate(tenLoai, currentLoaiTaiKhoans)) {
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
                  // Tạo mã loại tự động
                  final now = DateTime.now();
                  final formattedDate =
                      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
                  final maLoai = '${tenLoai.hashCode.abs()}$formattedDate';

                  final newLoaiTaiKhoan = LoaiTaiKhoan(
                    maLoai: maLoai,
                    tenLoai: tenLoai,
                  );

                  final apiService = ApiLoaiTaiKhoanService();
                  await apiService.createLoaiTaiKhoan(newLoaiTaiKhoan);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Loại tài khoản đã được thêm thành công')),
                    );
                  }

                  onSuccess();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi thêm: ${e.toString()}')),
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
  static bool _isNameDuplicate(String tenLoai, List<LoaiTaiKhoan> currentLoaiTaiKhoans, {String? excludeMaLoai}) {
    final normalizedName = tenLoai.trim().toLowerCase();
    return currentLoaiTaiKhoans.any((loai) =>
        loai.tenLoai.trim().toLowerCase() == normalizedName &&
        (excludeMaLoai == null || loai.maLoai != excludeMaLoai));
  }
}