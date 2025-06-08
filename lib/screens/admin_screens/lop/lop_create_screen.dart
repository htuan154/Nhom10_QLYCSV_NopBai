import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';
import 'package:doan_qlsv_nhom10/services/api_lop.dart';

class LopCreateScreen extends StatefulWidget {
  const LopCreateScreen({Key? key}) : super(key: key);

  @override
  _LopCreateScreenState createState() => _LopCreateScreenState();
}

class _LopCreateScreenState extends State<LopCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lopApiClient = LopApiClient();
  bool _isLoading = false;

  final TextEditingController _maLopController = TextEditingController();
  final TextEditingController _tenLopController = TextEditingController();

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final lop = Lop(
        maLop: _tenLopController.text.trim(),
        tenLop: _tenLopController.text.trim(),
      );

      await _lopApiClient.createLop(lop);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm lớp mới thành công')),
      );

      Navigator.pop(context, true);
    } catch (error) {
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
        title: const Text('Thêm lớp mới'),
        backgroundColor: Colors.blue[700],
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
                    TextFormField(
                      controller: _maLopController,
                      decoration: const InputDecoration(
                        labelText: 'Mã lớp',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tenLopController,
                      decoration: const InputDecoration(
                        labelText: 'Tên lớp',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên lớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _saveForm,
                      child: const Text(
                        'Thêm mới',
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
