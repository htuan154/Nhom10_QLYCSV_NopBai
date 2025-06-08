import 'dart:math';
import 'package:doan_qlsv_nhom10/screens/admin_screens/notification/TBCYC_screen.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:doan_qlsv_nhom10/constants.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/home_admin/admin_home_screen.dart';
import 'package:doan_qlsv_nhom10/utils/rive_utils.dart';
import '../../../model/menu_admin.dart';
import 'components/btm_nav_item.dart';
import 'components/menu_btn.dart';
import 'components/side_bar.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/services/api_nhanvien.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/profile/profile_admin_screen.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/support/support_screen.dart';

class EntryPoint_admin extends StatefulWidget {
  final String token;
  final TaiKhoan taiKhoan;

  const EntryPoint_admin({
    Key? key,
    required this.token,
    required this.taiKhoan,
  }) : super(key: key);

  @override
  State<EntryPoint_admin> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint_admin>
    with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;
  Menu_admin selectedBottonNav = bottomNavItems.first;
  Menu_admin selectedSideMenu = sidebarMenu_admins.first;

  late SMIBool isMenuOpenInput;
  // Biến lưu trạng thái màn hình hiện tại
  late Widget _currentScreen;

  @override
  void initState() {
    super.initState();

    // Khởi tạo màn hình ban đầu với HomePage
    _currentScreen = HomePage_admin(
      token: widget.token,
      taiKhoan: widget.taiKhoan,
    );

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });

    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));

    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
  }

  // Hàm tìm bottom nav item tương ứng với screen được chọn từ sidebar
  Menu_admin? findCorrespondingBottomNavItem(String screenTitle) {
    // Tìm bottom nav item có title tương ứng
    try {
      return bottomNavItems.firstWhere((item) => item.title == screenTitle);
    } catch (e) {
      // Nếu không tìm thấy, trả về null
      return null;
    }
  }

  // Hàm được gọi khi chọn menu từ sidebar
  void onSidebarMenuSelected(Widget screen, String menuTitle) {
    setState(() {
      _currentScreen = screen;
    });

    // Tìm và cập nhật selectedBottonNav tương ứng
    Menu_admin? correspondingBottomNav = findCorrespondingBottomNavItem(menuTitle);
    if (correspondingBottomNav != null) {
      setState(() {
        selectedBottonNav = correspondingBottomNav;
      });
    }

    // Đóng sidebar sau khi chọn
    if (isSideBarOpen) {
      isMenuOpenInput.value = false;
      _animationController.reverse();
      setState(() {
        isSideBarOpen = false;
      });
    }
  }

  void updateSelectedBtmNav(Menu_admin menu) async {
    if (selectedBottonNav != menu) {
      setState(() {
        selectedBottonNav = menu;
      });

      if (menu.title == "Trang chủ") {
        setState(() {
          _currentScreen = HomePage_admin(
            token: widget.token,
            taiKhoan: widget.taiKhoan,
          );
        });
      } else if (menu.title == "Cá nhân") {
        String maNhanVien = widget.taiKhoan.maNV;

        // Tách await ra khỏi setState
        final fetchedEmployee = await ApiNhanVien.fetchNhanVienById(maNhanVien);

        if (fetchedEmployee != null) {
          // Hiển thị màn hình Cá nhân với thông tin nhân viên
          setState(() {
            _currentScreen = ProfileNhanVienScreen(employee: fetchedEmployee);
          });
        } else {
          // Xử lý nếu không tìm thấy nhân viên
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy nhân viên")),
          );
        }
      } else if (menu.title == "Thông báo") {
        setState(() {
          _currentScreen = ThongBaoChatYeuCauScreen(
            token: widget.token,
            maTK: widget.taiKhoan.maTK,
          );
        });
      } else if (menu.title == "Chat") {
        setState(() {
          _currentScreen = SupportListScreen(
            token: widget.token,
            maTK: widget.taiKhoan.maTK,
          );
        });
      }
    }
  }

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor2,
      body: Stack(
        children: [
          // Sidebar
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(
              token: widget.token,
              taiKhoan: widget.taiKhoan,
              onMenuSelected: onSidebarMenuSelected, // Sử dụng callback mới
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.only(
              bottom: bottomPadding + 80,
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(
                    1 * animation.value - 30 * (animation.value) * pi / 180),
              child: Transform.translate(
                offset: Offset(animation.value * 265, 0),
                child: Transform.scale(
                  scale: scalAnimation.value,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    child: _currentScreen, // Màn hình hiển thị hiện tại
                  ),
                ),
              ),
            ),
          ),

          // Menu Button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 16,
            child: MenuBtn(
              press: () {
                isMenuOpenInput.value = !isMenuOpenInput.value;

                if (_animationController.value == 0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                setState(() {
                  isSideBarOpen = !isSideBarOpen;
                });
              },
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine");

                artboard.addController(controller!);

                isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;
                isMenuOpenInput.value = true;
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: backgroundColor2.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor2.withOpacity(0.3),
                  offset: const Offset(0, 20),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavItems.length,
                  (index) {
                    Menu_admin navBar = bottomNavItems[index];
                    return BtmNavItem(
                      navBar: navBar,
                      press: () {
                        RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                        updateSelectedBtmNav(navBar);
                      },
                      riveOnInit: (artboard) {
                        navBar.rive.status = RiveUtils.getRiveInput(artboard,
                            stateMachineName: navBar.rive.stateMachineName);
                      },
                      selectedNav: selectedBottonNav,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}