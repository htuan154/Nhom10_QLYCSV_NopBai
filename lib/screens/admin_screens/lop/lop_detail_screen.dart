import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_lop.dart';
import 'package:doan_qlsv_nhom10/services/api_sinhvien.dart';
import 'lop_edit_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/sinh_vien/sinhvien_form_screen.dart';

class LopDetailScreen extends StatefulWidget {
  final String maLop;
  final String token;

  const LopDetailScreen({Key? key, required this.maLop, required this.token})
      : super(key: key);

  @override
  _LopDetailScreenState createState() => _LopDetailScreenState();
}

class _LopDetailScreenState extends State<LopDetailScreen> {
  final LopApiClient _lopApiClient = LopApiClient();
  late final ApiServiceSinhVien apiService;
  late Future<Lop> _lopFuture;
  late Future<List<SinhVien>> _sinhViensFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiServiceSinhVien(widget.token);
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    _lopFuture = _lopApiClient.getLop(widget.maLop);
    _sinhViensFuture = _lopApiClient.getSinhViensByLop(widget.maLop);

    try {
      await Future.wait([_lopFuture, _sinhViensFuture]);
    } catch (e) {}

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteSinhVien(SinhVien sinhVien) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await apiService.deleteSinhVien(sinhVien.maSV!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa sinh viên ${sinhVien.tenSV}')),
        );
        await _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa sinh viên')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmDialog(SinhVien sv) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa sinh viên'),
        content: Text(
            'Bạn có chắc muốn xóa vĩnh viễn sinh viên ${sv.tenSV} khỏi hệ thống không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Xóa'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteSinhVien(sv);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSinhVienDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm sinh viên vào lớp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Mã sinh viên',
                  hintText: 'Nhập mã sinh viên cần thêm',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Tạo sinh viên mới'),
                    onPressed: () {
                      Navigator.pop(context);
                      _createNewSinhVien();
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final maSV = controller.text.trim();
                if (maSV.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    await _lopApiClient.addSinhVienToLop(widget.maLop, maSV);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Thêm sinh viên vào lớp thành công')),
                    );
                    await _refreshData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewSinhVien() async {
    final lop = await _lopFuture;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinhVienFormScreen(
          token: widget.token,
          sinhVien: null,
          initialLop: lop,
        ),
      ),
    );

    if (result == true) {
      await _refreshData();
    }
  }

  Future<void> _editSinhVien(SinhVien sinhVien) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinhVienFormScreen(
          token: widget.token,
          sinhVien: sinhVien,
        ),
      ),
    );

    if (result == true) {
      await _refreshData();
    }
  }

  Widget _buildEmptySinhVienMessage() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Không có sinh viên nào trong lớp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Chi tiết lớp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final lop = await _lopFuture;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LopEditScreen(lopToEdit: lop),
                ),
              );
              if (result == true) {
                _refreshData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Lop>(
                      future: _lopFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Lỗi: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text('Không tìm thấy thông tin lớp'),
                          );
                        } else {
                          final lop = snapshot.data!;
                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thông tin lớp',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('Mã lớp'),
                                    subtitle: Text(lop.maLop),
                                  ),
                                  ListTile(
                                    title: const Text('Tên lớp'),
                                    subtitle: Text(lop.tenLop),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh sách sinh viên',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.person_add),
                              label: const Text('Tạo SV mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: _createNewSinhVien,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<SinhVien>>(
                      future: _sinhViensFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Lỗi: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return _buildEmptySinhVienMessage();
                        } else {
                          final sinhViens = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sinhViens.length,
                            itemBuilder: (context, index) {
                              final sv = sinhViens[index];
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(sv.tenSV.isNotEmpty
                                        ? sv.tenSV[0]
                                        : '?'),
                                  ),
                                  title: Text(sv.tenSV),
                                  subtitle: Text('MSSV: ${sv.maSV}'),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editSinhVien(sv);
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmDialog(sv);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Chỉnh sửa'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_forever, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Xóa'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                  onTap: () => _editSinhVien(sv),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _lopApiClient.dispose();
    super.dispose();
  }
}