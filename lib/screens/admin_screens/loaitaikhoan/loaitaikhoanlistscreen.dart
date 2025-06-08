import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_tai_khoan.dart';
import 'create_loai_tai_khoan_dialog.dart';
import 'edit_loai_tai_khoan_dialog.dart';
import 'delete_loai_tai_khoan_dialog.dart';

class LoaiTaiKhoanListScreen extends StatefulWidget {
  const LoaiTaiKhoanListScreen({Key? key}) : super(key: key);

  @override
  _LoaiTaiKhoanListScreenState createState() => _LoaiTaiKhoanListScreenState();
}

class _LoaiTaiKhoanListScreenState extends State<LoaiTaiKhoanListScreen> {
  final ApiLoaiTaiKhoanService _apiService = ApiLoaiTaiKhoanService();
  late Future<List<LoaiTaiKhoan>> _futureLoaiTaiKhoans;
  bool _isLoading = false;
  List<LoaiTaiKhoan> _currentLoaiTaiKhoans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _futureLoaiTaiKhoans = _apiService.getAllLoaiTaiKhoan();
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _showCreateDialog() {
    CreateLoaiTaiKhoanDialog.show(
      context: context,
      currentLoaiTaiKhoans: _currentLoaiTaiKhoans,
      onSuccess: _loadData,
      setLoading: _setLoading,
    );
  }

  void _showEditDialog(LoaiTaiKhoan loaiTaiKhoan) {
    EditLoaiTaiKhoanDialog.show(
      context: context,
      loaiTaiKhoan: loaiTaiKhoan,
      currentLoaiTaiKhoans: _currentLoaiTaiKhoans,
      onSuccess: _loadData,
      setLoading: _setLoading,
    );
  }

  void _showDeleteConfirmDialog(LoaiTaiKhoan loaiTaiKhoan) {
    DeleteLoaiTaiKhoanDialog.show(
      context: context,
      loaiTaiKhoan: loaiTaiKhoan,
      onSuccess: _loadData,
      setLoading: _setLoading,
    );
  }

  // Hàm hiển thị menu popup 3 chấm
  void _showOptionsMenu(LoaiTaiKhoan loaiTaiKhoan, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditDialog(loaiTaiKhoan);
      } else if (value == 'delete') {
        _showDeleteConfirmDialog(loaiTaiKhoan);
      }
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Quản lý Loại Tài Khoản'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with create button
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh sách loại tài khoản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // List content
              Expanded(
                child: FutureBuilder<List<LoaiTaiKhoan>>(
                  future: _futureLoaiTaiKhoans,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Lỗi: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshData,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không có dữ liệu',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    _currentLoaiTaiKhoans = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _currentLoaiTaiKhoans.length,
                        itemBuilder: (context, index) {
                          final loaiTaiKhoan = _currentLoaiTaiKhoans[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8.0),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  loaiTaiKhoan.tenLoai
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'L',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                loaiTaiKhoan.tenLoai ?? 'Không có tên',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'ID: ${loaiTaiKhoan.maLoai ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  _showOptionsMenu(loaiTaiKhoan, details.globalPosition);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}