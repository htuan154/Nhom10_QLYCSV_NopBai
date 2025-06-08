import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';

class ApiServiceTaiKhoanSinhVien {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/TaiKhoanSinhViens'; // URL của API
  final String token; // Token xác thực

  // Constructor với token xác thực
  ApiServiceTaiKhoanSinhVien(this.token);

  // GET danh sách tài khoản sinh viên
  Future<List<TaiKhoanSinhVien>> getTaiKhoanSinhViens() async {
    try {
      print('Đang kết nối tới: $baseUrl');
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => TaiKhoanSinhVien.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập danh sách tài khoản sinh viên');
      } else {
        throw Exception('Lỗi khi tải danh sách tài khoản sinh viên: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tải danh sách tài khoản sinh viên: ${e.toString()}');
    }
  }

  // GET thông tin một tài khoản sinh viên theo id
  Future<TaiKhoanSinhVien> getTaiKhoanSinhVienById(String id) async {
    try {
      print('Đang kết nối tới: $baseUrl/$id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 200) {
        return TaiKhoanSinhVien.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy tài khoản sinh viên với mã $id');
      } else {
        throw Exception('Lỗi khi tải thông tin tài khoản sinh viên: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tải thông tin tài khoản sinh viên: ${e.toString()}');
    }
  }

  // POST tạo tài khoản sinh viên mới
  Future<TaiKhoanSinhVien> createTaiKhoanSinhVien(TaiKhoanSinhVien taiKhoanSinhVien) async {
    try {
      print('Đang kết nối tới: $baseUrl');
      print('Dữ liệu gửi đi: ${jsonEncode(taiKhoanSinhVien.toJson())}');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taiKhoanSinhVien.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 201) {
        return TaiKhoanSinhVien.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền tạo tài khoản sinh viên mới');
      } else {
        throw Exception('Lỗi khi tạo tài khoản sinh viên mới: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tạo tài khoản sinh viên mới: ${e.toString()}');
    }
  }

  // PUT cập nhật thông tin tài khoản sinh viên
  Future<bool> updateTaiKhoanSinhVien(String id, TaiKhoanSinhVien taiKhoanSinhVien) async {
    try {
      print('Đang kết nối tới: $baseUrl/$id');
      print('Dữ liệu gửi đi: ${jsonEncode(taiKhoanSinhVien.toJson())}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taiKhoanSinhVien.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 400) {
        throw Exception('Dữ liệu không hợp lệ: ID không khớp');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy tài khoản sinh viên với mã $id');
      } else {
        throw Exception('Lỗi khi cập nhật tài khoản sinh viên: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi cập nhật tài khoản sinh viên: ${e.toString()}');
    }
  }
// POST khôi phục mật khẩu tài khoản sinh viên
Future<bool> recoverPasswordTaiKhoanSinhVien(String id, String email) async {
  try {
    print('Đang kết nối tới: $baseUrl/$id/recoverPassword');
    print('Dữ liệu gửi đi: {"email": "$email"}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/$id/recoverPassword'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email}),
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Kết nối tới server quá thời gian (10s)');
    });

    print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
    print('Phản hồi từ server - Nội dung: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy tài khoản sinh viên với mã $id');
    } else {
      throw Exception('Lỗi khi khôi phục mật khẩu tài khoản sinh viên: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('Lỗi Socket: ${e.toString()}');
    throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
  } on FormatException catch (e) {
    print('Lỗi định dạng: ${e.toString()}');
    throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
  } on TimeoutException catch (e) {
    print('Lỗi timeout: ${e.toString()}');
    throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
  } catch (e, stackTrace) {
    print('Lỗi không xác định: ${e.toString()}');
    print('Stack trace: $stackTrace');
    throw Exception('Lỗi khi khôi phục mật khẩu tài khoản sinh viên: ${e.toString()}');
  }
}
Future<bool> TaoTatCaTaiKhoanSinhVien() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/TaoTatCaTaiKhoanSinhVien'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Nếu cần thêm Authorization
      },
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Kết nối tới server quá thời gian (10s)');
    });

    if (response.statusCode == 200) {
      print('Đã tạo tài khoản thành công: ${response.body}');
      return true;
    } else if (response.statusCode == 400) {
      print('Lỗi dữ liệu từ server: ${response.body}');
      return false;
    } else {
      throw Exception('Lỗi khi tạo tài khoản sinh viên: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('Lỗi kết nối: ${e.toString()}');
    throw Exception('Không thể kết nối tới server: ${e.message}');
  } on TimeoutException catch (e) {
    print('Lỗi timeout: ${e.toString()}');
    throw Exception('Kết nối server quá thời gian: ${e.message}');
  } catch (e) {
    print('Lỗi không xác định: ${e.toString()}');
    throw Exception('Lỗi không xác định: ${e.toString()}');
  }
}

// PUT cập nhật mật khẩu tài khoản sinh viên
Future<bool> updatePasswordTaiKhoanSinhVien(String id, String newPassword) async {
  try {
    print('Đang kết nối tới: $baseUrl/$id/updatePassword');
    print('Dữ liệu gửi đi: {"newPassword": "$newPassword"}');
    
    final response = await http.put(
      Uri.parse('$baseUrl/$id/updatePassword'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'newPassword': newPassword}),
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Kết nối tới server quá thời gian (10s)');
    });

    print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
    print('Phản hồi từ server - Nội dung: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Dữ liệu không hợp lệ: Mật khẩu không hợp lệ');
    } else {
      throw Exception('Lỗi khi cập nhật mật khẩu tài khoản sinh viên: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('Lỗi Socket: ${e.toString()}');
    throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
  } on FormatException catch (e) {
    print('Lỗi định dạng: ${e.toString()}');
    throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
  } on TimeoutException catch (e) {
    print('Lỗi timeout: ${e.toString()}');
    throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
  } catch (e, stackTrace) {
    print('Lỗi không xác định: ${e.toString()}');
    print('Stack trace: $stackTrace');
    throw Exception('Lỗi khi cập nhật mật khẩu tài khoản sinh viên: ${e.toString()}');
  }
}

	
  // DELETE xóa tài khoản sinh viên
  Future<bool> deleteTaiKhoanSinhVien(String id) async {
    try {
      print('Đang kết nối tới: $baseUrl/$id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy tài khoản sinh viên với mã $id');
      } else {
        throw Exception('Lỗi khi xóa tài khoản sinh viên: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi xóa tài khoản sinh viên: ${e.toString()}');
    }
  }

  // Thêm phương thức lấy tài khoản sinh viên theo mã sinh viên
  Future<TaiKhoanSinhVien?> getTaiKhoanBySinhVienId(String maSV) async {
    try {
      print('Đang kết nối tới: $baseUrl');
      
      // Lấy tất cả tài khoản và tìm kiếm theo mã sinh viên
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<TaiKhoanSinhVien> taiKhoans = data.map((item) => TaiKhoanSinhVien.fromJson(item)).toList();
        
        // Tìm tài khoản có mã sinh viên trùng khớp
        for (var taiKhoan in taiKhoans) {
          if (taiKhoan.maTKSV == maSV) {
            return taiKhoan;
          }
        }
        
        // Không tìm thấy tài khoản cho sinh viên này
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập danh sách tài khoản sinh viên');
      } else {
        throw Exception('Lỗi khi tải danh sách tài khoản sinh viên: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tìm kiếm tài khoản sinh viên: ${e.toString()}');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
