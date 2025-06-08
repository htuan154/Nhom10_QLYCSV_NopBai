import 'package:flutter/material.dart';
import 'dart:async';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/class/thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'components/notification_card_for_news.dart';
import 'components/notification_card_for_request.dart';
import 'package:doan_qlsv_nhom10/screens/request/request_detail_screen.dart';
import 'package:doan_qlsv_nhom10/screens/home/detail_tintuc.dart';

// Enum cho các tùy chọn lọc
enum FilterType {
  all, // Tất cả
  newest, // Mới nhất
  oldest, // Cũ nhất
  unread, // Chưa đọc
  read, // Đã đọc
  thongbao, // Chỉ ThongBao
  thongbaoyeucau // Chỉ ThongBaoYeuCau
}

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

class CombinedNotificationScreen extends StatefulWidget {
  final String token;
  final String maTKSV;

  const CombinedNotificationScreen(
      {Key? key, required this.token, required this.maTKSV})
      : super(key: key);

  @override
  _CombinedNotificationScreenState createState() =>
      _CombinedNotificationScreenState();
}

class _CombinedNotificationScreenState
    extends State<CombinedNotificationScreen> {
  late ApiThongBaoService _apiThongBaoService;
  late ApiThongBaoYeuCauService _apiThongBaoYeuCauService;
  late ApiNewsService _apiNewsService;

  List<ThongBao> _thongBaos = [];
  List<ThongBaoYeuCau> _thongBaoYeuCaus = [];
  List<NotificationItem> _combinedNotifications = [];
  List<NotificationItem> _filteredNotifications = [];

  bool _isLoading = true;
  String? _error;
  FilterType _currentFilter = FilterType.newest;

  @override
  void initState() {
    super.initState();
    _apiThongBaoService = ApiThongBaoService(widget.token);
    _apiThongBaoYeuCauService = ApiThongBaoYeuCauService();
    _apiNewsService = ApiNewsService(widget.token);
    _loadAllNotifications();
  }

  // Tải tất cả thông báo
  Future<void> _loadAllNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Tải song song cả 2 loại thông báo
      final results = await Future.wait([
        _apiThongBaoService.getThongBaosByTaiKhoan(widget.maTKSV),
        _apiThongBaoYeuCauService.getThongBaoByTaiKhoanSinhVien(widget.maTKSV),
      ]);

      final thongBaos = results[0] as List<ThongBao>;
      final thongBaoYeuCaus = results[1] as List<ThongBaoYeuCau>;

      // Gộp và sắp xếp theo thời gian
      _combineAndSortNotifications(thongBaos, thongBaoYeuCaus);

      setState(() {
        _thongBaos = thongBaos;
        _thongBaoYeuCaus = thongBaoYeuCaus;
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

    _combinedNotifications = combined;
    _applyFilter(_currentFilter);
  }

  // Áp dụng bộ lọc
  void _applyFilter(FilterType filterType) {
    List<NotificationItem> filtered = List.from(_combinedNotifications);

    switch (filterType) {
      case FilterType.all:
        // Không cần lọc, giữ nguyên và sắp xếp mới nhất
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case FilterType.newest:
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case FilterType.oldest:
        filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case FilterType.unread:
        filtered = filtered.where((item) => item.isUnread).toList();
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case FilterType.read:
        filtered = filtered.where((item) => !item.isUnread).toList();
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case FilterType.thongbao:
        filtered = filtered.where((item) => item is ThongBaoItem).toList();
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case FilterType.thongbaoyeucau:
        filtered =
            filtered.where((item) => item is ThongBaoYeuCauItem).toList();
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
    }

    setState(() {
      _filteredNotifications = filtered;
      _currentFilter = filterType;
    });
  }

  // Hiển thị menu lọc
  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc thông báo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
                children: [
                  _buildFilterOption(
                    title: 'Tất cả',
                    icon: Icons.list,
                    filterType: FilterType.all,
                  ),
                  _buildFilterOption(
                    title: 'Mới nhất',
                    icon: Icons.arrow_upward,
                    filterType: FilterType.newest,
                  ),
                  _buildFilterOption(
                    title: 'Cũ nhất',
                    icon: Icons.arrow_downward,
                    filterType: FilterType.oldest,
                  ),
                  _buildFilterOption(
                    title: 'Chưa đọc',
                    icon: Icons.mark_email_unread,
                    filterType: FilterType.unread,
                  ),
                  _buildFilterOption(
                    title: 'Đã đọc',
                    icon: Icons.mark_email_read,
                    filterType: FilterType.read,
                  ),
                  _buildFilterOption(
                    title: 'Thông báo',
                    icon: Icons.notifications,
                    filterType: FilterType.thongbao,
                  ),
                  _buildFilterOption(
                    title: 'Thông báo yêu cầu',
                    icon: Icons.assignment,
                    filterType: FilterType.thongbaoyeucau,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget cho mỗi tùy chọn lọc
  Widget _buildFilterOption({
    required String title,
    required IconData icon,
    required FilterType filterType,
  }) {
    bool isSelected = _currentFilter == filterType;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        Navigator.pop(context);
        _applyFilter(filterType);
      },
    );
  }

  // Lấy tên bộ lọc hiện tại để hiển thị
  String _getFilterName(FilterType filterType) {
    switch (filterType) {
      case FilterType.all:
        return 'Tất cả';
      case FilterType.newest:
        return 'Mới nhất';
      case FilterType.oldest:
        return 'Cũ nhất';
      case FilterType.unread:
        return 'Chưa đọc';
      case FilterType.read:
        return 'Đã đọc';
      case FilterType.thongbao:
        return 'Thông báo';
      case FilterType.thongbaoyeucau:
        return 'Thông báo yêu cầu';
    }
  }

  // Làm mới danh sách thông báo
  Future<void> _refreshData() async {
    await _loadAllNotifications();
    return;
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
              'Tất cả thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterMenu,
              tooltip: 'Lọc thông báo',
            ),
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
          // Hiển thị bộ lọc hiện tại
          if (_currentFilter != FilterType.newest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.filter_list,
                      color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Đang lọc: ${_getFilterName(_currentFilter)}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _applyFilter(FilterType.newest),
                    child: const Text('Xóa lọc'),
                  ),
                ],
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

    if (_filteredNotifications.isEmpty) {
      String emptyMessage = 'Không có thông báo nào';
      if (_currentFilter != FilterType.newest &&
          _currentFilter != FilterType.all) {
        emptyMessage =
            'Không có thông báo nào phù hợp với bộ lọc "${_getFilterName(_currentFilter)}"';
      }
      return Center(child: Text(emptyMessage));
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _filteredNotifications
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
