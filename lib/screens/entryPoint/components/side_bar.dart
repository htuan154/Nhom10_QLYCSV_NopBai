import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:flutter/material.dart';
import '../../../model/menu.dart';
import '../../../utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';
import 'package:doan_qlsv_nhom10/screens/home/home_page.dart';
import 'package:doan_qlsv_nhom10/screens/profile/profile_screen.dart';
import 'package:doan_qlsv_nhom10/screens/request/request_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/notification/nofitication_screen.dart';
import 'package:doan_qlsv_nhom10/screens/search/search_screen.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';

class SideBar extends StatefulWidget {
  // Cập nhật callback để truyền cả Widget và menuTitle
  final Function(Widget, String) onMenuSelected;
  final String token;
  final SinhVien sinhVien1;
  final TaiKhoanSinhVien taiKhoan;

  const SideBar({
    super.key,
    required this.sinhVien1,
    required this.onMenuSelected,
    required this.token,
    required this.taiKhoan,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;

  void onMenuPressed(Menu menu) {
    setState(() {
      selectedSideMenu = menu;
    });

    Widget screen;
    
    // Tạo màn hình tương ứng
    switch (menu.title) {
      case "Cá nhân":
        screen = ProfileScreen(
          student: widget.sinhVien1,
          token: widget.token,
        );
        break;
      case "Hỗ Trợ":
        screen = StudentRequestsListScreen(
          maTKSV: widget.taiKhoan.maTKSV,
          token: widget.token,
        );
        break;
      case "Thông báo":
        screen = CombinedNotificationScreen(
          maTKSV: widget.taiKhoan.maTKSV,
          token: widget.token,
        );
        break;
      case "Tìm Kiếm":
        screen = SearchNotificationScreen(
          token: widget.token,
          maTKSV: widget.taiKhoan.maTKSV,
        );
        break;
      case "Trang chủ":
      default:
        screen = HomePage(
          token: widget.token,
          maTKSV: widget.taiKhoan.maTKSV,
        );
        break;
    }

    // Gọi callback với cả screen và menuTitle
    widget.onMenuSelected(screen, menu.title);
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
              InfoCard(
                name: "Student",
                bio: widget.sinhVien1.tenSV,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sidebarMenus.map((menu) => SideMenu(
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