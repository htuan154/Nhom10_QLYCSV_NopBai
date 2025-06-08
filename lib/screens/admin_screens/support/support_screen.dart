import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_doanchat.dart';
import 'package:doan_qlsv_nhom10/services/api_xulyyeucau.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/request/request_detail_screen.dart';

class SupportListScreen extends StatefulWidget {
  final String maTK;
  final String token;

  const SupportListScreen({
    Key? key,
    required this.maTK,
    required this.token,
  }) : super(key: key);

  @override
  State<SupportListScreen> createState() => _SupportListScreenState();
}

class _SupportListScreenState extends State<SupportListScreen> {
  // Các service cần thiết
  late ApiDoanChatService doanChatService;
  late ApiXuLyYeuCauService xuLyYeuCauService;

  late Future<List<Request>> _chatRequestsFuture;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _uniqueMaYCs = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo services
    doanChatService = ApiDoanChatService();
    xuLyYeuCauService = ApiXuLyYeuCauService(widget.token);
    _loadChatRequests();
  }

  Future<void> _loadChatRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy danh sách mã yêu cầu unique
      _uniqueMaYCs = await getUniqueMaYCByTaiKhoan(
        maTK: widget.maTK,
        doanChatService: doanChatService,
        xuLyYeuCauService: xuLyYeuCauService,
      );

      // Lấy thông tin chi tiết các yêu cầu
      _chatRequestsFuture = _getRequestsByMaYCs(_uniqueMaYCs);
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi khi tải danh sách chat: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Request>> _getRequestsByMaYCs(List<String> maYCs) async {
    List<Request> requests = [];

    for (String maYC in maYCs) {
      try {
        Request request = await ApiYeuCauService.getYeuCauById(maYC);
        requests.add(request);
      } catch (e) {
        print('Không thể lấy yêu cầu với mã $maYC: $e');
        // Tiếp tục với các mã khác
      }
    }

    // Sắp xếp theo ngày tạo mới nhất
    requests.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
    return requests;
  }

  // Hàm lấy danh sách mã yêu cầu unique từ các yêu cầu mà tài khoản này xử lý
  Future<List<String>> getUniqueMaYCByTaiKhoan({
    required String maTK,
    required ApiDoanChatService doanChatService,
    required ApiXuLyYeuCauService xuLyYeuCauService,
  }) async {
    try {
      // Lấy danh sách đoạn chat theo mã tài khoản
      final doanChats = await doanChatService.getDoanChatsByTaiKhoan(maTK);
      // Lấy danh sách xử lý yêu cầu theo mã tài khoản
      final xuLyYeuCaus = await xuLyYeuCauService.getXuLyYeuCauByMaTK(maTK);
      // Lấy tất cả mã yêu cầu từ đoạn chat
      final maYCFromChats = doanChats.map((chat) => chat.maYC).toList();
      // Lấy tất cả mã yêu cầu từ xử lý yêu cầu
      final maYCFromXuLys = xuLyYeuCaus.map((xly) => xly.maYC).toList();
      // Gộp hai danh sách và lọc trùng
      final allMaYCs = [...maYCFromChats, ...maYCFromXuLys];
      final uniqueMaYCs = allMaYCs.toSet().toList(); // loại bỏ trùng
      return uniqueMaYCs;
    } catch (e) {
      print('Error in getUniqueMaYCByTaiKhoan: $e');
      throw Exception('Không thể lấy danh sách mã yêu cầu: $e');
    }
  }

  String _getStatusColor(String trangThai) {
    switch (trangThai.toLowerCase()) {
      case 'chờ xử lý':
        return 'orange';
      case 'đã xử lý':
        return 'green';
      case 'từ chối':
        return 'red';
      case 'đang xử lý':
        return 'blue';
      default:
        return 'grey';
    }
  }

  Color _getStatusBackgroundColor(String trangThai) {
    switch (_getStatusColor(trangThai)) {
      case 'green':
        return Colors.green.shade100;
      case 'red':
        return Colors.red.shade100;
      case 'orange':
        return Colors.orange.shade100;
      case 'blue':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String trangThai) {
    switch (_getStatusColor(trangThai)) {
      case 'green':
        return Colors.green.shade800;
      case 'red':
        return Colors.red.shade800;
      case 'orange':
        return Colors.orange.shade800;
      case 'blue':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildChatIcon(String trangThai) {
    if (trangThai.toLowerCase() == 'đang xử lý') {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text(
            'Yêu cầu đang xử lý',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadChatRequests,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChatRequests,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : FutureBuilder<List<Request>>(
                  future: _chatRequestsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Đã xảy ra lỗi: ${snapshot.error}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadChatRequests,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                              ),
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
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Chưa có yêu cầu nào để chat',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Các yêu cầu có thể chat sẽ xuất hiện ở đây',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final requests = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _loadChatRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          final isActive =
                              request.trangThai.toLowerCase() == 'đang xử lý';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isActive
                                  ? BorderSide(
                                      color: Colors.blue[300]!, width: 2)
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    radius: 24,
                                    child: Icon(
                                      Icons.chat_bubble,
                                      color: Colors.blue[700],
                                      size: 24,
                                    ),
                                  ),
                                  if (isActive)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: _buildChatIcon(request.trangThai),
                                    ),
                                ],
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'YC: ${request.maYC}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusBackgroundColor(
                                              request.trangThai),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          request.trangThai,
                                          style: TextStyle(
                                            color: _getStatusTextColor(
                                                request.trangThai),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Loại: ${request.maLoaiYC}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    request.noiDung,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm')
                                            .format(request.ngayTao),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.chat,
                                color: isActive
                                    ? Colors.blue[700]
                                    : Colors.grey[400],
                                size: 24,
                              ),
                              onTap: () {
                                // Navigate to chat screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminRequestDetailScreen(
                                      requestId: request.maYC,
                                      maTK: widget.maTK,
                                    ),
                                  ),
                                ).then((_) => _loadChatRequests());

                                // Placeholder: Show snackbar
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text(
                                //         'Mở chat xử lý yêu cầu: ${request.maYC}'),
                                //     backgroundColor: Colors.blue[700],
                                //   ),
                                // );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
