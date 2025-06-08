// Màn hình chỉnh sửa thông báo
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';

class ThongBaoEditScreen extends StatefulWidget {
  final String token;
  final ThongBao thongBao;

  const ThongBaoEditScreen({
    Key? key,
    required this.token,
    required this.thongBao,
  }) : super(key: key);

  @override
  _ThongBaoEditScreenState createState() => _ThongBaoEditScreenState();
}

class _ThongBaoEditScreenState extends State<ThongBaoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _trangThai;
  bool _isSubmitting = false;
  late ApiThongBaoService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiThongBaoService(widget.token);
    // Normalize trangThai to ensure it matches exactly with dropdown options
    if (widget.thongBao.trangThai == 'Chưa xem' ||
        widget.thongBao.trangThai == 'Chưa xem') {
      _trangThai = 'Chưa xem';
    } else if (widget.thongBao.trangThai == 'Đã xem' ||
        widget.thongBao.trangThai == 'Đã xem') {
      _trangThai = 'Đã xem';
    } else {
      // Default to 'chưa xem' if the value is unexpected
      _trangThai = 'Chưa xem';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final updatedThongBao = ThongBao(
          maTT: widget.thongBao.maTT,
          maTKSV: widget.thongBao.maTKSV,
          ngayTao: widget.thongBao.ngayTao,
          trangThai: _trangThai,
        );

        await _apiService.updateThongBao(updatedThongBao);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông báo thành công')),
        );

        Navigator.pop(context, true); // Trả về true để báo hiệu refresh
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi cập nhật thông báo: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Chỉnh sửa thông báo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin thông báo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildInfoText('Mã tin tức', widget.thongBao.maTT),
                      _buildInfoText('Mã tài khoản', widget.thongBao.maTKSV),
                      _buildInfoText(
                        'Ngày tạo',
                        '${widget.thongBao.ngayTao.day}/${widget.thongBao.ngayTao.month}/${widget.thongBao.ngayTao.year} ${widget.thongBao.ngayTao.hour}:${widget.thongBao.ngayTao.minute}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cập nhật trạng thái',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        value: _trangThai,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Chưa xem',
                            child: Text('Chưa xem'),
                          ),
                          DropdownMenuItem(
                            value: 'Đã xem',
                            child: Text('Đã xem'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _trangThai = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn trạng thái';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Cập nhật thông báo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
