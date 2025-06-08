import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_sinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/screens/onboding/onboding_screen.dart';

class ProfileScreen extends StatefulWidget {
  final SinhVien student;
  final String token;

  ProfileScreen({required this.student, required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController birthplaceController;
  late String selectedGender;
  bool isLoading = false;

  // Controllers for password change form
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // Keep a copy of the current SinhVien object
  late SinhVien currentStudent;

  // Store the student's account information
  TaiKhoanSinhVien? userAccount;

  // Khởi tạo API service với token
  late ApiServiceTaiKhoanSinhVien apiService;

  @override
  void initState() {
    super.initState();
    // Khởi tạo API service với token
    apiService = ApiServiceTaiKhoanSinhVien(widget.token);

    // Create a copy of the student data
    currentStudent = SinhVien(
        maSV: widget.student.maSV,
        tenSV: widget.student.tenSV,
        gioiTinh: widget.student.gioiTinh,
        ngaySinh: widget.student.ngaySinh,
        email: widget.student.email,
        maLop: widget.student.maLop,
        diaChi: widget.student.diaChi,
        lopHoc: widget.student.lopHoc,
        khoaHoc: widget.student.khoaHoc,
        bacDaoTao: widget.student.bacDaoTao,
        loaiHinhDaoTao: widget.student.loaiHinhDaoTao,
        nganh: widget.student.nganh);

    // Initialize controllers for info update
    nameController = TextEditingController(text: currentStudent.tenSV);
    dobController =
        TextEditingController(text: currentStudent.ngaySinh.toString());
    birthplaceController = TextEditingController(text: currentStudent.diaChi);
    selectedGender = currentStudent.gioiTinh;

    // Initialize controllers for password change
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Fetch the user's account information
    _fetchUserAccount();
  }

  // Helper method to get the first letter of name and return corresponding asset path
  String _getAvatarAssetPath() {
    String name = currentStudent.tenSV ?? '';
    if (name.isEmpty) return 'assets/images/letter-a.png'; // Default fallback

    // Get the first character and convert to lowercase
    String firstLetter = name.trim().split(' ').last[0].toLowerCase();

    // Map to corresponding asset file
    return 'assets/images/letter-$firstLetter.png';
  }

  // Fetch the user's account information
  Future<void> _fetchUserAccount() async {
    if (currentStudent.maSV.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });

        // Sử dụng đối tượng apiService đã khởi tạo để gọi phương thức
        List<TaiKhoanSinhVien> accounts =
            await apiService.getTaiKhoanSinhViens();

        // Find the account matching the current student's ID
        userAccount = accounts.firstWhere(
          (account) => account.maSV == currentStudent.maSV,
          orElse: () =>
              throw Exception('Không tìm thấy tài khoản cho sinh viên này'),
        );

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi tải thông tin tài khoản: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose info update controllers
    nameController.dispose();
    dobController.dispose();
    birthplaceController.dispose();

    // Dispose password change controllers
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // Convert date string from DD/MM/YYYY format to DateTime
  DateTime? _parseDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  Future<void> _updateStudentInfo() async {
    if (currentStudent.maSV.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể cập nhật: Mã sinh viên không hợp lệ"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create an updated SinhVien object
    DateTime? parsedDate = _parseDate(dobController.text);

    SinhVien updatedStudent = SinhVien(
        maSV: currentStudent.maSV,
        tenSV: nameController.text,
        gioiTinh: selectedGender,
        ngaySinh: parsedDate ??
            currentStudent.ngaySinh, // Use current if parsing fails
        email: currentStudent.email,
        maLop: currentStudent.maLop,
        diaChi: birthplaceController.text,
        lopHoc: currentStudent.lopHoc,
        khoaHoc: currentStudent.khoaHoc,
        bacDaoTao: currentStudent.bacDaoTao,
        loaiHinhDaoTao: currentStudent.loaiHinhDaoTao,
        nganh: currentStudent.nganh);

    setState(() {
      isLoading = true;
    });

    try {
      // Call API to update student information
      bool success = await ApiServiceSinhVien(widget.token).updateSinhVien(
        currentStudent.maSV,
        updatedStudent,
      );

      setState(() {
        isLoading = false;
      });

      if (success) {
        // Update the current student data on success
        setState(() {
          currentStudent = updatedStudent;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cập nhật thông tin thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cập nhật thông tin thất bại. Vui lòng thử lại sau."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpdateForm() {
    // Reset controllers to current values when opening the form
    nameController.text = currentStudent.tenSV;
    dobController.text = currentStudent.ngaySinh.toString();
    birthplaceController.text = currentStudent.diaChi;
    selectedGender = currentStudent.gioiTinh;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Cập nhật thông tin sinh viên'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Họ tên
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ tên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Giới tính
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Giới tính',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Nam', 'Nữ'].map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          selectedGender = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Ngày sinh
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(
                      labelText: 'Ngày sinh (DD/MM/YYYY)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                        setDialogState(() {
                          dobController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Địa chỉ
                  TextField(
                    controller: birthplaceController,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Call API to update student info
                  _updateStudentInfo();
                },
                child: Text('Lưu'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _changePassword() async {
    if (userAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể đổi mật khẩu: Tài khoản không tồn tại"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Verify the old password before changing to new password
      if (oldPasswordController.text != userAccount!.matKhau) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Mật khẩu cũ không chính xác"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create an updated account with the new password
      TaiKhoanSinhVien updatedAccount = TaiKhoanSinhVien(
        maTKSV: userAccount!.maTKSV,
        tenDangNhap: userAccount!.tenDangNhap,
        matKhau: newPasswordController.text,
        maSV: userAccount!.maSV,
        // Copy other properties as needed
      );

      // Call API to update the account information with new password
      bool success = await apiService.updateTaiKhoanSinhVien(
        userAccount!.maTKSV,
        updatedAccount,
      );

      setState(() {
        isLoading = false;
      });

      if (success) {
        // Update the current account data on success
        setState(() {
          userAccount = updatedAccount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đổi mật khẩu thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đổi mật khẩu thất bại. Vui lòng thử lại sau."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPasswordChangeForm() {
    // Reset password controllers when opening the form
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    // Variables to track password validation errors
    bool passwordMismatch = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Đổi mật khẩu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mật khẩu cũ
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu cũ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Mật khẩu mới
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      helperText: 'Mật khẩu phải có ít nhất 6 ký tự',
                    ),
                    onChanged: (_) {
                      if (confirmPasswordController.text.isNotEmpty) {
                        setDialogState(() {
                          passwordMismatch = newPasswordController.text !=
                              confirmPasswordController.text;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Xác nhận mật khẩu mới
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      errorText:
                          passwordMismatch ? 'Mật khẩu không khớp' : null,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        passwordMismatch = newPasswordController.text !=
                            confirmPasswordController.text;
                      });
                    },
                  ),

                  // Error message if any
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate input fields
                  if (oldPasswordController.text.isEmpty ||
                      newPasswordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Vui lòng điền đầy đủ thông tin';
                    });
                    return;
                  }

                  if (newPasswordController.text.length < 6) {
                    setDialogState(() {
                      errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự';
                    });
                    return;
                  }

                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    setDialogState(() {
                      errorMessage =
                          'Mật khẩu mới và xác nhận mật khẩu không khớp';
                    });
                    return;
                  }

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Call the API to change password
                  _changePassword();
                },
                child: Text('Đổi mật khẩu'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Thông tin sinh viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.blue[700],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Ảnh đại diện ở giữa - Updated to use asset images like NhanVien
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: AssetImage(_getAvatarAssetPath()),
                            backgroundColor: Colors.grey[300],
                            onBackgroundImageError: (exception, stackTrace) {
                              // Fallback if the specific letter image doesn't exist
                              print('Error loading avatar image: $exception');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue[300]!,
                                  width: 3.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _showUpdateForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Cập nhật thông tin'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Khung thông tin sinh viên có thể cuộn được
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow('MSSV', currentStudent.maSV, 'Lớp học',
                              currentStudent.lopHoc),
                          _buildInfoRow('Họ tên', currentStudent.tenSV,
                              'Khóa học', currentStudent.khoaHoc.toString()),
                          _buildInfoRow('Giới tính', currentStudent.gioiTinh,
                              'Bậc đào tạo', currentStudent.bacDaoTao),
                          _buildInfoRow(
                              'Ngày sinh',
                              currentStudent.ngaySinh.toString(),
                              'Loại hình đào tạo',
                              currentStudent.loaiHinhDaoTao),
                          _buildInfoRow('Địa chỉ', currentStudent.diaChi,
                              'Ngành', currentStudent.nganh),
                          if (userAccount != null)
                            _buildInfoRow('Tên đăng nhập',
                                userAccount!.tenDangNhap, '', ''),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Các nút đổi mật khẩu và đăng xuất
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showPasswordChangeForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Đổi mật khẩu'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OnbodingScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Đăng xuất'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to create info rows
  Widget _buildInfoRow(
      String label1, String value1, String label2, String value2) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label1: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: value1,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          if (label2.isNotEmpty)
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '$label2: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextSpan(
                      text: value2,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}