import 'package:flutter/material.dart';
import 'dart:async';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';

class ThongBaoAddScreen extends StatefulWidget {
  final String token;

  const ThongBaoAddScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _ThongBaoAddScreenState createState() => _ThongBaoAddScreenState();
}

class _ThongBaoAddScreenState extends State<ThongBaoAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maTTController = TextEditingController();
  final _maTKSVController = TextEditingController();

  String? _selectedMaTT;
  String? _selectedMaTKSV;

  bool _isSubmitting = false;
  late ApiThongBaoService _apiThongBao;
  late ApiServiceTaiKhoanSinhVien _apiTKSV;
  late ApiNewsService _apiNews;

  List<TaiKhoanSinhVien> _taiKhoanSinhViens = [];
  List<TinTuc> _tinTucs = [];

  @override
  void initState() {
    super.initState();
    _apiThongBao = ApiThongBaoService(widget.token);
    _apiTKSV = ApiServiceTaiKhoanSinhVien(widget.token);
    _apiNews = ApiNewsService(widget.token);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final tksvs = await _apiTKSV.getTaiKhoanSinhViens();
      final tintucs = await _apiNews.getTinTucs();

      setState(() {
        _taiKhoanSinhViens = tksvs;
        _tinTucs = tintucs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  @override
  void dispose() {
    _maTTController.dispose();
    _maTKSVController.dispose();
    super.dispose();
  }

  Future<bool> _checkThongBaoExists(String maTT, String maTKSV) async {
    final allThongBaos = await _apiThongBao.getThongBaos();
    return allThongBaos.any((tb) => tb.maTT == maTT && tb.maTKSV == maTKSV);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final maTT = _selectedMaTT!;
        final maTKSV = _selectedMaTKSV!;

        final exists = await _checkThongBaoExists(maTT, maTKSV);

        if (exists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thông báo đã tồn tại, không thể thêm trùng lặp'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final thongBao = ThongBao(
          maTT: maTT,
          maTKSV: maTKSV,
          ngayTao: DateTime.now(),
          trangThai: 'Chưa xem',
        );

        await _apiThongBao.createThongBao(thongBao);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm thông báo thành công'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm thông báo: $e'),
            backgroundColor: Colors.red,
          ),
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

  Future<void> _taoTatCaThongBao() async {
    if (_tinTucs.isEmpty || _taiKhoanSinhViens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Danh sách tin tức hoặc tài khoản trống'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      int successCount = 0;

      // 🔽 Tải tất cả thông báo một lần
      final allThongBaos = await _apiThongBao.getThongBaos();

      // 🔽 Duyệt từng cặp tin tức + tài khoản sinh viên
      for (var tinTuc in _tinTucs) {
        for (var tk in _taiKhoanSinhViens) {
          final exists = allThongBaos
              .any((tb) => tb.maTT == tinTuc.maTT && tb.maTKSV == tk.maTKSV);

          if (!exists) {
            final thongBao = ThongBao(
              maTT: tinTuc.maTT,
              maTKSV: tk.maTKSV,
              ngayTao: DateTime.now(),
              trangThai: 'Chưa xem',
            );
            await _apiThongBao.createThongBao(thongBao);
            successCount++;
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo $successCount thông báo mới'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tạo thông báo hàng loạt: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Thêm thông báo mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMaTT,
                decoration: const InputDecoration(
                  labelText: 'Mã tin tức',
                  border: OutlineInputBorder(),
                ),
                items: _tinTucs.map((tinTuc) {
                  return DropdownMenuItem<String>(
                    value: tinTuc.maTT,
                    child: Text(tinTuc.maTT),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMaTT = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn mã tin tức';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMaTKSV,
                decoration: const InputDecoration(
                  labelText: 'Mã tài khoản sinh viên',
                  border: OutlineInputBorder(),
                ),
                items: _taiKhoanSinhViens.map((tk) {
                  return DropdownMenuItem<String>(
                    value: tk.maTKSV,
                    child: Text(tk.maTKSV),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMaTKSV = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn mã tài khoản sinh viên';
                  }
                  return null;
                },
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
                    : const Text('Thêm thông báo'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _taoTatCaThongBao,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Tạo tất cả thông báo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
