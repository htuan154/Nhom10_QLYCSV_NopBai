import 'package:flutter/material.dart';
import '../../../../model/menu_admin.dart';
import 'package:doan_qlsv_nhom10/utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/home_admin/admin_home_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/notification/TBCYC_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/profile/profile_admin_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/support/support_screen.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';

class SideBar extends StatefulWidget {
  final Function(Widget, String) onMenuSelected; // Callback với screen và title
  final String token;
  final TaiKhoan taiKhoan;

  const SideBar({
    super.key, 
    required this.onMenuSelected,
    required this.token,
    required this.taiKhoan,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu_admin selectedSideMenu = sidebarMenu_admins.first;
  dynamic currentEmployee;
  bool isLoadingEmployee = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeInfo();
  }

  // Hàm tải thông tin nhân viên
  Future<void> _loadEmployeeInfo() async {
    try {
      String maNhanVien = widget.taiKhoan.maNV;
      final fetchedEmployee = await ApiNhanVien.fetchNhanVienById(maNhanVien);
      
      if (mounted) {
        setState(() {
          currentEmployee = fetchedEmployee;
          isLoadingEmployee = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingEmployee = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải thông tin nhân viên: $e")),
        );
      }
    }
  }

  // Hàm xử lý sự kiện khi người dùng nhấn vào menu
  void onMenuPressed(Menu_admin menu) async {
    // Cập nhật selectedSideMenu khi chọn menu
    setState(() {
      selectedSideMenu = menu;
    });

    // Điều hướng đến các màn hình tương ứng
    if (menu.title == "Trang chủ") {
      widget.onMenuSelected(
        HomePage_admin(
          token: widget.token,
          taiKhoan: widget.taiKhoan,
        ),
        menu.title, // Truyền title
      );
    } 
    else if (menu.title == "Cá nhân") {
      String maNhanVien = widget.taiKhoan.maNV;
      
      try {
        // Fetch thông tin nhân viên
        final fetchedEmployee = await ApiNhanVien.fetchNhanVienById(maNhanVien);
        
        if (fetchedEmployee != null) {
          widget.onMenuSelected(
            ProfileNhanVienScreen(employee: fetchedEmployee),
            menu.title, // Truyền title
          );
        } else {
          // Hiển thị thông báo lỗi nếu không tìm thấy nhân viên
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Không tìm thấy nhân viên")),
            );
          }
        }
      } catch (e) {
        // Xử lý lỗi khi gọi API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi khi tải thông tin: $e")),
          );
        }
      }
    } 
    else if (menu.title == "Thông báo") {
      widget.onMenuSelected(
        ThongBaoChatYeuCauScreen(
          token: widget.token,
          maTK: widget.taiKhoan.maTK,
        ),
        menu.title, // Truyền title
      );
    } 
    else if (menu.title == "Hỗ trợ" || menu.title == "Chat") {
      widget.onMenuSelected(
        SupportListScreen(
          token: widget.token,
          maTK: widget.taiKhoan.maTK,
        ),
        "Chat", // Chuyển "Hỗ trợ" thành "Chat" để khớp với bottom nav
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị thông tin nhân viên động hoặc loading
              isLoadingEmployee
                  ? const InfoCard(
                      name: "Loading...",
                      bio: "Đang tải...",
                    )
                  : InfoCard(
                      name: currentEmployee?.tenNV ?? "Admin",
                      bio: currentEmployee?.chucVu ?? "Administrator",
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              // Duyệt qua sidebarMenus và hiển thị menu
              ...sidebarMenu_admins.map((menu) => SideMenu(
                    menu: menu,
                    selectedMenu: selectedSideMenu,
                    press: () {
                      RiveUtils.chnageSMIBoolState(menu.rive.status!);
                      onMenuPressed(menu);
                    },
                    riveOnInit: (artboard) {
                      menu.rive.status = RiveUtils.getRiveInput(artboard,
                          stateMachineName: menu.rive.stateMachineName);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}