import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_tai_khoan.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart'; // Import service mới
import 'tai_khoan_add_screen.dart';
import 'tai_khoan_edit_screen.dart';

class TaiKhoanListScreen extends StatefulWidget {
  @override
  _TaiKhoanListScreenState createState() => _TaiKhoanListScreenState();
}

class _TaiKhoanListScreenState extends State<TaiKhoanListScreen> {
  late Future<List<TaiKhoan>> _taiKhoans;
  late Future<List<LoaiTaiKhoan>> _loaiTaiKhoans;
  Map<String, String> _loaiTaiKhoanMap = {}; // Map để lưu mã -> tên

  @override
  void initState() {
    super.initState();
    _taiKhoans = ApiTaiKhoan.fetchTaiKhoans();
    _loaiTaiKhoans = _loadLoaiTaiKhoans();
  }

  Future<List<LoaiTaiKhoan>> _loadLoaiTaiKhoans() async {
    try {
      final apiService = ApiLoaiTaiKhoanService();
      final loaiTKList = await apiService.getAllLoaiTaiKhoan();

      // Tạo map để tra cứu nhanh
      _loaiTaiKhoanMap = {
        for (var loaiTK in loaiTKList) loaiTK.maLoai: loaiTK.tenLoai
      };

      return loaiTKList;
    } catch (e) {
      print('Error loading loai tai khoan: $e');
      return [];
    }
  }

  void _refreshList() {
    setState(() {
      _taiKhoans = ApiTaiKhoan.fetchTaiKhoans();
      _loaiTaiKhoans = _loadLoaiTaiKhoans();
    });
  }

  void _deleteTaiKhoan(String id) async {
    await ApiTaiKhoan.deleteTaiKhoan(id);
    _refreshList();
  }

  // Hàm để lấy tên loại tài khoản từ mã
  String _getLoaiTaiKhoanName(String maLoaiTK) {
    return _loaiTaiKhoanMap[maLoaiTK] ?? 'UNKNOWN';
  }

  // Hàm tạo tất cả tài khoản
  void _createAllAccounts() async {
    final msg = await ApiTaiKhoan.createBulkTaiKhoans();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Text('Danh sách tài khoản')),
      body: Column(
        children: [
          // Phần nút điều khiển nằm ngang
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Nút thêm tài khoản bên trái
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaiKhoanAddScreen()),
                    );
                    _refreshList();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm tài khoản'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // hoặc màu bạn muốn
                    foregroundColor: Colors.white,
                  ),
                ),
                Spacer(), // Đẩy nút bên phải ra xa
                // Nút tạo tất cả bên phải
                ElevatedButton.icon(
                  onPressed: _createAllAccounts,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Tạo tất cả'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Phần danh sách tài khoản
          Expanded(
            child: FutureBuilder(
              future: Future.wait([_taiKhoans, _loaiTaiKhoans]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  List<TaiKhoan> taiKhoans =
                      snapshot.data![0] as List<TaiKhoan>;
                  // Loại tài khoản đã được load trong _loadLoaiTaiKhoans()

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: taiKhoans.length,
                    itemBuilder: (context, index) {
                      final tk = taiKhoans[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar tròn bên trái
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    tk.tenDangNhap.isNotEmpty
                                        ? tk.tenDangNhap[0].toUpperCase()
                                        : 'T',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // Thông tin tài khoản
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tk.tenDangNhap,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              // Badge hiển thị tên loại tài khoản với nền xám chữ đen
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300], // Nền xám
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getLoaiTaiKhoanName(tk.maLoai).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black, // Chữ đen
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Menu ba chấm
                              PopupMenuButton<String>(
                                onSelected: (String value) async {
                                  if (value == 'edit') {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TaiKhoanEditScreen(taiKhoan: tk),
                                      ),
                                    );
                                    _refreshList();
                                  } else if (value == 'delete') {
                                    // Hiển thị dialog xác nhận trước khi xóa
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Xác nhận xóa'),
                                          content: Text(
                                              'Bạn có chắc chắn muốn xóa tài khoản "${tk.tenDangNhap}" không?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Hủy'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Xóa',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _deleteTaiKhoan(tk.maTK);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Chỉnh sửa'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Xóa'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi khi tải dữ liệu',
                            style: TextStyle(color: Colors.red)),
                        SizedBox(height: 10),
                        Text(snapshot.error.toString(),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
