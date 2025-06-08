import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';
import 'nhanvien_form_screen.dart';

class NhanVienDetailScreen extends StatefulWidget {
  final String maNV;

  NhanVienDetailScreen({required this.maNV});

  @override
  _NhanVienDetailScreenState createState() => _NhanVienDetailScreenState();
}

class _NhanVienDetailScreenState extends State<NhanVienDetailScreen> {
  late Future<NhanVien?> futureNhanVien;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureNhanVien = ApiNhanVien.fetchNhanVienById(widget.maNV);
  }

  void _refresh() {
    setState(() {
      futureNhanVien = ApiNhanVien.fetchNhanVienById(widget.maNV);
    });
  }

  Future<void> _confirmDelete(BuildContext context, NhanVien nhanVien) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa nhân viên này?'),
                SizedBox(height: 10),
                Text(
                  '${nhanVien.tenNV} (${nhanVien.maNV})',
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
                await _deleteNhanVien(nhanVien);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNhanVien(NhanVien nhanVien) async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await ApiNhanVien.deleteNhanVien(nhanVien.maNV!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa nhân viên ${nhanVien.tenNV}')),
        );
        Navigator.pop(context); // Volver a la pantalla anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa nhân viên')),
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

  void _editNhanVien(NhanVien nhanVien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanVienFormScreen(nhanVien: nhanVien),
      ),
    ).then((_) => _refresh());
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
        title: Text('Chi tiết nhân viên'),
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
          FutureBuilder<NhanVien?>(
            future: futureNhanVien,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !isLoading) return Center(child: CircularProgressIndicator());

              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }

              final nhanVien = snapshot.data;

              if (nhanVien == null) {
                return Center(
                    child: Text('Không tìm thấy thông tin nhân viên'));
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de cabecera con avatar y nombre
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              nhanVien.tenNV?.substring(0, 1) ?? '?',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            nhanVien.tenNV ?? 'Không có tên',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            nhanVien.chucVu ?? 'Không có chức vụ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Sección de información personal
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
                            _buildInfoItem('Mã nhân viên', nhanVien.maNV),
                            _buildInfoItem('Giới tính', nhanVien.gioiTinh),
                            _buildInfoItem(
                                'Ngày sinh', nhanVien.formattedNgaySinh),
                            _buildInfoItem('Địa chỉ', nhanVien.diaChi),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sección de información de contacto
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
                            _buildInfoItem('Email', nhanVien.email),
                            _buildInfoItem(
                                'Số điện thoại', nhanVien.soDienThoai),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sección de información de trabajo
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin công việc',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            _buildInfoItem('Chức vụ', nhanVien.chucVu),
                            _buildInfoItem(
                                'Năm vào làm', nhanVien.namVaoLam?.toString()),
                            _buildInfoItem(
                                'Thâm niên',
                                nhanVien.namVaoLam != null
                                    ? '${DateTime.now().year - nhanVien.namVaoLam!} năm'
                                    : null),
                          ],
                        ),
                      ),
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
      bottomNavigationBar: FutureBuilder<NhanVien?>(
        future: futureNhanVien,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) return SizedBox.shrink();

          final nhanVien = snapshot.data!;

          return BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _editNhanVien(nhanVien),
                      icon: Icon(Icons.edit, color: Colors.blue),
                      label: Text('Chỉnh sửa',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _confirmDelete(context, nhanVien),
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
