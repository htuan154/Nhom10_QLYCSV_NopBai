import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/services/api_sinhvien.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';
import 'sinhvien_form_screen.dart';
import 'package:intl/intl.dart';

class SinhVienDetailScreen extends StatefulWidget {
  final String maSV;
  final String token;

  SinhVienDetailScreen({required this.maSV, required this.token});

  @override
  _SinhVienDetailScreenState createState() => _SinhVienDetailScreenState();
}

class _SinhVienDetailScreenState extends State<SinhVienDetailScreen> {
  late Future<SinhVien> futureSinhVien;
  late ApiServiceSinhVien apiService;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiServiceSinhVien(widget.token);
    futureSinhVien = apiService.getSinhVienById(widget.maSV);
  }

  void _refresh() {
    setState(() {
      futureSinhVien = apiService.getSinhVienById(widget.maSV);
    });
  }

  Future<void> _confirmDelete(BuildContext context, SinhVien sinhVien) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa sinh viên này?'),
                SizedBox(height: 10),
                Text(
                  '${sinhVien.tenSV} (${sinhVien.maSV})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteSinhVien(sinhVien);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSinhVien(SinhVien sinhVien) async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await apiService.deleteSinhVien(sinhVien.maSV);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa sinh viên ${sinhVien.tenSV}')),
        );
        Navigator.pop(context); // Trở về màn hình trước
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa sinh viên')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editSinhVien(SinhVien sinhVien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SinhVienFormScreen(token: widget.token, sinhVien: sinhVien),
      ),
    ).then((_) => _refresh());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không có thông tin';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Không có thông tin'),
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
        title: Text('Chi tiết sinh viên'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<SinhVien>(
            future: futureSinhVien,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !isLoading) return Center(child: CircularProgressIndicator());

              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }

              final sinhVien = snapshot.data;

              if (sinhVien == null) {
                return Center(
                    child: Text('Không tìm thấy thông tin sinh viên'));
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần header với avatar và tên
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              sinhVien.tenSV.substring(0, 1),
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            sinhVien.tenSV,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            sinhVien.lopHoc,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Phần thông tin cá nhân
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            _buildInfoItem('Mã sinh viên', sinhVien.maSV),
                            _buildInfoItem('Giới tính', sinhVien.gioiTinh),
                            _buildInfoItem(
                                'Ngày sinh', _formatDate(sinhVien.ngaySinh)),
                            _buildInfoItem('Địa chỉ', sinhVien.diaChi),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Phần thông tin liên hệ
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin liên hệ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            _buildInfoItem('Email', sinhVien.email),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Phần thông tin học tập
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin học tập',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            _buildInfoItem('Lớp', sinhVien.lopHoc),
                            _buildInfoItem('Mã lớp', sinhVien.maLop),
                            _buildInfoItem('Ngành', sinhVien.nganh),
                            _buildInfoItem(
                                'Khóa học', sinhVien.khoaHoc.toString()),
                            _buildInfoItem(
                                'Loại hình đào tạo', sinhVien.loaiHinhDaoTao),
                            _buildInfoItem('Bậc đào tạo', sinhVien.bacDaoTao),
                          ],
                        ),
                      ),
                    ),

                    // Hiển thị thông tin lớp nếu có
                    if (sinhVien.lop != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông tin lớp học',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Divider(),
                                  _buildInfoItem(
                                      'Tên lớp', sinhVien.lop?.tenLop),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: FutureBuilder<SinhVien>(
        future: futureSinhVien,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) return SizedBox.shrink();

          final sinhVien = snapshot.data!;

          return BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _editSinhVien(sinhVien),
                      icon: Icon(Icons.edit, color: Colors.blue),
                      label: Text('Chỉnh sửa',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _confirmDelete(context, sinhVien),
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
