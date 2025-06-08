import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/loai_yeu_cau.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_yeu_cau.dart';

class LoaiYeuCauListScreen extends StatefulWidget {
  const LoaiYeuCauListScreen({Key? key}) : super(key: key);

  @override
  _LoaiYeuCauListScreenState createState() => _LoaiYeuCauListScreenState();
}

class _LoaiYeuCauListScreenState extends State<LoaiYeuCauListScreen> {
  final ApiLoaiYeuCauService _apiService = ApiLoaiYeuCauService();

  late Future<List<LoaiYeuCau>> _futureLoaiYeuCaus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _futureLoaiYeuCaus = _apiService.getAllLoaiYeuCau();
    });
  }

  Future<void> _deleteLoaiYeuCau(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.deleteLoaiYeuCau(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loại yêu cầu đã được xóa thành công')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm hiển thị menu ba chấm
  void _showPopupMenu(BuildContext context, LoaiYeuCau item) async {
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
        _showAddEditDialog(loaiYeuCau: item);
      } else if (value == 'delete') {
        _showDeleteConfirmation(item);
      }
    });
  }

  // Hàm hiển thị dialog xác nhận xóa
  void _showDeleteConfirmation(LoaiYeuCau item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Xóa loại yêu cầu "${item.tenLoaiYC}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteLoaiYeuCau(item.maLoaiYC);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddEditDialog({LoaiYeuCau? loaiYeuCau}) async {
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyyMMddHHmmss').format(now);
    final isEditing = loaiYeuCau != null;

    final TextEditingController tenLoaiController = TextEditingController(
      text: loaiYeuCau?.tenLoaiYC ?? '',
    );

    final TextEditingController maLoaiController = TextEditingController(
      text: isEditing
          ? loaiYeuCau!.maLoaiYC
          : '${tenLoaiController.hashCode}$formattedTime',
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Sửa Loại Yêu Cầu' : 'Thêm Loại Yêu Cầu'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: maLoaiController,
                  decoration:
                      const InputDecoration(labelText: 'Mã Loại Yêu Cầu'),
                  readOnly: true, // Ngăn chỉnh sửa mã
                ),
                TextField(
                  controller: tenLoaiController,
                  decoration:
                      const InputDecoration(labelText: 'Tên Loại Yêu Cầu'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
              onPressed: () async {
                if (maLoaiController.text.isEmpty ||
                    tenLoaiController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng điền đầy đủ thông tin')),
                  );
                  return;
                }

                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  final newLoaiYeuCau = LoaiYeuCau(
                    maLoaiYC: maLoaiController.text.trim(),
                    tenLoaiYC: tenLoaiController.text.trim(),
                  );

                  if (isEditing) {
                    await _apiService.updateLoaiYeuCau(
                        loaiYeuCau!.maLoaiYC, newLoaiYeuCau);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công')),
                    );
                  } else {
                    final existingLoaiYeuCaus =
                        await _apiService.getAllLoaiYeuCau();
                    final isDuplicate = existingLoaiYeuCaus.any(
                      (item) =>
                          item.maLoaiYC.toLowerCase() ==
                          newLoaiYeuCau.maLoaiYC.toLowerCase(),
                    );

                    if (isDuplicate) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Mã loại yêu cầu đã tồn tại')),
                      );
                      return;
                    }

                    await _apiService.createLoaiYeuCau(newLoaiYeuCau);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm thành công')),
                    );
                  }

                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Danh Sách Loại Yêu Cầu'),
      ),
      body: Column(
        children: [
          // Nút thêm loại yêu cầu đặt bên dưới AppBar, sát bên phải
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm loại yêu cầu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Nội dung chính
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: FutureBuilder<List<LoaiYeuCau>>(
                    future: _futureLoaiYeuCaus,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Lỗi: ${snapshot.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Không có dữ liệu'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Làm mới'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final loaiYeuCaus = snapshot.data!;
                        return ListView.builder(
                          itemCount: loaiYeuCaus.length,
                          itemBuilder: (context, index) {
                            final item = loaiYeuCaus[index];
                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: ListTile(
                                title: Text(item.tenLoaiYC),
                                subtitle: Text('Mã: ${item.maLoaiYC}'),
                                trailing: Builder(
                                  builder: (context) => IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showPopupMenu(context, item),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}