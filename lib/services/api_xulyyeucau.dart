import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/xu_ly_yeu_cau.dart';

class ApiXuLyYeuCauService {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/XuLyYeuCaus';
  final String token;

  ApiXuLyYeuCauService(this.token);

  Future<List<XuLyYeuCau>> getXuLyYeuCaus() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        return (jsonList as List)
            .map((json) => XuLyYeuCau.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Lỗi khi tải danh sách xử lý yêu cầu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải xử lý yêu cầu: $e');
    }
  }

  Future<XuLyYeuCau> getXuLyYeuCauById(String maYC, String maTK) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$maYC/$maTK'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return XuLyYeuCau.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy xử lý yêu cầu với mã: $maYC - $maTK');
      } else {
        throw Exception('Lỗi khi tải xử lý yêu cầu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải xử lý yêu cầu: $e');
    }
  }

  Future<List<XuLyYeuCau>> getXuLyYeuCauByMaYC(String maYC) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/YeuCau/$maYC'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        return (jsonList as List)
            .map((json) => XuLyYeuCau.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception(
            'Không tìm thấy xử lý yêu cầu nào với mã yêu cầu: $maYC');
      } else {
        throw Exception(
            'Lỗi khi tải xử lý yêu cầu theo mã YC: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Lỗi không xác định khi tải xử lý yêu cầu theo mã YC: $e');
    }
  }

  Future<List<XuLyYeuCau>> getXuLyYeuCauByMaTK(String maTK) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/TaiKhoan/$maTK'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        return (jsonList as List)
            .map((json) => XuLyYeuCau.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception(
            'Không tìm thấy xử lý yêu cầu nào với mã tài khoản: $maTK');
      } else {
        throw Exception(
            'Lỗi khi tải xử lý yêu cầu theo mã tài khoản: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Lỗi không xác định khi tải xử lý yêu cầu theo mã tài khoản: $e');
    }
  }

  Future<XuLyYeuCau> createXuLyYeuCau(XuLyYeuCau xly) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(xly.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return XuLyYeuCau.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Lỗi khi tạo xử lý yêu cầu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi tạo xử lý yêu cầu: $e');
    }
  }

  Future<bool> deleteXuLyYeuCau(String maYC, String maTK) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$maYC/$maTK'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Lỗi khi xóa xử lý yêu cầu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi xóa xử lý yêu cầu: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
