import 'package:doan_qlsv_nhom10/services/api_thongbaochatyeucau.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:doan_qlsv_nhom10/class/thongbaochatyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbaochatyeucau.dart';
import 'notification_card_for_TBCYC.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/request/request_detail_screen.dart';

class ThongBaoChatYeuCauScreen extends StatefulWidget {
  final String token;
  final String maTK; // ID của tài khoản đang đăng nhập

  const ThongBaoChatYeuCauScreen(
      {Key? key, required this.token, required this.maTK})
      : super(key: key);

  @override
  _ThongBaoChatYeuCauScreenState createState() =>
      _ThongBaoChatYeuCauScreenState();
}

class _ThongBaoChatYeuCauScreenState extends State<ThongBaoChatYeuCauScreen> {
  late ApiThongBaoChatYeuCauService _apiService;
  List<ThongBaoChatYeuCau> _thongBaos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = ApiThongBaoChatYeuCauService();
    _loadThongBaos();
  }

  // Tải danh sách thông báo chat yêu cầu theo maTK
  Future<void> _loadThongBaos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Sử dụng API để lấy thông báo theo mã tài khoản
      final thongBaos = await _apiService.getThongBaoByMaTK(widget.maTK);

      // Sắp xếp theo ngày thông báo (mới nhất lên đầu)
      thongBaos.sort((a, b) {
        if (a.ngayThongBao == null || b.ngayThongBao == null) return 0;
        return DateTime.parse(b.ngayThongBao!)
            .compareTo(DateTime.parse(a.ngayThongBao!));
      });

      setState(() {
        _thongBaos = thongBaos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Làm mới danh sách thông báo
  Future<void> _refreshData() async {
    await _loadThongBaos();
    return;
  }

  // Đánh dấu thông báo đã xem
  Future<void> _markAsRead(ThongBaoChatYeuCau thongBao) async {
    try {
      // Lấy tất cả thông báo theo mã tài khoản
      final thongBaoList = await _apiService.getThongBaoByMaTK(thongBao.maTK!);

      // Lọc các thông báo có cùng mã yêu cầu
      final matchedThongBaos = thongBaoList
          .where((tb) => tb.maYC == thongBao.maYC && tb.trangThai != 'Đã xem')
          .toList();

      // Cập nhật trạng thái các thông báo đó thành "Đã xem"
      for (var tb in matchedThongBaos) {
        final updatedThongBao = ThongBaoChatYeuCau(
          maTBCYC: tb.maTBCYC,
          maYC: tb.maYC,
          maTK: tb.maTK,
          noiDung: tb.noiDung,
          ngayThongBao: tb.ngayThongBao,
          trangThai: 'Đã xem',
        );

        await _apiService.updateThongBaoChatYeuCau(
            tb.maTBCYC!, updatedThongBao);
      }

      _refreshData(); // Gọi lại dữ liệu nếu cần làm mới giao diện
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: ${e.toString()}')),
      );
    }
  }

  // Xác định màu dựa trên trạng thái thông báo
  Color _getStatusColor(String? trangThai) {
    if (trangThai?.trim().toLowerCase() == 'chưa xem') {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  // Xác định icon dựa trên trạng thái thông báo
  String _getStatusIcon(String? trangThai) {
    if (trangThai?.trim().toLowerCase() == 'chưa xem') {
      return 'assets/icons/notification_unread.png'; // Thay bằng đường dẫn thực tế
    } else {
      return 'assets/icons/notification_read.png'; // Thay bằng đường dẫn thực tế
    }
  }

  // Lấy tiêu đề thông báo
  String _getNotificationTitle(ThongBaoChatYeuCau thongBao) {
    return "Thông báo yêu cầu #${thongBao.maYC ?? 'N/A'}";
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
              'Thông báo chat yêu cầu',
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
      body: _buildBody(),
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

    if (_thongBaos.isEmpty) {
      return const Center(child: Text('Không có thông báo chat yêu cầu nào'));
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _thongBaos
                .map((thongBao) => Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: NotificationCardforTBCYC(
                        title: _getNotificationTitle(thongBao),
                        message: thongBao.noiDung ??
                            "", // Hiển thị nội dung ngắn gọn
                        iconSrc: _getStatusIcon(thongBao.trangThai),
                        color: _getStatusColor(thongBao.trangThai),
                        time: _formatDate(thongBao.ngayThongBao),
                        isUnread: thongBao.trangThai?.trim().toLowerCase() ==
                            'chưa xem',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminRequestDetailScreen(
                                requestId: thongBao.maYC ?? '',
                                maTK: thongBao.maTK ?? '',
                              ),
                            ),
                          );
                          // Đánh dấu là đã xem khi xem chi tiết
                          if (thongBao.trangThai?.trim().toLowerCase() ==
                              'chưa xem') {
                            _markAsRead(thongBao);
                          }
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // Format lại ngày giờ để hiển thị
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }

    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/${date.year} $hour:$minute';
    } catch (e) {
      return dateString; // Trả về chuỗi gốc nếu không parse được
    }
  }
}
