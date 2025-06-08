import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:doan_qlsv_nhom10/screens/entryPoint/entry_point.dart';
import 'package:doan_qlsv_nhom10/services/api_login.dart';
import 'package:doan_qlsv_nhom10/screens/admin_screens/entryPoint_admin/entry_point_admin.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';

//Form Đăng nhập(chứa các trường để nhập email, password)
class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  // Thay đổi từ late sang nullable để tránh lỗi nếu chưa khởi tạo
  SMITrigger? error;
  SMITrigger? success;
  SMITrigger? reset;
  SMITrigger? confetti;

  // Thêm biến để theo dõi trạng thái khởi tạo
  bool _isConfettiInitialized = false;
  bool _isCheckInitialized = false;

  // Thêm controller để lưu trữ
  RiveAnimationController? _checkController;
  RiveAnimationController? _confettiController;

  // Add TextEditingController to capture the values
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Không cần tải trước animation nữa
  }

  void _onCheckRiveInit(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (controller != null) {
      artboard.addController(controller);
      error = controller.findInput<bool>('Error') as SMITrigger;
      success = controller.findInput<bool>('Check') as SMITrigger;
      reset = controller.findInput<bool>('Reset') as SMITrigger;
      _isCheckInitialized = true;
    }
  }

  void _onConfettiRiveInit(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");

    if (controller != null) {
      artboard.addController(controller);
      confetti = controller.findInput<bool>("Trigger explosion") as SMITrigger;
      _isConfettiInitialized = true;
    }
  }

  void signIn(BuildContext context) {
  setState(() {
    isShowConfetti = false;
    isShowLoading = true;
  });

  Future.delayed(
    const Duration(seconds: 1),
    () async {
      if (_formKey.currentState!.validate()) {
        final String username = _usernameController.text;
        final String password = _passwordController.text;

        ApiService apiService = ApiService();
        var response = await apiService.login(username, password);
        print("Response: $response");

        if (response['success'] == true) {
          final String token = response['token'] ?? '';

          if (success != null) {
            success!.fire();
          }

          Future.delayed(
            const Duration(seconds: 2),
            () {
              setState(() {
                isShowLoading = false;
                isShowConfetti = true;
              });

              Future.delayed(const Duration(milliseconds: 300), () {
                if (_isConfettiInitialized && confetti != null) {
                  try {
                    confetti!.fire();
                  } catch (e) {
                    print("Lỗi khi fire confetti: $e");
                  }
                }
              });

              Future.delayed(const Duration(seconds: 1), () {
                if (!context.mounted) return;

                try {
                  String userRole = response['role'] ?? '';
                  print("User role: $userRole");

                  if (response['userInfo'] != null) {
                    final userInfo = response['userInfo'];

                    if (userRole == 'Student') {
                      final TaiKhoanSinhVien taiKhoanSV = userInfo as TaiKhoanSinhVien;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryPoint(
                            token: token,
                            taiKhoan: taiKhoanSV,
                          ),
                        ),
                      );
                    } else {
                      final TaiKhoan taiKhoanNV = userInfo as TaiKhoan;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryPoint_admin(
                            token: token,
                            taiKhoan: taiKhoanNV,
                          ),
                        ),
                      );
                    }
                  } else {
                    print("userInfo is null => Đăng nhập thất bại");

                    if (error != null) {
                      error!.fire();
                    }

                    Future.delayed(
                      const Duration(seconds: 2),
                      () {
                        setState(() {
                          isShowLoading = false;
                        });

                        if (reset != null) {
                          reset!.fire();
                        }
                      },
                    );
                  }
                } catch (e) {
                  print("Lỗi khi chuyển màn hình: $e");
                }
              });
            },
          );
        } else {
          if (error != null) {
            error!.fire();
          }

          Future.delayed(
            const Duration(seconds: 2),
            () {
              setState(() {
                isShowLoading = false;
              });

              if (reset != null) {
                reset!.fire();
              }
            },
          );
        }
      } else {
        if (error != null) {
          error!.fire();
        }

        Future.delayed(
          const Duration(seconds: 2),
          () {
            setState(() {
              isShowLoading = false;
            });

            if (reset != null) {
              reset!.fire();
            }
          },
        );
      }
    },
  );
}

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Username",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset("assets/icons/User.svg"),
                    ),
                  ),
                ),
              ),
              const Text(
                "Password",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset("assets/icons/password.svg"),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    signIn(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF77D8E),
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                  icon: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Color(0xFFFE0037),
                  ),
                  label: const Text("Đăng Nhập"),
                ),
              ),
            ],
          ),
        ),
        // Luôn render RiveAnimation nhưng ẩn/hiện chúng
        Visibility(
          visible: isShowLoading,
          child: CustomPositioned(
            child: RiveAnimation.asset(
              'assets/RiveAssets/check.riv',
              fit: BoxFit.cover,
              onInit: _onCheckRiveInit,
            ),
          ),
        ),
        // Luôn render confetti animation nhưng ẩn/hiện nó
        Visibility(
          visible: isShowConfetti,
          child: CustomPositioned(
            scale: 6,
            child: RiveAnimation.asset(
              "assets/RiveAssets/confetti.riv",
              onInit: _onConfettiRiveInit,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, this.scale = 1, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 100,
            width: 100,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
