import 'package:flutter/material.dart';
import 'dart:async';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'thongbao_add_screen.dart';
import 'thongbao_edit_screen.dart';

class ThongBaoListScreen extends StatefulWidget {
  final String token;
  const ThongBaoListScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ThongBaoListScreenState createState() => _ThongBaoListScreenState();
}

class _ThongBaoListScreenState extends State<ThongBaoListScreen> {
  late ApiThongBaoService _apiThongBaoService;
  late ApiServiceTaiKhoanSinhVien _apiTKSV;
  late ApiNewsService _apiNews;

  List<ThongBao> _thongBaos = []; // Thông báo đã tải hiển thị trên UI
  List<TaiKhoanSinhVien> _taiKhoanSinhViens = [];
  List<TinTuc> _tinTucs = [];

  // Các biến cho pagination
  final int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMoreData = true;
  List<ThongBao> _allThongBaos = []; // Lưu tất cả thông báo từ API

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  // Controller để theo dõi vị trí cuộn
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _apiThongBaoService = ApiThongBaoService(widget.token);
    _apiTKSV = ApiServiceTaiKhoanSinhVien(widget.token);
    _apiNews = ApiNewsService(widget.token);

    // Thêm listener để phát hiện khi cuộn đến cuối danh sách
    _scrollController.addListener(_scrollListener);

    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener theo dõi việc cuộn
  void _scrollListener() {
    // Nếu người dùng đã cuộn đến khoảng 200px trước cuối danh sách
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  // Tải dữ liệu ban đầu
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _hasMoreData = true;
      _thongBaos = [];
      _allThongBaos = [];
    });

    try {
      // Tải toàn bộ danh sách sinh viên và tin tức
      final tksvList = await _apiTKSV.getTaiKhoanSinhViens();
      final tinTucList = await _apiNews.getTinTucs();

      // Tải toàn bộ thông báo từ API hiện có
      final allThongBaos = await _apiThongBaoService.getThongBaos();

      // Sắp xếp theo ngày tạo (mới nhất lên đầu)
      allThongBaos.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));

      setState(() {
        _taiKhoanSinhViens = tksvList;
        _tinTucs = tinTucList;
        _allThongBaos = allThongBaos;

        // Tải trang đầu tiên
        _loadPageData();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Tải dữ liệu của một trang cụ thể từ cache đã tải trước đó
  void _loadPageData() {
    final start = _currentPage * _pageSize;

    if (start >= _allThongBaos.length) {
      setState(() {
        _hasMoreData = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final end = start + _pageSize <= _allThongBaos.length
        ? start + _pageSize
        : _allThongBaos.length;

    final pageItems = _allThongBaos.sublist(start, end);

    setState(() {
      _thongBaos.addAll(pageItems);
      _hasMoreData = end < _allThongBaos.length;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  // Tải thêm dữ liệu khi cuộn xuống
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Sử dụng Future.delayed để tránh blocking UI thread và tạo hiệu ứng tải dữ liệu
    await Future.delayed(const Duration(milliseconds: 300));
    _loadPageData();
  }

  // Làm mới toàn bộ dữ liệu
  Future<void> _refreshData() async {
    await _loadInitialData();
    return;
  }

  Future<void> _deleteThongBao(ThongBao thongBao) async {
    try {
      final success = await _apiThongBaoService.deleteThongBao(
        thongBao.maTT,
        thongBao.maTKSV,
      );

      if (success) {
        setState(() {
          // Xóa khỏi danh sách hiển thị
          _thongBaos.removeWhere((item) =>
              item.maTT == thongBao.maTT && item.maTKSV == thongBao.maTKSV);

          // Xóa khỏi danh sách đầy đủ
          _allThongBaos.removeWhere((item) =>
              item.maTT == thongBao.maTT && item.maTKSV == thongBao.maTKSV);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thông báo thành công')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa thông báo: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Nút thêm thông báo
          // Nút thêm thông báo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Căn nút về phía bên phải
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ThongBaoAddScreen(token: widget.token),
                      ),
                    );
                    if (result == true) {
                      _refreshData();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thông báo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Danh sách thông báo
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _currentPage == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Đã xảy ra lỗi:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _refreshData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_thongBaos.isEmpty) {
      return const Center(child: Text('Không có thông báo nào'));
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _thongBaos.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Hiển thị loading indicator ở cuối danh sách khi đang tải thêm
          if (index == _thongBaos.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final thongBao = _thongBaos[index];
          final isChuaXem =
              thongBao.trangThai.trim().toLowerCase() == 'chưa xem';

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text('Thông báo #${thongBao.maTT}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày tạo: ${_formatDate(thongBao.ngayTao)}'),
                  Text('Người nhận: ${thongBao.maTKSV}'),
                  Text('Trạng thái: ${thongBao.trangThai}'),
                ],
              ),
              leading: Icon(
                isChuaXem ? Icons.mark_email_unread : Icons.mark_email_read,
                color: isChuaXem ? Colors.red : Colors.green,
                size: 28,
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (String value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThongBaoEditScreen(
                          token: widget.token,
                          thongBao: thongBao,
                        ),
                      ),
                    );
                    if (result == true) {
                      _refreshData();
                    }
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(thongBao);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () async {
                if (!mounted) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThongBaoEditScreen(
                      token: widget.token,
                      thongBao: thongBao,
                    ),
                  ),
                );
                if (result == true) {
                  _refreshData();
                }
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format lại ngày để hiển thị với padding số 0
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  void _showDeleteConfirmation(ThongBao thongBao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
              'Bạn có chắc chắn muốn xóa thông báo #${thongBao.maTT} của ${thongBao.maTKSV} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteThongBao(thongBao);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
