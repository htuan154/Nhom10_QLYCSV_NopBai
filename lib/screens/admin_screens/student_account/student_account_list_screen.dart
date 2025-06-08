// lib/screens/student_account/student_account_list_screen.dart
import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/student_account/student_account_detail_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/student_account/student_account_add_screen.dart';

class StudentAccountListScreen extends StatefulWidget {
  final String token;

  const StudentAccountListScreen({Key? key, required this.token})
      : super(key: key);

  @override
  _StudentAccountListScreenState createState() =>
      _StudentAccountListScreenState();
}

class _StudentAccountListScreenState extends State<StudentAccountListScreen> {
  late ApiServiceTaiKhoanSinhVien _apiService;
  late ApiThongBaoService _apiThongBao;
  late ApiNewsService _apiNews;
  
  List<TaiKhoanSinhVien> _accounts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  List<TaiKhoanSinhVien> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiServiceTaiKhoanSinhVien(widget.token);
    _apiThongBao = ApiThongBaoService(widget.token);
    _apiNews = ApiNewsService(widget.token);
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final accounts = await _apiService.getTaiKhoanSinhViens();
      setState(() {
        _accounts = accounts;
        _filteredAccounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorDialog(_errorMessage);
    }
  }

  void _filterAccounts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = _accounts;
      } else {
        _filteredAccounts = _accounts
            .where((account) =>
                account.maTKSV.toLowerCase().contains(query.toLowerCase()) ||
                account.maSV.toLowerCase().contains(query.toLowerCase()) ||
                account.tenDangNhap.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteAccount(String id) async {
    try {
      await _apiService.deleteTaiKhoanSinhVien(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản đã được xóa thành công')),
      );
      _loadAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa tài khoản: ${e.toString()}')),
      );
    }
  }

  // Hàm tạo thông báo cho tài khoản mới được tạo
  Future<void> _taoThongBaoChoTaiKhoanMoi(List<TaiKhoanSinhVien> newAccounts) async {
    try {
      // Tải danh sách tin tức
      final tinTucs = await _apiNews.getTinTucs();
      
      if (tinTucs.isEmpty) {
        print('Không có tin tức nào để tạo thông báo');
        return;
      }

      // Tải tất cả thông báo hiện tại để kiểm tra trùng lặp
      final allThongBaos = await _apiThongBao.getThongBaos();
      
      int successCount = 0;

      // Duyệt từng tài khoản mới và từng tin tức
      for (var account in newAccounts) {
        for (var tinTuc in tinTucs) {
          // Kiểm tra xem thông báo đã tồn tại chưa
          final exists = allThongBaos.any((tb) => 
              tb.maTT == tinTuc.maTT && tb.maTKSV == account.maTKSV);

          if (!exists) {
            final thongBao = ThongBao(
              maTT: tinTuc.maTT,
              maTKSV: account.maTKSV,
              ngayTao: DateTime.now(),
              trangThai: 'Chưa xem',
            );
            
            await _apiThongBao.createThongBao(thongBao);
            successCount++;
          }
        }
      }

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo $successCount thông báo cho tài khoản mới'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tạo thông báo: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _createAllAccounts() async {
  // Hiển thị dialog loading với layout cải thiện
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Đang tạo tài khoản và thông báo...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );

  try {
    // Lấy danh sách tài khoản hiện tại trước khi tạo mới
    final accountsBefore = await _apiService.getTaiKhoanSinhViens();
    
    // Tạo tất cả tài khoản sinh viên
    final result = await _apiService.TaoTatCaTaiKhoanSinhVien();
    
    if (result) {
      // Lấy danh sách tài khoản sau khi tạo mới
      final accountsAfter = await _apiService.getTaiKhoanSinhViens();
      
      // Tìm những tài khoản mới được tạo
      final newAccounts = accountsAfter.where((afterAccount) =>
          !accountsBefore.any((beforeAccount) => 
              beforeAccount.maTKSV == afterAccount.maTKSV)).toList();

      // Đóng dialog loading
      if (mounted) Navigator.pop(context);

      if (newAccounts.isNotEmpty) {
        // Tạo thông báo cho những tài khoản mới
        await _taoThongBaoChoTaiKhoanMoi(newAccounts);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo ${newAccounts.length} tài khoản sinh viên mới và thông báo thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có tài khoản mới nào được tạo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      // Reload danh sách
      _loadAccounts();
    } else {
      // Đóng dialog loading
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi tạo tài khoản'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Đóng dialog loading
    if (mounted) Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi khi tạo tài khoản: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(TaiKhoanSinhVien account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa tài khoản ${account.maTKSV}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(account.maTKSV);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(TaiKhoanSinhVien account, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'edit') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentAccountDetailScreen(
              token: widget.token,
              accountId: account.maTKSV,
            ),
          ),
        );
        if (result == true) {
          _loadAccounts();
        }
      } else if (value == 'delete') {
        _showDeleteConfirmDialog(account);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Quản lý tài khoản sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccounts,
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm tài khoản',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterAccounts('');
                  },
                ),
              ),
              onChanged: _filterAccounts,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ElevatedButton.icon(
                //   onPressed: () async {
                //     final result = await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) =>
                //             StudentAccountAddScreen(token: widget.token),
                //       ),
                //     );
                //     if (result == true) {
                //       _loadAccounts();
                //     }
                //   },
                //   icon: const Icon(Icons.add),
                //   label: const Text('Thêm tài khoản'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     foregroundColor: Colors.white,
                //   ),
                // ),
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
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đã xảy ra lỗi',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(_errorMessage),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAccounts,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _filteredAccounts.isEmpty
                        ? const Center(child: Text('Không có tài khoản nào'))
                        : RefreshIndicator(
                            onRefresh: _loadAccounts,
                            child: ListView.builder(
                              itemCount: _filteredAccounts.length,
                              itemBuilder: (context, index) {
                                final account = _filteredAccounts[index];
                                return Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    title: Text('Mã TK: ${account.maTKSV}'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Mã SV: ${account.maSV}'),
                                        Text(
                                            'Tên đăng nhập: ${account.tenDangNhap}'),
                                      ],
                                    ),
                                    trailing: GestureDetector(
                                      onTapDown: (TapDownDetails details) {
                                        _showOptionsMenu(
                                            account, details.globalPosition);
                                      },
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StudentAccountDetailScreen(
                                            token: widget.token,
                                            accountId: account.maTKSV,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadAccounts();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}