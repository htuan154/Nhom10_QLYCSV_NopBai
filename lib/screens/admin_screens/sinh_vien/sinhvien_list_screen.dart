import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/services/api_sinhvien.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';

import 'sinhvien_form_screen.dart';
import 'sinhvien_detail_screen.dart';

class SinhVienListScreen extends StatefulWidget {
  final String token;

  const SinhVienListScreen({Key? key, required this.token}) : super(key: key);

  @override
  _SinhVienListScreenState createState() => _SinhVienListScreenState();
}

class _SinhVienListScreenState extends State<SinhVienListScreen> {
  late Future<List<SinhVien>> futureSinhViens;
  late ApiServiceSinhVien apiService;
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    apiService = ApiServiceSinhVien(widget.token);
    _loadSinhViens();
  }

  void _loadSinhViens() {
    setState(() {
      futureSinhViens = searchQuery.isEmpty
          ? apiService.getSinhViens()
          : apiService.searchSinhVien(searchQuery);
    });
  }

  void _refresh() {
    setState(() {
      searchQuery = '';
      _loadSinhViens();
    });
  }

  // Phương thức hiển thị xác nhận xóa
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

  // Phương thức xóa sinh viên
  Future<void> _deleteSinhVien(SinhVien sinhVien) async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await apiService.deleteSinhVien(sinhVien.maSV!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa sinh viên ${sinhVien.tenSV}')),
        );
        _refresh();
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

  // Phương thức chỉnh sửa sinh viên
  void _editSinhVien(SinhVien sinhVien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SinhVienFormScreen(token: widget.token, sinhVien: sinhVien),
      ),
    ).then((_) => _refresh());
  }

  // Phương thức xem chi tiết sinh viên
  void _viewSinhVienDetails(String maSV) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SinhVienDetailScreen(token: widget.token, maSV: maSV),
      ),
    ).then((_) => _refresh());
  }

  // Phương thức thêm sinh viên mới
  void _addSinhVien() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SinhVienFormScreen(token: widget.token),
      ),
    ).then((result) {
      if (result == true) {
        _refresh();
      }
    });
  }

  // Phương thức tìm kiếm sinh viên
  void _showSearchDialog() {
    final TextEditingController searchController =
        TextEditingController(text: searchQuery);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tìm kiếm sinh viên'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Nhập tên sinh viên',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Tìm kiếm'),
            onPressed: () {
              setState(() {
                searchQuery = searchController.text;
                futureSinhViens = apiService.searchSinhVien(searchQuery);
              });
              Navigator.of(context).pop();
            },
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
        title: Text('Danh sách sinh viên'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Làm mới danh sách',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Tìm kiếm',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Nút thêm sinh viên nằm bên dưới AppBar, sát bên phải
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addSinhVien,
                      icon: const Icon(Icons.group_add),
                      label: const Text('Thêm sinh viên'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Nội dung danh sách sinh viên
              Expanded(
                child: FutureBuilder<List<SinhVien>>(
                  future: futureSinhViens,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !isLoading)
                      return Center(child: CircularProgressIndicator());

                    if (snapshot.hasError) {
                      debugPrint(snapshot.error.toString());
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }

                    final sinhViens = snapshot.data ?? [];

                    if (sinhViens.isEmpty) {
                      return Center(child: Text('Không có sinh viên nào'));
                    }

                    return ListView.builder(
                      itemCount: sinhViens.length,
                      itemBuilder: (context, index) {
                        final sv = sinhViens[index];
                        return Card(
                          color: Colors.white,
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Dismissible(
                            key: Key(sv.maSV ?? 'key_$index'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              await _confirmDelete(context, sv);
                              return false; // Để giữ phần tử trong danh sách cho đến khi xác nhận xóa
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(sv.tenSV?.substring(0, 1) ?? '?'),
                              ),
                              title: Text(sv.tenSV ?? 'Không có tên'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Lớp: ${sv.lopHoc ?? ''}"),
                                  // Hiển thị MSSV trong subtitle để tránh bị overflow
                                  Text(
                                    "MSSV: ${sv.maSV ?? ''}",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 48, // Giới hạn độ rộng của trailing
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editSinhVien(sv);
                                    } else if (value == 'delete') {
                                      _confirmDelete(context, sv);
                                    } else if (value == 'details') {
                                      _viewSinhVienDetails(sv.maSV!);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'details',
                                      child: Row(
                                        children: [
                                          Icon(Icons.info, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Chi tiết'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              color: Colors.orange),
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
                              ),
                              onTap: () => _viewSinhVienDetails(sv.maSV!),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
