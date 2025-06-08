import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart'; // Import class sinh viên

class ApiService {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/Auth';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Đang kết nối tới: $baseUrl/login');
      print('Dữ liệu gửi đi: username=$username, password=$password');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 120), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (120s)');
      });

      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        Map<String, dynamic> result = {
          'success': true,
          'token': responseData['token'],
        };

        if (responseData.containsKey('role')) {
          result['role'] = responseData['role'];
        }

        if (responseData.containsKey('userInfo')) {
          if (responseData['role'] == 'Student') {
            // Dùng class TaiKhoanSinhVien nếu là sinh viên
            TaiKhoanSinhVien svAccount = TaiKhoanSinhVien.fromJson(responseData['userInfo']);
            result['userInfo'] = svAccount;
          } else {
            // Ngược lại dùng class TaiKhoan (nhân viên)
            TaiKhoan tk = TaiKhoan.fromJson(responseData['userInfo']);
            result['userInfo'] = tk;
          }
        }

        return result;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Tên đăng nhập hoặc mật khẩu không đúng',
        };
      } else {
        return {
          'success': false,
          'message': 'Đã xảy ra lỗi từ server (${response.statusCode}): ${response.body}',
        };
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Kiểm tra mạng và địa chỉ API: ${e.message}',
      };
    } on FormatException catch (e) {
      return {
        'success': false,
        'message': 'Lỗi định dạng dữ liệu từ server: ${e.message}',
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Kết nối đến máy chủ quá thời gian: ${e.message}',
      };
    } catch (e, stackTrace) {
      print('Lỗi không xác định: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Lỗi không xác định: ${e.toString()}',
      };
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
