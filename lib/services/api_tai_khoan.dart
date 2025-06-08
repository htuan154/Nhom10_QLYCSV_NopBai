import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';

class ApiTaiKhoan {
  static const String baseUrl = 'https://api-appmobile-test.onrender.com/api/TaiKhoans';

  /// Lấy danh sách tài khoản
  static Future<List<TaiKhoan>> fetchTaiKhoans() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => TaiKhoan.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách tài khoản');
    }
  }

  static Future<List<TaiKhoan>> getAllTaiKhoan() async {
  final response = await http.get(Uri.parse('https://api-appmobile-test.onrender.com/api/TaiKhoans'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => TaiKhoan.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load tài khoản');
  }
}

  /// Lấy thông tin tài khoản theo ID
  static Future<TaiKhoan?> fetchTaiKhoanById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return TaiKhoan.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  /// Thêm tài khoản mới
  static Future<bool> createTaiKhoan(TaiKhoan tk) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tk.toJson()),
    );

    return response.statusCode == 201;
  }

  /// Cập nhật tài khoản
  static Future<bool> updateTaiKhoan(String id, TaiKhoan tk) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tk.toJson()),
    );

    return response.statusCode == 204;
  }

  /// Xoá tài khoản
  static Future<bool> deleteTaiKhoan(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    return response.statusCode == 204;
  }

  /// Tạo tài khoản hàng loạt cho các nhân viên chưa có
  static Future<String> createBulkTaiKhoans() async {
    final response = await http.post(Uri.parse('$baseUrl/CreateBulk'));

    if (response.statusCode == 200) {
      return response.body; 
    } else {
      throw Exception('Lỗi khi tạo tài khoản hàng loạt');
    }
  }
}
