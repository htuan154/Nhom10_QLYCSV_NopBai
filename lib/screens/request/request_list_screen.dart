import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';

class StudentRequestsListScreen extends StatefulWidget {
  final String maTKSV;
  final String token;

  const StudentRequestsListScreen(
      {Key? key, required this.maTKSV, required this.token})
      : super(key: key);

  @override
  State<StudentRequestsListScreen> createState() =>
      _StudentRequestsListScreenState();
}

class _StudentRequestsListScreenState extends State<StudentRequestsListScreen> {
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
      _requestsFuture = ApiYeuCauService.getYeuCausByMaTKSV(widget.maTKSV);
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

  String _getStatusColor(String trangThai) {
    switch (trangThai.toLowerCase()) {
      case 'chờ xử lý':
        return 'orange';
      case 'đã xử lý':
        return 'green';
      case 'từ chối':
        return 'red';
      default:
        return 'blue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text('Danh sách yêu cầu của bạn'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRequests,
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Bạn chưa tạo yêu cầu nào',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateRequestScreen(
                                        maTKSV: widget.maTKSV),
                                  ),
                                );

                                if (result == true) {
                                  _loadRequests(); // Tải lại danh sách yêu cầu nếu có yêu cầu mới
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, 
                                foregroundColor: Colors.white, 
                              ),
                              child: const Text('Tạo yêu cầu mới'),
                            ),
                          ],
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
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Column(
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                                      request.trangThai) ==
                                                  'green'
                                              ? Colors.green.shade100
                                              : _getStatusColor(
                                                          request.trangThai) ==
                                                      'red'
                                                  ? Colors.red.shade100
                                                  : _getStatusColor(request
                                                              .trangThai) ==
                                                          'orange'
                                                      ? Colors.orange.shade100
                                                      : Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          request.trangThai,
                                          style: TextStyle(
                                            color: _getStatusColor(
                                                        request.trangThai) ==
                                                    'green'
                                                ? Colors.green.shade800
                                                : _getStatusColor(request
                                                            .trangThai) ==
                                                        'red'
                                                    ? Colors.red.shade800
                                                    : _getStatusColor(request
                                                                .trangThai) ==
                                                            'orange'
                                                        ? Colors.orange.shade800
                                                        : Colors.blue.shade800,
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
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to detail screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RequestDetailScreen(
                                      requestId: request.maYC,
                                      maTKSV: widget.maTKSV,
                                      token: widget.token,
                                    ),
                                  ),
                                ).then((_) => _loadRequests());
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRequestScreen(
                maTKSV: widget.maTKSV,
              ),
            ),
          );

          if (result == true) {
            _loadRequests(); // Tải lại danh sách yêu cầu nếu có yêu cầu mới
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
