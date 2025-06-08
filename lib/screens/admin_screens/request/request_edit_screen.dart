import 'package:doan_qlsv_nhom10/class/doanchat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/loai_yeu_cau.dart';
import 'package:doan_qlsv_nhom10/class/xu_ly_yeu_cau.dart';
import 'package:doan_qlsv_nhom10/class/thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/class/doanchat.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_yeu_cau.dart';
import 'package:doan_qlsv_nhom10/services/api_xulyyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbaoyeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_doanchat.dart';

class EditRequestScreen extends StatefulWidget {
  final Request request;
  final TaiKhoan taikhoan;
  final String token;

  const EditRequestScreen(
      {Key? key,
      required this.request,
      required this.taikhoan,
      required this.token})
      : super(key: key);

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noiDungController = TextEditingController();

  List<LoaiYeuCau> _loaiYeuCauList = [];
  String? _selectedLoaiYCId;
  String? _selectedTrangThai;
  String? _originalTrangThai; // To keep track of the original status

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _trangThaiOptions = [
    'Chờ xử lý',
    'Đang xử lý',
    'Đã xử lý',
    'Từ chối'
  ];

  @override
  void initState() {
    super.initState();
    _selectedTrangThai = widget.request.trangThai;
    _originalTrangThai = widget.request.trangThai; // Store the original status
    _noiDungController.text = widget.request.noiDung;
    _loadLoaiYeuCau();
  }

  @override
  void dispose() {
    _noiDungController.dispose();
    super.dispose();
  }

  Future<void> _loadLoaiYeuCau() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiLoaiYeuCauService();
      _loaiYeuCauList = await api.getAllLoaiYeuCau();

      setState(() {
        _selectedLoaiYCId = widget.request.maLoaiYC;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải loại yêu cầu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _saveStatus() async {
    if (_selectedTrangThai == null || _selectedLoaiYCId == null) return;

    if ((_selectedTrangThai?.trim() ?? '') ==
        (_originalTrangThai?.trim() ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có thay đổi về trạng thái'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedRequest = Request(
        maYC: widget.request.maYC,
        maLoaiYC: _selectedLoaiYCId!,
        maTKSV: widget.request.maTKSV,
        noiDung: _noiDungController.text.trim(),
        ngayTao: widget.request.ngayTao,
        trangThai: _selectedTrangThai!,
      );

      final success = await ApiYeuCauService.updateYeuCau(
          widget.request.maYC, updatedRequest);

      if (success) {
        // Ghi lịch sử xử lý
        final xuLyYeuCau = XuLyYeuCau(
          maYC: widget.request.maYC,
          maTK: widget.taikhoan.maTK,
          ngayXuLy: DateTime.now(),
          trangThaiCu: _originalTrangThai!,
          trangThaiMoi: _selectedTrangThai!,
        );

        final apiXuLy = ApiXuLyYeuCauService(widget.token ?? '');
        await apiXuLy.createXuLyYeuCau(xuLyYeuCau);

        final nowfordoanchat = DateTime.now();
        final String formattedTimefordoanchat =
            '${nowfordoanchat.year}${_twoDigits(nowfordoanchat.month)}${_twoDigits(nowfordoanchat.day)}'
            '${_twoDigits(nowfordoanchat.hour)}${_twoDigits(nowfordoanchat.minute)}${_twoDigits(nowfordoanchat.second)}';

        final doanchat = DoanChat(
          maDC: formattedTimefordoanchat,
          maYC: widget.request.maYC,
          ngayTao: DateTime.now(),
          maNguoiGui: widget.taikhoan.maTK,
          noiDung:
              'Yêu cầu: ${widget.request.maYC} đã chuyển trạng thái từ ${_originalTrangThai!} sang ${_selectedTrangThai!} ',
        );

        final apiDoanChat = ApiDoanChatService();
        await apiDoanChat.createDoanChat(doanchat);

        // Tạo thông báo yêu cầu
        final DateTime now = DateTime.now();
        final String formattedTime = now
            .toIso8601String()
            .replaceAll(RegExp(r'[-:T.]'), '')
            .substring(0, 14);
        final String maTBYC = 'TBYC$formattedTime${widget.request.maYC}';

        final thongBao = ThongBaoYeuCau(
          maTBYC: maTBYC,
          maYC: widget.request.maYC,
          maTKSV: widget.request.maTKSV,
          noiDung: 'Chuyển Đổi Trạng Thái ${widget.request.maYC}',
          ngayThongBao: now,
          trangThai: 'Chưa xem',
        );

        final apiThongBao = ApiThongBaoYeuCauService();
        await apiThongBao.createThongBaoYeuCau(thongBao);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trạng thái đã được lưu và thông báo đã được tạo'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể lưu trạng thái'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu trạng thái: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text('Chỉnh sửa yêu cầu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _buildLabel('Mã yêu cầu:'),
                        _buildReadonlyField(widget.request.maYC),
                        const SizedBox(height: 16),
                        _buildLabel('Loại yêu cầu:'),
                        DropdownButtonFormField<String>(
                          value: _selectedLoaiYCId,
                          items: _loaiYeuCauList
                              .map((e) => DropdownMenuItem(
                                    value: e.maLoaiYC,
                                    child: Text(e.tenLoaiYC),
                                  ))
                              .toList(),
                          onChanged: null,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Nội dung:'),
                        TextFormField(
                          controller: _noiDungController,
                          maxLines: 5,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Mã sinh viên:'),
                        _buildReadonlyField(widget.request.maTKSV),
                        const SizedBox(height: 16),
                        _buildLabel('Ngày tạo:'),
                        _buildReadonlyField(DateFormat('dd/MM/yyyy HH:mm')
                            .format(widget.request.ngayTao)),
                        const SizedBox(height: 16),
                        _buildLabel('Trạng thái hiện tại:'),
                        _buildReadonlyField(_originalTrangThai ?? ''),
                        const SizedBox(height: 16),
                        _buildLabel('Trạng thái mới:'),
                        DropdownButtonFormField<String>(
                          value: _selectedTrangThai,
                          items: _trangThaiOptions
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTrangThai = value;
                            });
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Người xử lý:'),
                        _buildReadonlyField('(${widget.taikhoan.maTK})'),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _saveStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Lưu trạng thái'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildReadonlyField(String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Color(0xFFEEEEEE),
      ),
    );
  }
}
