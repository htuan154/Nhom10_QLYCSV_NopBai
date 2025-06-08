import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';

import 'nhanvien_form_screen.dart';
import 'nhanvien_detail_screen.dart';

class NhanVienListScreen extends StatefulWidget {
  @override
  _NhanVienListScreenState createState() => _NhanVienListScreenState();
}

class _NhanVienListScreenState extends State<NhanVienListScreen> {
  late Future<List<NhanVien>> futureNhanViens;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureNhanViens = ApiNhanVien.fetchNhanViens();
  }

  void _refresh() {
    setState(() {
      futureNhanViens = ApiNhanVien.fetchNhanViens();
    });
  }

  // Método para mostrar confirmación de eliminación
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

  // Método para eliminar un empleado
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
        _refresh();
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

  // Método para editar un empleado
  void _editNhanVien(NhanVien nhanVien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanVienFormScreen(nhanVien: nhanVien),
      ),
    ).then((_) => _refresh());
  }

  // Método para ver detalles de un empleado
  void _viewNhanVienDetails(String maNV) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanVienDetailScreen(maNV: maNV),
      ),
    ).then((_) => _refresh());
  }

  // Método para añadir un nuevo empleado
  void _addNhanVien() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NhanVienFormScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Danh sách nhân viên'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Làm mới danh sách',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda en el futuro
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tính năng tìm kiếm đang phát triển')),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
        ],
      ),
      body: Column(
        children: [
          // Nút thêm nhân viên
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _addNhanVien,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm nhân viên'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(160, 45), 
                  ),
                ),
              ],
            ),
          ),
          // Danh sách nhân viên
          Expanded(
            child: Stack(
              children: [
                FutureBuilder<List<NhanVien>>(
                  future: futureNhanViens,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !isLoading)
                      return Center(child: CircularProgressIndicator());

                    if (snapshot.hasError) {
                      debugPrint(snapshot.error.toString());
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }

                    final nhanViens = snapshot.data ?? [];

                    if (nhanViens.isEmpty) {
                      return Center(child: Text('Không có nhân viên nào'));
                    }

                    return ListView.builder(
                      itemCount: nhanViens.length,
                      itemBuilder: (context, index) {
                        final nv = nhanViens[index];
                        return Card(
                          color: Colors.white,
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Dismissible(
                            key: Key(nv.maNV ?? 'key_$index'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              await _confirmDelete(context, nv);
                              return false; // Para mantener el elemento en la lista hasta que se confirme la eliminación
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(nv.tenNV?.substring(0, 1) ?? '?'),
                              ),
                              title: Text(nv.tenNV ?? 'Không có tên'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mã NV: ${nv.maNV ?? ''}"),
                                  if (nv.ngaySinh != null)
                                    Text("Ngày sinh: ${nv.formattedNgaySinh}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        nv.chucVu ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("Năm vào: ${nv.namVaoLam ?? ''}"),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editNhanVien(nv);
                                      } else if (value == 'delete') {
                                        _confirmDelete(context, nv);
                                      } else if (value == 'details') {
                                        _viewNhanVienDetails(nv.maNV!);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem<String>(
                                        value: 'details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info,
                                                color: Colors.blue),
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
                                            Icon(Icons.delete,
                                                color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Xóa'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _viewNhanVienDetails(nv.maNV!),
                            ),
                          ),
                        );
                      },
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
          ),
        ],
      ),
    );
  }
}
