import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../class/thongbao.dart';

class ApiThongBaoService {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/ThongBao';
  final String token;

  ApiThongBaoService(this.token);

  Future<List<ThongBao>> getThongBaos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        print('JSON danh sách thông báo: $jsonList');
        return (jsonList as List).map((json) {
          try {
            return ThongBao.fromJson(json);
          } catch (e, stack) {
            print('Lỗi khi parse một thông báo: $e');
            print('JSON lỗi: $json');
            print(stack);
            throw Exception('Lỗi khi parse ThongBao: $e');
          }
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập danh sách thông báo');
      } else {
        throw Exception('Lỗi khi tải danh sách thông báo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải thông báo: $e');
    }
  }

  Future<List<ThongBao>> getThongBaosByTaiKhoan(String maTKSV) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/byTaiKhoan/$maTKSV'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        print('JSON thông báo theo tài khoản $maTKSV: $jsonList');
        return (jsonList as List).map((json) {
          try {
            return ThongBao.fromJson(json);
          } catch (e, stack) {
            print('Lỗi khi parse thông báo: $e');
            print('JSON lỗi: $json');
            print(stack);
            throw Exception('Lỗi khi parse ThongBao: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thông báo cho tài khoản $maTKSV');
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập thông báo của tài khoản');
      } else {
        throw Exception('Lỗi khi tải thông báo theo tài khoản: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải thông báo theo tài khoản: $e');
    }
  }

  Future<ThongBao> createThongBao(ThongBao thongBao) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(thongBao.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        print('JSON trả về sau khi tạo thông báo: $json');
        try {
          return ThongBao.fromJson(json);
        } catch (e, stack) {
          print('Lỗi khi parse ThongBao sau POST: $e');
          print('JSON lỗi: $json');
          print(stack);
          throw Exception('Lỗi khi parse ThongBao sau tạo: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền tạo thông báo mới');
      } else {
        throw Exception('Lỗi khi tạo thông báo mới: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi tạo thông báo: $e');
    }
  }

  Future<bool> deleteThongBao(String maTT, String maTKSV) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$maTT/$maTKSV'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thông báo với mã $maTT và tài khoản $maTKSV');
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền xóa thông báo');
      } else {
        throw Exception('Lỗi khi xóa thông báo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi xóa thông báo: $e');
    }
  }

  Future<ThongBao> updateThongBao(ThongBao thongBao) async {
    try {
      // Thay đổi từ PUT sang POST để phù hợp với API endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/update'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(thongBao.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('JSON trả về sau cập nhật: $json');
        try {
          return ThongBao.fromJson(json);
        } catch (e, stack) {
          print('Lỗi khi parse ThongBao sau POST update: $e');
          print('JSON lỗi: $json');
          print(stack);
          throw Exception('Lỗi khi parse ThongBao sau cập nhật: $e');
        }
      } else if (response.statusCode == 204) {
        return thongBao;
      } else {
        print('Lỗi khi cập nhật thông báo: ${response.statusCode} - ${response.body}');
        throw Exception('Lỗi khi cập nhật thông báo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception khi cập nhật thông báo: $e');
      throw Exception('Lỗi không xác định khi cập nhật thông báo: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}