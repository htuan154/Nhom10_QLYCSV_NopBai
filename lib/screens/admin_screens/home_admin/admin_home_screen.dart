import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/student_account/student_account_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/news/news_list_screen.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/loaitaikhoan/loaitaikhoanlistscreen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/nhan_vien/nhanvien_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/taikhoan/tai_khoan_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/lop/lop_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/sinh_vien/sinhvien_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/thongbao/thongbao_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/loaiyeucau/loaiyeucaulistscreen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/request/request_list_screen.dart';

class HomePage_admin extends StatelessWidget {
  final String token;
  final TaiKhoan taiKhoan;

  const HomePage_admin(
      {super.key, required this.token, required this.taiKhoan});

  // Role constants
  static const String ROLE_REQUEST_HANDLER = '22057501920250524221750';
  static const String ROLE_STUDENT_MANAGER = '23656424520250524221809';
  static const String ROLE_NEWS_PUBLISHER = '24438024320250524221736';
  static const String ROLE_STAFF = '41234296720250524220316';
  static const String ROLE_ADMINISTRATOR = '42512166320250524221722';
  static const String ROLE_TEMP = '81270409820250605090055';

  @override
  Widget build(BuildContext context) {
    // Check if user is TEMP - they can't access anything
    if (taiKhoan.maLoai == ROLE_TEMP) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            backgroundColor: Colors.blue[700],
            title: const Text(
              'Hệ thống quản lý sinh viên',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Container(
          color: Colors.grey[50],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 20),
                Text(
                  "Không có quyền truy cập",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tài khoản tạm thời không được phép truy cập hệ thống",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text(
            'Hệ thống quản lý sinh viên',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                "Bảng điều khiển",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 20),

              // Management Grid - Only show available modules
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: _buildAvailableModules(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAvailableModules(BuildContext context) {
    List<Widget> modules = [];

    // ADMINISTRATOR - Access to all modules
    if (_isAdministrator()) {
      modules.addAll([
        _buildManagementCard(
          context,
          title: "Tài khoản\nSinh viên",
          icon: Icons.school,
          color: const Color(0xFF4CAF50),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentAccountListScreen(token: token),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Tin tức",
          icon: Icons.article,
          color: const Color(0xFF2196F3),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsListScreen(
                token: token,
                taiKhoan: taiKhoan,
              ),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Loại\nTài khoản",
          icon: Icons.account_tree,
          color: const Color(0xFF9C27B0),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoaiTaiKhoanListScreen(),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Nhân viên",
          icon: Icons.people,
          color: const Color(0xFFFF9800),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NhanVienListScreen(),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Tài khoản",
          icon: Icons.account_circle,
          color: const Color(0xFF607D8B),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaiKhoanListScreen(),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Lớp học",
          icon: Icons.class_,
          color: const Color(0xFF795548),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LopListScreen(token: token),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Sinh viên",
          icon: Icons.person,
          color: const Color(0xFF3F51B5),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SinhVienListScreen(token: token),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Thông báo",
          icon: Icons.notifications,
          color: const Color(0xFFE91E63),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThongBaoListScreen(token: token),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Loại\nYêu cầu",
          icon: Icons.category,
          color: const Color(0xFF009688),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoaiYeuCauListScreen(),
            ),
          ),
        ),
        _buildManagementCard(
          context,
          title: "Yêu cầu",
          icon: Icons.assignment,
          color: const Color(0xFFFF5722),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminRequestsListScreen(
                taikhoan: taiKhoan,
                token: token,
              ),
            ),
          ),
        ),
      ]);
    } else {
      // STUDENT MANAGER - TKSV, lớp học, sinh viên
      if (_isStudentManager()) {
        modules.addAll([
          _buildManagementCard(
            context,
            title: "Tài khoản\nSinh viên",
            icon: Icons.school,
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentAccountListScreen(token: token),
              ),
            ),
          ),
          _buildManagementCard(
            context,
            title: "Lớp học",
            icon: Icons.class_,
            color: const Color(0xFF795548),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LopListScreen(token: token),
              ),
            ),
          ),
          _buildManagementCard(
            context,
            title: "Sinh viên",
            icon: Icons.person,
            color: const Color(0xFF3F51B5),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SinhVienListScreen(token: token),
              ),
            ),
          ),
        ]);
      }

      // REQUEST HANDLER - Yêu cầu, Loại yêu cầu
      if (_isRequestHandler()) {
        modules.addAll([
          _buildManagementCard(
            context,
            title: "Loại\nYêu cầu",
            icon: Icons.category,
            color: const Color(0xFF009688),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoaiYeuCauListScreen(),
              ),
            ),
          ),
          _buildManagementCard(
            context,
            title: "Yêu cầu",
            icon: Icons.assignment,
            color: const Color(0xFFFF5722),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminRequestsListScreen(
                  taikhoan: taiKhoan,
                  token: token,
                ),
              ),
            ),
          ),
        ]);
      }

      // NEWS PUBLISHER - Tin tức, thông báo
      if (_isNewsPublisher()) {
        modules.addAll([
          _buildManagementCard(
            context,
            title: "Tin tức",
            icon: Icons.article,
            color: const Color(0xFF2196F3),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsListScreen(
                  token: token,
                  taiKhoan: taiKhoan,
                ),
              ),
            ),
          ),
          _buildManagementCard(
            context,
            title: "Thông báo",
            icon: Icons.notifications,
            color: const Color(0xFFE91E63),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThongBaoListScreen(token: token),
              ),
            ),
          ),
        ]);
      }

      // STAFF - Tài khoản
      if (_isStaff()) {
        modules.add(
          _buildManagementCard(
            context,
            title: "Tài khoản",
            icon: Icons.account_circle,
            color: const Color(0xFF607D8B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaiKhoanListScreen(),
              ),
            ),
          ),
        );
      }
    }

    return modules;
  }

  // Role checking methods
  bool _isAdministrator() => taiKhoan.maLoai == ROLE_ADMINISTRATOR;
  bool _isStudentManager() => taiKhoan.maLoai == ROLE_STUDENT_MANAGER;
  bool _isRequestHandler() => taiKhoan.maLoai == ROLE_REQUEST_HANDLER;
  bool _isNewsPublisher() => taiKhoan.maLoai == ROLE_NEWS_PUBLISHER;
  bool _isStaff() => taiKhoan.maLoai == ROLE_STAFF;

  // Permission checking methods
  bool _hasAccessToStats() {
    return _isAdministrator() || _isStudentManager() || _isRequestHandler();
  }

  bool _hasStudentAccess() {
    return _isAdministrator() || _isStudentManager();
  }

  bool _hasRequestAccess() {
    return _isAdministrator() || _isRequestHandler();
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}