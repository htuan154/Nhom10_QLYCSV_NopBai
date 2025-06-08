import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';
import 'package:doan_qlsv_nhom10/services/api_lop.dart';
import 'lop_detail_screen.dart';
import 'lop_create_screen.dart';
import 'lop_edit_screen.dart';

class LopListScreen extends StatefulWidget {
  final String token;
  const LopListScreen({Key? key, required this.token}) : super(key: key);

  @override
  _LopListScreenState createState() => _LopListScreenState();
}

class _LopListScreenState extends State<LopListScreen> {
  final LopApiClient _lopApiClient = LopApiClient();
  late Future<List<Lop>> _lopsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshLops();
  }

  Future<void> _refreshLops() async {
    setState(() {
      _isLoading = true;
      _lopsFuture = _lopApiClient.getLops();
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteLop(String maLop) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _lopApiClient.deleteLop(maLop);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa lớp thành công')),
      );
      _refreshLops();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm mở màn hình tạo lớp mới
  Future<void> _openCreateLopScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LopCreateScreen()),
    );
    if (result == true) {
      _refreshLops();
    }
  }

  // Hàm mở màn hình chỉnh sửa lớp
  Future<void> _openEditLopScreen(Lop lop) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LopEditScreen(lopToEdit: lop)),
    );
    if (result == true) {
      _refreshLops();
    }
  }

  // Hàm hiển thị menu ba chấm
  void _showPopupMenu(BuildContext context, Lop lop) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _openEditLopScreen(lop);
      } else if (value == 'delete') {
        _showDeleteConfirmation(lop);
      }
    });
  }

  // Hàm hiển thị dialog xác nhận xóa
  void _showDeleteConfirmation(Lop lop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa lớp ${lop.tenLop} không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Xóa'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteLop(lop.maLop);
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
        title: const Text('Danh sách lớp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLops,
          ),
        ],
      ),
      body: Column(
        children: [
          // Nút thêm lớp nằm sát AppBar về phía bên phải
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _openCreateLopScreen,
              icon: const Icon(Icons.add),
              label: const Text('Thêm lớp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          // Phần danh sách lớp
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Lop>>(
                    future: _lopsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Lỗi: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Không có lớp nào'),
                        );
                      } else {
                        final lops = snapshot.data!;
                        return ListView.builder(
                          itemCount: lops.length,
                          itemBuilder: (context, index) {
                            final lop = lops[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: ListTile(
                                title: Text(
                                  'Lớp: ${lop.tenLop}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Mã lớp: ${lop.maLop}'),
                                trailing: Builder(
                                  builder: (context) => IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showPopupMenu(context, lop),
                                  ),
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LopDetailScreen(
                                        maLop: lop.maLop,
                                        token: widget.token,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _refreshLops();
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lopApiClient.dispose();
    super.dispose();
  }
}