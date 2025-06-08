import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';
import 'package:doan_qlsv_nhom10/services/api_lop.dart';

class LopEditScreen extends StatefulWidget {
  final Lop lopToEdit;
  
  const LopEditScreen({Key? key, required this.lopToEdit}) : super(key: key);
  
  @override
  _LopEditScreenState createState() => _LopEditScreenState();
}

class _LopEditScreenState extends State<LopEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lopApiClient = LopApiClient();
  bool _isLoading = false;
  
  late TextEditingController _maLopController;
  late TextEditingController _tenLopController;
  
  @override
  void initState() {
    super.initState();
    _maLopController = TextEditingController(text: widget.lopToEdit.maLop ?? '');
    _tenLopController = TextEditingController(text: widget.lopToEdit.tenLop ?? '');
  }
  
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Giữ nguyên tất cả thuộc tính của lớp gốc, chỉ cập nhật những gì thay đổi
      final updatedLop = Lop(
        maLop: widget.lopToEdit.maLop, // Giữ nguyên mã lớp gốc
        tenLop: _tenLopController.text.trim(),
        // Thêm các thuộc tính khác nếu class Lop có
        // Ví dụ: nếu có thuộc tính khác, hãy copy từ widget.lopToEdit
      );
      
      // Sử dụng mã lớp gốc thay vì từ controller
      final success = await _lopApiClient.updateLop(
        widget.lopToEdit.maLop!, 
        updatedLop
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật lớp thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Cập nhật không thành công');
      }
    } catch (error) {
      print('Lỗi cập nhật lớp: $error'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _maLopController.dispose();
    _tenLopController.dispose();
    _lopApiClient.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa lớp'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hiển thị mã lớp nhưng không cho phép chỉnh sửa
                    TextFormField(
                      controller: _maLopController,
                      decoration: InputDecoration(
                        labelText: 'Mã lớp',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      readOnly: true,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tenLopController,
                      decoration: const InputDecoration(
                        labelText: 'Tên lớp',
                        border: OutlineInputBorder(),
                        hintText: 'Nhập tên lớp...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên lớp';
                        }
                        if (value.trim().length < 2) {
                          return 'Tên lớp phải có ít nhất 2 ký tự';
                        }
                        return null;
                      },
                      maxLength: 100,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveForm,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Cập nhật',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}