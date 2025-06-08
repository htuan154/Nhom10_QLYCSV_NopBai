import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'request_edit_screen.dart';
import 'request_detail_screen.dart';

class AdminRequestsListScreen extends StatefulWidget {
  final TaiKhoan taikhoan;
  final String token;

  const AdminRequestsListScreen(
      {Key? key, required this.taikhoan, required this.token})
      : super(key: key);

  @override
  State<AdminRequestsListScreen> createState() =>
      _AdminRequestsListScreenState();
}

class _AdminRequestsListScreenState extends State<AdminRequestsListScreen> {
  late Future<List<Request>> _requestsFuture;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _requestsFuture = ApiYeuCauService.getYeuCaus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi khi tải yêu cầu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String trangThai) {
  final normalized = trangThai.trim().toLowerCase();
  print('Debugging - Original status: "$trangThai", Normalized: "$normalized"'); // Debug line
  
  switch (normalized) {
    case 'chờ xử lý':
      return Colors.orange;
    case 'đang xử lý':
      return Colors.blue;
    case 'đã xử lý':
      return Colors.green;
    case 'từ chối':
      return Colors.red;
    default:
      print('Status not matched: "$normalized"'); // Debug line
      return Colors.grey;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Danh sách tất cả yêu cầu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRequests,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : FutureBuilder<List<Request>>(
                  future: _requestsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đã xảy ra lỗi: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRequests,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có yêu cầu nào',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final requests = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminRequestDetailScreen(
                                    requestId: request.maYC,
                                    maTK: widget.taikhoan.maTK,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Mã YC: ${request.maYC}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                    request.trangThai)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            request.trangThai,
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                  request.trangThai),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Loại: ${request.maLoaiYC}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nội dung: ${request.noiDung}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(request.ngayTao)}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Mã TKSV: ${request.maTKSV ?? 'Không có'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          label: const Text('Chỉnh sửa'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditRequestScreen(
                                                  request: request,
                                                  taikhoan: widget.taikhoan,
                                                  token: widget.token,
                                                ),
                                              ),
                                            ).then((_) => _loadRequests());
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
