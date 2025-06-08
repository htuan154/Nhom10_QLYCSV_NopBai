import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:doan_qlsv_nhom10/constants.dart';
import 'package:doan_qlsv_nhom10/screens/home/home_page.dart';
import 'package:doan_qlsv_nhom10/utils/rive_utils.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';
import 'package:doan_qlsv_nhom10/screens/profile/profile_screen.dart';
import 'package:doan_qlsv_nhom10/screens/request/request_list_screen.dart';
import 'package:doan_qlsv_nhom10/screens/notification/nofitication_screen.dart';
import 'package:doan_qlsv_nhom10/screens/search/search_screen.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/services/api_sinhvien.dart';

import '../../model/menu.dart';
import 'components/btm_nav_item.dart';
import 'components/menu_btn.dart';
import 'components/side_bar.dart';

class EntryPoint extends StatefulWidget {
  final String token;
  final TaiKhoanSinhVien taiKhoan;

  const EntryPoint({super.key, required this.token, required this.taiKhoan});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;
  Menu selectedBottonNav = bottomNavItems.first;

  late SMIBool isMenuOpenInput;

  SinhVien? sinhVien;
  bool isLoading = true;

  late Widget _currentScreen;

  // Hàm chung để cập nhật màn hình và đồng bộ navigation
  void _updateScreen(String screenTitle) {
    if (sinhVien != null) {
      // Tìm menu tương ứng trong bottomNavItems
      final correspondingBottomNav = bottomNavItems.firstWhere(
        (menu) => menu.title == screenTitle,
        orElse: () => bottomNavItems.first,
      );

      setState(() {
        selectedBottonNav = correspondingBottomNav;
        
        switch (screenTitle) {
          case "Cá nhân":
            _currentScreen = ProfileScreen(
              student: sinhVien!,
              token: widget.token,
            );
            break;
          case "Hỗ Trợ":
            _currentScreen = StudentRequestsListScreen(
              maTKSV: widget.taiKhoan.maTKSV,
              token: widget.token,
            );
            break;
          case "Thông báo":
            _currentScreen = CombinedNotificationScreen(
              maTKSV: widget.taiKhoan.maTKSV,
              token: widget.token,
            );
            break;
          case "Tìm Kiếm":
            _currentScreen = SearchNotificationScreen(
              token: widget.token,
              maTKSV: widget.taiKhoan.maTKSV,
            );
            break;
          case "Trang chủ":
          default:
            _currentScreen = HomePage(
              token: widget.token,
              maTKSV: widget.taiKhoan.maTKSV,
            );
        }
      });

      // Cập nhật trạng thái Rive cho bottom navigation
      RiveUtils.chnageSMIBoolState(correspondingBottomNav.rive.status!);
    }
  }

  void updateSelectedBtmNav(Menu menu) {
    if (selectedBottonNav != menu) {
      _updateScreen(menu.title);
    }
  }

  // Callback từ sidebar
  void onSidebarMenuSelected(Widget screen, String menuTitle) {
    setState(() {
      _currentScreen = screen;
    });
    _updateScreen(menuTitle);
    
    // Đóng sidebar sau khi chọn
    if (isSideBarOpen) {
      isMenuOpenInput.value = false;
      _animationController.reverse();
      setState(() {
        isSideBarOpen = false;
      });
    }
  }

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => setState(() {}));

    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    _currentScreen = HomePage(
      token: widget.token,
      maTKSV: widget.taiKhoan.maTKSV,
    );

    _loadSinhVien();
  }

  Future<void> _loadSinhVien() async {
    try {
      final api = ApiServiceSinhVien(widget.token);
      final sv = await api.getSinhVienById(widget.taiKhoan.maSV);
      setState(() {
        sinhVien = sv;
        _currentScreen = HomePage(
          token: widget.token,
          maTKSV: widget.taiKhoan.maTKSV,
        );
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin sinh viên: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
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
                    sinhVien1: sinhVien!,
                    token: widget.token,
                    taiKhoan: widget.taiKhoan,
                    onMenuSelected: onSidebarMenuSelected, // Truyền callback mới
                  ),
                ),

                // Main content
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding + 80),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(1 * animation.value -
                          30 * animation.value * pi / 180),
                    child: Transform.translate(
                      offset: Offset(animation.value * 265, 0),
                      child: Transform.scale(
                        scale: scalAnimation.value,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          child: _currentScreen,
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
                  padding: const EdgeInsets.all(12),
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
                    children: List.generate(bottomNavItems.length, (index) {
                      final navBar = bottomNavItems[index];
                      return BtmNavItem(
                        navBar: navBar,
                        press: () {
                          RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                          updateSelectedBtmNav(navBar);
                        },
                        riveOnInit: (artboard) {
                          navBar.rive.status = RiveUtils.getRiveInput(
                            artboard,
                            stateMachineName: navBar.rive.stateMachineName,
                          );
                        },
                        selectedNav: selectedBottonNav,
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
  }
}