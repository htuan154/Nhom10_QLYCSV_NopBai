import 'package:flutter/material.dart';
import 'dart:async';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/class/thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'package:doan_qlsv_nhom10/screens/notification/components/notification_card_for_news.dart';
import 'package:doan_qlsv_nhom10/screens/notification/components/notification_card_for_request.dart';
import 'package:doan_qlsv_nhom10/screens/request/request_detail_screen.dart';
import 'package:doan_qlsv_nhom10/screens/home/detail_tintuc.dart';

// Base class cho notification item
abstract class NotificationItem {
  DateTime get dateTime;
  String get id;
  String get status;
  bool get isUnread => status.trim().toLowerCase() == 'chưa xem';
}

// Wrapper cho ThongBao
class ThongBaoItem extends NotificationItem {
  final ThongBao thongBao;

  ThongBaoItem(this.thongBao);

  @override
  DateTime get dateTime => thongBao.ngayTao;

  @override
  String get id => thongBao.maTT;

  @override
  String get status => thongBao.trangThai;
}

// Wrapper cho ThongBaoYeuCau
class ThongBaoYeuCauItem extends NotificationItem {
  final ThongBaoYeuCau thongBaoYeuCau;

  ThongBaoYeuCauItem(this.thongBaoYeuCau);

  @override
  DateTime get dateTime => thongBaoYeuCau.ngayThongBao;

  @override
  String get id => thongBaoYeuCau.maTBYC;

  @override
  String get status => thongBaoYeuCau.trangThai;
}

class SearchNotificationScreen extends StatefulWidget {
  final String token;
  final String maTKSV;

  const SearchNotificationScreen(
      {Key? key, required this.token, required this.maTKSV})
      : super(key: key);

  @override
  _SearchNotificationScreenState createState() =>
      _SearchNotificationScreenState();
}

class _SearchNotificationScreenState extends State<SearchNotificationScreen> {
  late ApiThongBaoService _apiThongBaoService;
  late ApiThongBaoYeuCauService _apiThongBaoYeuCauService;
  late ApiNewsService _apiNewsService;

  List<ThongBao> _allThongBaos = [];
  List<ThongBaoYeuCau> _allThongBaoYeuCaus = [];
  List<TinTuc> _allTinTucs = [];
  List<NotificationItem> _allNotifications = [];
  List<NotificationItem> _searchResults = [];

  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _apiThongBaoService = ApiThongBaoService(widget.token);
    _apiThongBaoYeuCauService = ApiThongBaoYeuCauService();
    _apiNewsService = ApiNewsService(widget.token);

    _searchController.addListener(_onSearchChanged);
    _loadAllNotifications();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  // Lắng nghe thay đổi trong ô tìm kiếm
  void _onSearchChanged() {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  // Tải tất cả thông báo và tin tức
  Future<void> _loadAllNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Tải song song cả 3 loại: ThongBao, ThongBaoYeuCau, và TinTuc
      final results = await Future.wait([
        _apiThongBaoService.getThongBaosByTaiKhoan(widget.maTKSV),
        _apiThongBaoYeuCauService.getThongBaoByTaiKhoanSinhVien(widget.maTKSV),
        _apiNewsService.getTinTucs(),
      ]);

      final thongBaos = results[0] as List<ThongBao>;
      final thongBaoYeuCaus = results[1] as List<ThongBaoYeuCau>;
      final tinTucs = results[2] as List<TinTuc>;

      // Gộp và sắp xếp theo thời gian
      _combineAndSortNotifications(thongBaos, thongBaoYeuCaus);

      setState(() {
        _allThongBaos = thongBaos;
        _allThongBaoYeuCaus = thongBaoYeuCaus;
        _allTinTucs = tinTucs;
        _searchResults =
            List.from(_allNotifications); // Hiển thị tất cả ban đầu
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Gộp và sắp xếp thông báo theo thời gian
  void _combineAndSortNotifications(
      List<ThongBao> thongBaos, List<ThongBaoYeuCau> thongBaoYeuCaus) {
    List<NotificationItem> combined = [];

    // Thêm ThongBao vào danh sách
    for (var thongBao in thongBaos) {
      combined.add(ThongBaoItem(thongBao));
    }

    // Thêm ThongBaoYeuCau vào danh sách
    for (var thongBaoYeuCau in thongBaoYeuCaus) {
      combined.add(ThongBaoYeuCauItem(thongBaoYeuCau));
    }

    // Sắp xếp theo thời gian (mới nhất lên đầu)
    combined.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    _allNotifications = combined;
  }

  // Thực hiện tìm kiếm
  Future<void> _performSearch(String searchText) async {
    if (searchText.trim().isEmpty) {
      setState(() {
        _searchResults = List.from(_allNotifications);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<NotificationItem> filteredResults = [];

      // Tìm kiếm trong ThongBaoYeuCau (tìm theo nội dung)
      for (var item in _allNotifications) {
        if (item is ThongBaoYeuCauItem) {
          if (item.thongBaoYeuCau.noiDung
              .toLowerCase()
              .contains(searchText.toLowerCase().trim())) {
            filteredResults.add(item);
          }
        }
      }

      // Tìm kiếm trong ThongBao (tìm theo nội dung TinTuc tương ứng)
      for (var item in _allNotifications) {
        if (item is ThongBaoItem) {
          // Tìm TinTuc tương ứng với mã ThongBao
          var tinTuc = _allTinTucs.firstWhere(
            (tt) => tt.maTT == item.thongBao.maTT,
            orElse: () => TinTuc(
                maTT: '', noiDung: '', ngayTao: DateTime.now(), maTK: ''),
          );

          if (tinTuc.maTT.isNotEmpty) {
            // Tìm kiếm trong tiêu đề và nội dung của tin tức
            String searchInText = '${tinTuc.noiDung}'.toLowerCase();
            if (searchInText.contains(searchText.toLowerCase().trim())) {
              filteredResults.add(item);
            }
          }
        }
      }

      // Sắp xếp kết quả theo thời gian
      filteredResults.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        _searchResults = filteredResults;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      print('Lỗi khi tìm kiếm: $e');
    }
  }

  // Làm mới danh sách thông báo
  Future<void> _refreshData() async {
    await _loadAllNotifications();
    // Nếu đang có từ khóa tìm kiếm, thực hiện lại tìm kiếm
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  // Đánh dấu ThongBao đã xem
  Future<void> _markThongBaoAsRead(ThongBao thongBao) async {
    try {
      final updatedThongBao = ThongBao(
        maTT: thongBao.maTT,
        maTKSV: thongBao.maTKSV,
        ngayTao: thongBao.ngayTao,
        trangThai: 'Đã xem',
      );

      await _apiThongBaoService.updateThongBao(updatedThongBao);
      _refreshData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: ${e.toString()}')),
      );
    }
  }

  // Đánh dấu ThongBaoYeuCau đã xem
  Future<void> _markThongBaoYeuCauAsRead(String maYeuCau) async {
    try {
      // Lấy danh sách tất cả các thông báo yêu cầu có cùng mã yêu cầu
      List<ThongBaoYeuCau> thongBaos =
          await _apiThongBaoYeuCauService.getThongBaoByYeuCau(maYeuCau);

      // Duyệt qua danh sách và cập nhật trạng thái nếu chưa là 'Đã xem'
      for (var thongBao in thongBaos) {
        if (thongBao.trangThai != 'Đã xem') {
          final updatedThongBao = ThongBaoYeuCau(
            maTBYC: thongBao.maTBYC,
            maYC: thongBao.maYC,
            maTKSV: thongBao.maTKSV,
            noiDung: thongBao.noiDung,
            ngayThongBao: thongBao.ngayThongBao,
            trangThai: 'Đã xem',
          );

          await _apiThongBaoYeuCauService.updateThongBaoYeuCau(updatedThongBao);
        }
      }

      _refreshData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đánh dấu đã xem: ${e.toString()}')),
      );
    }
  }

  // Xác định màu dựa trên trạng thái
  Color _getStatusColor(String trangThai) {
    if (trangThai.trim().toLowerCase() == 'chưa xem') {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  // Xác định icon cho ThongBao
  String _getThongBaoIcon(String trangThai) {
    if (trangThai.trim().toLowerCase() == 'chưa xem') {
      return 'assets/icons/notification_unread.png';
    } else {
      return 'assets/icons/notification_read.png';
    }
  }

  // Xác định icon cho ThongBaoYeuCau
  String _getThongBaoYeuCauIcon(String trangThai) {
    if (trangThai.trim().toLowerCase() == 'chưa xem') {
      return 'assets/icons/request_unread.png';
    } else {
      return 'assets/icons/request_read.png';
    }
  }

  // Hiển thị chi tiết ThongBao
  void _showThongBaoDetail(ThongBao thongBao) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final TinTuc tinTuc = await _apiNewsService.getTinTucById(thongBao.maTT);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailPage(
            tinTuc: tinTuc,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lỗi khi tải chi tiết thông báo'),
            content: Text('Không thể tải chi tiết thông báo: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      );
    }
  }

  // Hiển thị chi tiết ThongBaoYeuCau
  void _showThongBaoYeuCauDetail(ThongBaoYeuCau thongBaoYeuCau) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo yêu cầu #${thongBaoYeuCau.maTBYC}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mã thông báo yêu cầu: ${thongBaoYeuCau.maTBYC}'),
                const SizedBox(height: 8),
                Text('Mã yêu cầu: ${thongBaoYeuCau.maYC}'),
                const SizedBox(height: 12),
                const Text('Nội dung:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(thongBaoYeuCau.noiDung),
                const SizedBox(height: 12),
                Text(
                    'Ngày thông báo: ${_formatDate(thongBaoYeuCau.ngayThongBao)}'),
                const SizedBox(height: 8),
                Text('Mã tài khoản sinh viên: ${thongBaoYeuCau.maTKSV}'),
                const SizedBox(height: 8),
                Text('Trạng thái: ${thongBaoYeuCau.trangThai}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // Lấy preview của nội dung (50 ký tự đầu)
  String _getPreviewMessage(String noiDung) {
    if (noiDung.length <= 50) {
      return noiDung;
    }
    return '${noiDung.substring(0, 50)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tìm kiếm thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
          centerTitle: false,
        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Hiển thị trạng thái tìm kiếm
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Đang tìm kiếm...'),
                ],
              ),
            ),

          // Hiển thị số kết quả tìm được
          if (_searchController.text.trim().isNotEmpty && !_isSearching)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Text(
                'Tìm thấy ${_searchResults.length} kết quả cho "${_searchController.text}"',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_searchResults.isEmpty) {
      String emptyMessage = _searchController.text.trim().isEmpty
          ? 'Nhập từ khóa để tìm kiếm thông báo'
          : 'Không tìm thấy thông báo nào phù hợp với từ khóa "${_searchController.text}"';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.trim().isEmpty
                  ? Icons.search
                  : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _searchResults
                .map((item) => Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: _buildNotificationCard(item),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    if (item is ThongBaoItem) {
      return NotificationCardforNews(
        title: "Thông báo #${item.thongBao.maTT}",
        message: "",
        iconSrc: _getThongBaoIcon(item.thongBao.trangThai),
        color: _getStatusColor(item.thongBao.trangThai),
        time: _formatDate(item.thongBao.ngayTao),
        isUnread: item.isUnread,
        onTap: () {
          _showThongBaoDetail(item.thongBao);
          if (item.isUnread) {
            _markThongBaoAsRead(item.thongBao);
          }
        },
      );
    } else if (item is ThongBaoYeuCauItem) {
      return NotificationCardforRequest(
        title: "Thông báo yêu cầu #${item.thongBaoYeuCau.maTBYC}",
        message: _getPreviewMessage(item.thongBaoYeuCau.noiDung),
        iconSrc: _getThongBaoYeuCauIcon(item.thongBaoYeuCau.trangThai),
        color: _getStatusColor(item.thongBaoYeuCau.trangThai),
        time: _formatDate(item.thongBaoYeuCau.ngayThongBao),
        isUnread: item.isUnread,
        onDetailPressed: () {
          _showThongBaoYeuCauDetail(item.thongBaoYeuCau);
          if (item.isUnread) {
            _markThongBaoYeuCauAsRead(item.thongBaoYeuCau.maYC);
          }
        },
        onTap: () {
          if (item.isUnread) {
            _markThongBaoYeuCauAsRead(item.thongBaoYeuCau.maYC);
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RequestDetailScreen(
                        requestId: item.thongBaoYeuCau.maYC,
                        maTKSV: widget.maTKSV,
                        token: widget.token,
                      )));
        },
      );
    }

    return Container(); // Fallback widget
  }

  // Format lại ngày giờ để hiển thị
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }
}
