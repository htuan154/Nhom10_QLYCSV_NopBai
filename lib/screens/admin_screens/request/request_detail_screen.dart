import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/class/thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/class/doanchat.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_doanchat.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbaoyeucau.dart';

class AdminRequestDetailScreen extends StatefulWidget {
  final String requestId;
  final String maTK;

  const AdminRequestDetailScreen(
      {Key? key, required this.requestId, required this.maTK})
      : super(key: key);

  @override
  State<AdminRequestDetailScreen> createState() =>
      _AdminRequestDetailScreenState();
}

class _AdminRequestDetailScreenState extends State<AdminRequestDetailScreen> {
  late Future<Request> _requestFuture;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<DoanChat> _doanChats = [];
  final ApiDoanChatService _chatService = ApiDoanChatService();
  String? _studentMaTK; // Mã tài khoản sinh viên để so sánh
  Request? _currentRequest; // Lưu thông tin request hiện tại

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
    _loadDoanChats();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDoanChats() async {
    try {
      final chats = await _chatService.getDoanChatsByYeuCau(widget.requestId);
      chats.sort(
          (a, b) => a.ngayTao.compareTo(b.ngayTao)); // Sắp xếp từ cũ -> mới
      setState(() {
        _doanChats = chats;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("Lỗi khi load đoạn chat: $e");
    }
  }

  Future<void> _loadRequestDetail() async {
    setState(() {
      _requestFuture = ApiYeuCauService.getYeuCauById(widget.requestId);
    });

    // Load request để lấy mã tài khoản sinh viên
    try {
      final request = await ApiYeuCauService.getYeuCauById(widget.requestId);
      setState(() {
        _studentMaTK = request.maTKSV; // Giả sử Request có field maTKSV
        _currentRequest = request; // Lưu thông tin request
      });
    } catch (e) {
      print("Lỗi khi load thông tin sinh viên: $e");
    }
  }

  // Kiểm tra xem có được phép chat hay không
  bool _isChatAllowed() {
    return _currentRequest?.trangThai.toLowerCase() == 'đang xử lý';
  }

  String _getStatusColor(String trangThai) {
    switch (trangThai.toLowerCase()) {
      case 'chờ xử lý':
        return 'orange';
      case 'đang xử lý':
        return 'blue';
      case 'đã xử lý':
        return 'green';
      case 'từ chối':
        return 'red';
      default:
        return 'blue';
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
        return Colors.blue.shade100;
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
        return Colors.blue.shade800;
    }
  }

  Widget _buildRequestInfo(Request request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với mã yêu cầu và trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Mã YC: ${request.maYC}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(request.trangThai),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  request.trangThai,
                  style: TextStyle(
                    color: _getStatusTextColor(request.trangThai),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thông tin chi tiết
          _buildInfoRow('Sinh viên:', request.maTKSV ?? "Chưa có"),
          const SizedBox(height: 12),

          _buildInfoRow('Loại yêu cầu:', request.maLoaiYC ?? "Chưa có"),
          const SizedBox(height: 12),

          _buildInfoRow('Ngày tạo:',
              DateFormat('dd/MM/yyyy HH:mm').format(request.ngayTao)),
          const SizedBox(height: 12),

          // Nội dung yêu cầu
          const Text(
            'Nội dung:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              request.noiDung,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    final bool chatAllowed = _isChatAllowed();
    
    return Expanded(
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  chatAllowed ? Icons.chat_bubble_outline : Icons.chat_bubble_outline,
                  color: chatAllowed ? Colors.blue.shade600 : Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trao đổi với sinh viên',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: chatAllowed ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                if (!chatAllowed) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chat bị khóa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tin nhắn
          Expanded(
            child: _doanChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có tin nhắn nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chatAllowed
                              ? 'Bắt đầu cuộc trò chuyện bằng cách gửi tin nhắn bên dưới'
                              : 'Chỉ có thể chat khi yêu cầu đang được xử lý',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _doanChats.length,
                    itemBuilder: (context, index) {
                      final chat = _doanChats[index];
                      // Tin nhắn của sinh viên sẽ nằm bên trái (false)
                      // Tin nhắn của admin sẽ nằm bên phải (true)
                      final isSentByStudent = chat.maNguoiGui == _studentMaTK;
                      return _buildMessageBubble(chat, !isSentByStudent);
                    },
                  ),
          ),

          // Nhập tin nhắn - chỉ hiển thị khi được phép chat
          if (chatAllowed)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn phản hồi...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            )
          else
            // Hiển thị thông báo khi chat bị khóa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Chỉ chat khi yêu cầu đang xử lý.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(DoanChat chat, bool isSentByAdmin) {
    return Align(
      alignment: isSentByAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSentByAdmin ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isSentByAdmin ? 12 : 0),
            bottomRight: Radius.circular(isSentByAdmin ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSentByAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              chat.noiDung,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm dd/MM').format(chat.ngayTao),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    // Kiểm tra lại quyền chat trước khi gửi
    if (!_isChatAllowed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chỉ chat khi yêu cầu đang xử lý."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final String formattedTime =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}'
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';

      final newChat = DoanChat(
        maDC: 'DC$formattedTime${widget.requestId}',
        maYC: widget.requestId,
        ngayTao: now,
        maNguoiGui: widget.maTK, // Sử dụng mã tài khoản admin
        noiDung: message,
      );

      await _chatService.createDoanChat(newChat);

      final DateTime nowforTBYC = DateTime.now();
      final String formattedTimeforTBYC = nowforTBYC
          .toIso8601String()
          .replaceAll(RegExp(r'[-:T.]'), '')
          .substring(0, 14);
      final String maTBYC = 'TBYC$formattedTimeforTBYC${widget.requestId}';

      final newThongBaoYeuCau = ThongBaoYeuCau(
        maTBYC: maTBYC,
        maYC: widget.requestId,
        maTKSV: _studentMaTK!,
        noiDung: 'Bạn có tin nhắn mới từ đoạn chat: ${widget.requestId}',
        ngayThongBao: DateTime.now(),
        trangThai: 'Chưa xem',
      );

      final apiThongBao = ApiThongBaoYeuCauService();
      await apiThongBao.createThongBaoYeuCau(newThongBaoYeuCau);

      _messageController.clear();
      await _loadDoanChats();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Lỗi khi gửi tin nhắn: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi gửi tin nhắn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Chi tiết yêu cầu - Admin'),
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadRequestDetail();
              _loadDoanChats();
            },
          ),
        ],
      ),
      body: FutureBuilder<Request>(
        future: _requestFuture,
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
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi khi tải thông tin yêu cầu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _loadRequestDetail();
                      _loadDoanChats();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Không tìm thấy thông tin yêu cầu',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final request = snapshot.data!;
          return Column(
            children: [
              _buildRequestInfo(request),
              _buildChatSection(),
            ],
          );
        },
      ),
    );
  }
}