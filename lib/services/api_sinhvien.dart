import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';

class ApiServiceSinhVien {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/SinhVien'; // URL của API
  final String token; // Token xác thực

  ApiServiceSinhVien(this.token);

  Future<List<SinhVien>> getSinhViens() async {
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
        return data.map((item) => SinhVien.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập danh sách sinh viên');
      } else {
        throw Exception('Lỗi khi tải danh sách sinh viên: ${response.statusCode}');
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
      throw Exception('Lỗi khi tải danh sách sinh viên: ${e.toString()}');
    }
  }

  // GET thông tin một sinh viên theo id
  Future<SinhVien> getSinhVienById(String id) async {
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
        return SinhVien.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy sinh viên với mã $id');
      } else {
        throw Exception('Lỗi khi tải thông tin sinh viên: ${response.statusCode}');
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
      throw Exception('Lỗi khi tải thông tin sinh viên: ${e.toString()}');
    }
  }

  // POST tạo sinh viên mới (chỉ Admin có quyền)
  Future<SinhVien> createSinhVien(SinhVien sinhVien) async {
    try {
      print('Đang kết nối tới: $baseUrl');
      print('Dữ liệu gửi đi: ${jsonEncode(sinhVien.toJson())}');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(sinhVien.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 201) {
        return SinhVien.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền tạo sinh viên mới');
      } else {
        throw Exception('Lỗi khi tạo sinh viên mới: ${response.statusCode} - ${response.body}');
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
      throw Exception('Lỗi khi tạo sinh viên mới: ${e.toString()}');
    }
  }

  // PUT cập nhật thông tin sinh viên (chỉ Admin có quyền)
  Future<bool> updateSinhVien(String id, SinhVien sinhVien) async {
    try {
      print('Đang kết nối tới: $baseUrl/$id');
      print('Dữ liệu gửi đi: ${jsonEncode(sinhVien.toJson())}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(sinhVien.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền cập nhật sinh viên');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy sinh viên với mã $id');
      } else {
        throw Exception('Lỗi khi cập nhật sinh viên: ${response.statusCode} - ${response.body}');
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
      throw Exception('Lỗi khi cập nhật sinh viên: ${e.toString()}');
    }
  }

  // DELETE xóa sinh viên (chỉ Admin có quyền)
  Future<bool> deleteSinhVien(String id) async {
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
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền xóa sinh viên');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy sinh viên với mã $id');
      } else {
        throw Exception('Lỗi khi xóa sinh viên: ${response.statusCode} - ${response.body}');
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
      throw Exception('Lỗi khi xóa sinh viên: ${e.toString()}');
    }
  }

  // Tìm kiếm sinh viên theo tên (chỉ Admin có quyền)
  Future<List<SinhVien>> searchSinhVien(String name) async {
    try {
      print('Đang kết nối tới: $baseUrl/search?name=$name');
      
      final response = await http.get(
        Uri.parse('$baseUrl/search?name=$name'),
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
        return data.map((item) => SinhVien.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền tìm kiếm sinh viên');
      } else if (response.statusCode == 404) {
        return []; // Trả về danh sách rỗng nếu không tìm thấy
      } else {
        throw Exception('Lỗi khi tìm kiếm sinh viên: ${response.statusCode}');
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
      throw Exception('Lỗi khi tìm kiếm sinh viên: ${e.toString()}');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}