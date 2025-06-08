import 'package:doan_qlsv_nhom10/class/xu_ly_yeu_cau.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/class/doanchat.dart';
import 'package:doan_qlsv_nhom10/class/thongbaochatyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_doanchat.dart';
import 'package:doan_qlsv_nhom10/services/api_xulyyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbaochatyeucau.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  final String maTKSV;
  final String token;

  const RequestDetailScreen(
      {Key? key,
      required this.requestId,
      required this.maTKSV,
      required this.token})
      : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late Future<Request> _requestFuture;
  late Future<List<XuLyYeuCau>> _xulyyeucau;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<DoanChat> _doanChats = [];
  final ApiDoanChatService _chatService = ApiDoanChatService();
  late ApiXuLyYeuCauService _xuLyYeuCauService;
  final ApiThongBaoChatYeuCauService _thongBaoChatYeuCauService =
      ApiThongBaoChatYeuCauService();

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
    _loadDoanChats();
    _loadXuLyYeuCau();
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
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print("Lỗi khi load đoạn chat: $e");
    }
  }

  Future<void> _loadRequestDetail() async {
    setState(() {
      _requestFuture = ApiYeuCauService.getYeuCauById(widget.requestId);
    });
  }

  Future<void> _loadXuLyYeuCau() async {
    setState(() {
      _xuLyYeuCauService = new ApiXuLyYeuCauService(widget.token);
      _xulyyeucau = _xuLyYeuCauService.getXuLyYeuCauByMaYC(widget.requestId);
    });
  }

  // Kiểm tra xem có được phép chat không
  bool _canChat(String trangThai) {
    return trangThai.toLowerCase() == 'đang xử lý';
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

  Widget _buildChatSection(Request request) {
    final canChat = _canChat(request.trangThai);
    
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
                  Icons.chat_bubble_outline, 
                  color: canChat ? Colors.blue.shade600 : Colors.grey.shade400
                ),
                const SizedBox(width: 8),
                Text(
                  canChat 
                    ? 'Trao đổi với người hỗ trợ'
                    : 'Trao đổi không khả dụng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: canChat ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Thông báo trạng thái nếu không được chat
          if (!canChat)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chỉ có thể chat khi yêu cầu đang được xử lý',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
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
                          color: Colors.grey.shade400
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có tin nhắn nào',
                          style: TextStyle(
                            fontSize: 16, 
                            color: Colors.grey.shade600
                          )
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canChat 
                            ? 'Bắt đầu cuộc trò chuyện bằng cách gửi tin nhắn bên dưới'
                            : 'Không thể gửi tin nhắn với trạng thái hiện tại',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey.shade500
                          )
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _doanChats.length,
                    itemBuilder: (context, index) {
                      final chat = _doanChats[index];
                      final isSentByUser = chat.maNguoiGui == widget.maTKSV;
                      return _buildMessageBubble(chat, isSentByUser);
                    },
                  ),
          ),

          // Nhập tin nhắn - chỉ hiển thị nếu được phép chat
          if (canChat)
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
                        hintText: 'Nhập tin nhắn...',
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
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(DoanChat chat, bool isSentByUser) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isSentByUser ? 12 : 0),
            bottomRight: Radius.circular(isSentByUser ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Kiểm tra trạng thái yêu cầu trước khi gửi
    final request = await _requestFuture;
    if (!_canChat(request.trangThai)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể gửi tin nhắn. Yêu cầu phải ở trạng thái "Đang xử lý"'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<DoanChat> doanChats = await _doanChats;
      final List<XuLyYeuCau> xuLyYeuCaus = await _xulyyeucau;

      final Set<String> maNguoiGuisFromChat = doanChats
          .map((msg) => msg.maNguoiGui)
          .whereType<String>() // Bỏ null
          .toSet();

      final Set<String> maNguoiXuLys =
          xuLyYeuCaus.map((x) => x.maTK).whereType<String>().toSet();

      final Set<String> danhSachNhanVienCanGui = {
        ...maNguoiGuisFromChat,
        ...maNguoiXuLys,
      }..remove(widget.maTKSV); // Loại bỏ sinh viên gửi tin

      final now = DateTime.now();
      final String formattedTime =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}'
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';

      // Tạo đoạn chat
      final newChat = DoanChat(
        maDC: 'DC$formattedTime${widget.requestId}',
        maYC: widget.requestId,
        ngayTao: now,
        maNguoiGui: widget.maTKSV,
        noiDung: message,
      );

      await _chatService.createDoanChat(newChat);

      // Gửi thông báo đến tất cả người xử lý
      for (String maTK in danhSachNhanVienCanGui) {
        final thongBao = ThongBaoChatYeuCau(
          maTBCYC: 'TBCYC$formattedTime${widget.requestId}$maTK',
          maYC: widget.requestId,
          maTK: maTK,
          noiDung: 'Bạn có tin nhắn mới từ yêu cầu: ${widget.requestId}',
          ngayThongBao: now.toIso8601String(),
          trangThai: 'Chưa xem',
        );

        try {
          await _thongBaoChatYeuCauService.createThongBaoChatYeuCau(thongBao);
        } catch (e) {
          print('Lỗi khi gửi thông báo cho $maTK: $e');
        }
      }

      _messageController.clear();
      await _loadDoanChats();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('Lỗi khi gửi tin nhắn: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi gửi tin nhắn'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Chi tiết yêu cầu'),
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadRequestDetail();
              await _loadDoanChats();
              await _loadXuLyYeuCau();
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
                    onPressed: _loadRequestDetail,
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
              _buildChatSection(request),
            ],
          );
        },
      ),
    );
  }
}