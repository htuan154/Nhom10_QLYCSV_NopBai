import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/yeucau.dart';

class ApiYeuCauService {
  static const String apiUrl = 'https://api-appmobile-test.onrender.com/api/YeuCaus';

  // Lấy danh sách tất cả yêu cầu
  static Future<List<Request>> getYeuCaus() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        return list.map((item) => Request.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load requests: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  // Lấy yêu cầu theo mã
  static Future<Request> getYeuCauById(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        return Request.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to load request with id $id: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching request by ID: $e');
    }
  }

  // Lấy danh sách yêu cầu theo mã tài khoản sinh viên
  static Future<List<Request>> getYeuCausByMaTKSV(String maTKSV) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/ByTaiKhoanSinhVien/$maTKSV'));
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        return list.map((item) => Request.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        // Không tìm thấy yêu cầu nào
        return [];
      } else {
        throw Exception(
            'Failed to load requests by maTKSV: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching requests by maTKSV: $e');
    }
  }

  // Thêm yêu cầu mới
  static Future<bool> addYeuCau(Request request) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to add request: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding request: $e');
    }
  }

  // Cập nhật yêu cầu
  static Future<bool> updateYeuCau(String id, Request request) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to update request with id $id: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating request: $e');
    }
  }

  // Xoá yêu cầu
  static Future<bool> deleteYeuCau(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete request with id $id: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting request: $e');
    }
  }
}
