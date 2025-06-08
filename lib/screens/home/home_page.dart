import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/screens/home/detail_tintuc.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String maTKSV;

  const HomePage({
    Key? key,
    required this.token,
    required this.maTKSV,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ApiNewsService _apiNewsService;
  late ApiThongBaoService _apiThongBaoService;
  
  List<TinTuc> _allTinTucs = [];
  List<ThongBao> _allThongBaos = [];
  List<TinTuc> _unreadTinTucs = [];
  List<TinTuc> _recentTinTucs = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _apiNewsService = ApiNewsService(widget.token);
    _apiThongBaoService = ApiThongBaoService(widget.token);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tải danh sách tin tức và thông báo song song
      final results = await Future.wait([
        _apiNewsService.getTinTucs(),
        _apiThongBaoService.getThongBaosByTaiKhoan(widget.maTKSV),
      ]);

      _allTinTucs = results[0] as List<TinTuc>;
      _allThongBaos = results[1] as List<ThongBao>;

      _categorizeNews();
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _categorizeNews() {
    // Lấy danh sách mã tin tức chưa xem từ thông báo
    Set<String> unreadNewsIds = _allThongBaos
        .where((thongBao) => thongBao.trangThai.toLowerCase() == 'chưa xem')
        .map((thongBao) => thongBao.maTT)
        .toSet();

    // Lấy danh sách mã tin tức đã xem từ thông báo
    Set<String> readNewsIds = _allThongBaos
        .where((thongBao) => thongBao.trangThai.toLowerCase() == 'đã xem')
        .map((thongBao) => thongBao.maTT)
        .toSet();

    // Phân loại tin tức
    // Chưa đọc: Chỉ hiển thị tin tức có thông báo "Chưa xem"
    _unreadTinTucs = _allTinTucs
        .where((tinTuc) => unreadNewsIds.contains(tinTuc.maTT))
        .toList();

    // Gần đây: Chỉ hiển thị tin tức có thông báo "Đã xem"
    _recentTinTucs = _allTinTucs
        .where((tinTuc) => readNewsIds.contains(tinTuc.maTT))
        .toList();
    
    // Sắp xếp theo ngày tạo mới nhất
    _unreadTinTucs.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
    _recentTinTucs.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
  }

  Future<void> _markAsRead(TinTuc tinTuc) async {
    try {
      // Điều hướng đến trang chi tiết trước
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailPage(tinTuc: tinTuc),
        ),
      );

      // Sau khi quay lại từ trang chi tiết, đánh dấu đã đọc
      final existingThongBao = _allThongBaos.firstWhere(
        (tb) => tb.maTT == tinTuc.maTT && tb.maTKSV == widget.maTKSV,
        orElse: () => ThongBao(
          maTT: tinTuc.maTT,
          maTKSV: widget.maTKSV,
          ngayTao: DateTime.now(),
          trangThai: 'Đã xem',
        ),
      );

      if (_allThongBaos.any((tb) => tb.maTT == tinTuc.maTT && tb.maTKSV == widget.maTKSV)) {
        // Cập nhật thông báo hiện có
        final updatedThongBao = ThongBao(
          maTT: existingThongBao.maTT,
          maTKSV: existingThongBao.maTKSV,
          ngayTao: existingThongBao.ngayTao,
          trangThai: 'Đã xem',
        );
        await _apiThongBaoService.updateThongBao(updatedThongBao);
      } else {
        // Tạo thông báo mới
        await _apiThongBaoService.createThongBao(existingThongBao);
      }

      // Cập nhật danh sách local
      await _loadData();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đánh dấu đã đọc: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCardColor(bool isUnread, int index) {
    // Màu sắc cho tin chưa đọc (màu nổi bật hơn)
    if (isUnread) {
      final colors = [
        const Color(0xFF7553F6), // Tím
        const Color(0xFF00A8E8), // Xanh dương
        const Color(0xFF00B04F), // Xanh lá
        const Color(0xFFFF6B35), // Cam
        const Color(0xFFE91E63), // Hồng
      ];
      return colors[index % colors.length];
    } else {
      // Màu sắc cho tin đã đọc (màu nhạt hơn)
      final colors = [
        const Color(0xFFB8A9E8), // Tím nhạt
        const Color(0xFF87CEEB), // Xanh dương nhạt
        const Color(0xFF98D8C8), // Xanh lá nhạt
        const Color(0xFFFFB89A), // Cam nhạt
        const Color(0xFFF48FB1), // Hồng nhạt
      ];
      return colors[index % colors.length];
    }
  }

  Widget _buildNewsCard(TinTuc tinTuc, int index, {bool showUnreadIndicator = false}) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final cardColor = _getCardColor(showUnreadIndicator, index);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _markAsRead(tinTuc),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          height: 180,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với mã tin tức và ngày
                    Row(
                      children: [
                        if (showUnreadIndicator)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            'Mã: ${tinTuc.maTT}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          dateFormat.format(tinTuc.ngayTao),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Nội dung tin tức
                    Expanded(
                      child: Text(
                        tinTuc.noiDung,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: showUnreadIndicator ? FontWeight.w600 : FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Footer với thông tin tác giả và action
                    Row(
                      children: [
                        if (tinTuc.taiKhoan != null) ...[
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${tinTuc.taiKhoan!.toString()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Icon bên phải
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        showUnreadIndicator ? Icons.mark_email_unread : Icons.article,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showUnreadIndicator ? 'Mới' : 'Đã xem',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList(List<TinTuc> tinTucs, {bool showUnreadIndicator = false}) {
    if (tinTucs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                showUnreadIndicator ? Icons.mark_email_read : Icons.article_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              showUnreadIndicator ? 'Không có tin tức chưa đọc' : 'Không có tin tức nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showUnreadIndicator 
                  ? 'Tất cả tin tức đã được đọc' 
                  : 'Hãy quay lại sau để xem tin tức mới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.blue[700],
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tinTucs.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(
            tinTucs[index],
            index,
            showUnreadIndicator: showUnreadIndicator,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tin Tức Sinh Viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
              onPressed: _loadData,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mark_email_unread, size: 18),
                  const SizedBox(width: 8),
                  Text('Chưa đọc (${_unreadTinTucs.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  Text('Gần đây (${_recentTinTucs.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Đang tải tin tức...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Có lỗi xảy ra',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNewsList(_unreadTinTucs, showUnreadIndicator: true),
                    _buildNewsList(_recentTinTucs),
                  ],
                ),
    );
  }
}