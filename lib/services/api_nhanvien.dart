// File: lib/api/api_nhanvien.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/nhanvien.dart';

class ApiNhanVien {
  static const String baseUrl = 'https://api-appmobile-test.onrender.com/api/NhanViens';

  static Future<List<NhanVien>> fetchNhanViens() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => NhanVien.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách nhân viên');
    }
  }

  static Future<NhanVien?> fetchNhanVienById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return NhanVien.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  static Future<bool> addNhanVien(NhanVien nv) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nv.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Lỗi khi thêm nhân viên: ${response.statusCode}');
      print('Nội dung lỗi từ server: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Lỗi exception khi thêm nhân viên: $e');
    return false;
  }
}

  static Future<bool> updateNhanVien(String id, NhanVien nv) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nv.toJson()),
    );
    return response.statusCode == 204;
  }

  static Future<bool> deleteNhanVien(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 204;
  }
}
