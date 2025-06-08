import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';

class AddEditNewsScreen extends StatefulWidget {
  final TinTuc? tinTuc;
  final String token;
  final TaiKhoan taiKhoan;

  const AddEditNewsScreen(
      {super.key,
      required this.token,
      required this.tinTuc,
      required this.taiKhoan});

  @override
  _AddEditNewsScreenState createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late ApiNewsService _apiService;

  late TextEditingController _noiDungController;
  late String _maTK;
  late String? _maTT;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiNewsService(widget.token);
    _noiDungController =
        TextEditingController(text: widget.tinTuc?.noiDung ?? '');
    _maTK = widget.tinTuc?.maTK ?? widget.taiKhoan.maTK;
    _maTT = widget.tinTuc?.maTT;
  }

  @override
  void dispose() {
    _noiDungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
            widget.tinTuc == null ? 'Thêm Tin Tức Mới' : 'Chỉnh Sửa Tin Tức'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _noiDungController,
                decoration: InputDecoration(
                  labelText: 'Nội dung tin tức',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung tin tức';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: const Color.fromARGB(255, 34, 0, 255))
                    : Text(widget.tinTuc == null
                        ? 'Thêm Tin Tức'
                        : 'Cập Nhật Tin Tức'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.tinTuc == null) {
          // Add new news
          final newTinTuc = TinTuc(
            maTT: DateTime.now()
                .millisecondsSinceEpoch
                .toString(), // Generate a unique ID
            maTK: _maTK,
            noiDung: _noiDungController.text,
            ngayTao: DateTime.now(),
            //taiKhoan: widget.taiKhoan
          );

          print("\n\n\n");
          print("New tin tuc: $newTinTuc");
          await _apiService.createTinTuc(newTinTuc);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm tin tức thành công')),
          );
        } else {
          // Update existing news
          final updatedTinTuc = TinTuc(
            maTT: _maTT!,
            maTK: _maTK,
            noiDung: _noiDungController.text,
            ngayTao: widget.tinTuc!.ngayTao,
          );

          print("\n\n\n\n\n");
          print("tin tuc: $updatedTinTuc");

          await _apiService.updateTinTuc(updatedTinTuc);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã cập nhật tin tức thành công')),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
