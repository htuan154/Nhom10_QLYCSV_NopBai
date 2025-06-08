import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/yeucau.dart';
import 'package:doan_qlsv_nhom10/class/loai_yeu_cau.dart';
import 'package:doan_qlsv_nhom10/services/api_yeucau.dart';
import 'package:doan_qlsv_nhom10/services/api_loai_yeu_cau.dart';

class CreateRequestScreen extends StatefulWidget {
  final String maTKSV;

  const CreateRequestScreen({
    Key? key,
    required this.maTKSV,
  }) : super(key: key);

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maYCController = TextEditingController();
  final _noiDungController = TextEditingController();

  String? _selectedLoaiYCId;
  List<LoaiYeuCau> _loaiYeuCauList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoaiYeuCau();
  }

  @override
  void dispose() {
    _maYCController.dispose();
    _noiDungController.dispose();
    super.dispose();
  }

  // Load request types
  Future<void> _loadLoaiYeuCau() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiLoaiYeuCauService = ApiLoaiYeuCauService();
      _loaiYeuCauList = await apiLoaiYeuCauService.getAllLoaiYeuCau();

      if (_loaiYeuCauList.isNotEmpty) {
        setState(() {
          _selectedLoaiYCId = _loaiYeuCauList.first.maLoaiYC;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi khi tải loại yêu cầu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Submit the request
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLoaiYCId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn loại yêu cầu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final timestamp = DateTime.now();
    final formattedTime =
        '${timestamp.year}${_twoDigits(timestamp.month)}${_twoDigits(timestamp.day)}'
        '${_twoDigits(timestamp.hour)}${_twoDigits(timestamp.minute)}${_twoDigits(timestamp.second)}';
    final fixedYC = '${widget.maTKSV.hashCode}$formattedTime';

    try {
      final newRequest = Request(
        maYC: fixedYC,
        maLoaiYC: _selectedLoaiYCId,
        maTKSV: widget.maTKSV,
        noiDung: _noiDungController.text.trim(),
        ngayTao: DateTime.now(),
        trangThai: 'Chờ xử lý',
      );

      final success = await ApiYeuCauService.addYeuCau(newRequest);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yêu cầu đã được tạo thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tạo yêu cầu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Tạo yêu cầu mới'),
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
                        onPressed: _loadLoaiYeuCau,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mã yêu cầu:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // TextFormField(
                        //   controller: _maYCController,
                        //   decoration: const InputDecoration(
                        //     hintText: 'Nhập mã yêu cầu...',
                        //     border: OutlineInputBorder(),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.trim().isEmpty) {
                        //       return 'Vui lòng nhập mã yêu cầu';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chọn loại yêu cầu:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          value: _selectedLoaiYCId,
                          items: _loaiYeuCauList
                              .map((loaiYC) => DropdownMenuItem<String>(
                                    value: loaiYC.maLoaiYC,
                                    child: Text(loaiYC.tenLoaiYC),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedLoaiYCId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn loại yêu cầu';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Nội dung yêu cầu:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _noiDungController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập nội dung yêu cầu của bạn...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập nội dung yêu cầu';
                            }
                            if (value.trim().length < 10) {
                              return 'Nội dung yêu cầu quá ngắn';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mã sinh viên:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: widget.maTKSV,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Color(0xFFEEEEEE),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ngày tạo:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: DateFormat('dd/MM/yyyy HH:mm')
                              .format(DateTime.now()),
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Color(0xFFEEEEEE),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Trạng thái:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: 'Chờ xử lý',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Color(0xFFEEEEEE),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: _isSubmitting ? null : _submitRequest,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Gửi yêu cầu',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
