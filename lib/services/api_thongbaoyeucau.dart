import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/thongbaoyeucau.dart';

class ApiThongBaoYeuCauService {
  static const String _baseUrl = 'https://api-appmobile-test.onrender.com/api/ThongBaoYeuCaus';

  // Lấy tất cả thông báo yêu cầu
  Future<List<ThongBaoYeuCau>> getAllThongBaoYeuCaus() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ThongBaoYeuCau.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load ThongBaoYeuCaus');
      }
    } catch (e) {
      print('Error in getAllThongBaoYeuCaus: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Lấy thông báo yêu cầu theo mã yêu cầu
  Future<List<ThongBaoYeuCau>> getThongBaoByYeuCau(String maYC) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/byyeucau/$maYC'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ThongBaoYeuCau.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load ThongBaoYeuCau for maYC: $maYC');
      }
    } catch (e) {
      print('Error in getThongBaoByYeuCau: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Lấy thông báo yêu cầu theo mã tài khoản sinh viên
  Future<List<ThongBaoYeuCau>> getThongBaoByTaiKhoanSinhVien(
      String maTKSV) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bytaikhoan/$maTKSV'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ThongBaoYeuCau.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load ThongBaoYeuCau for maTKSV: $maTKSV');
      }
    } catch (e) {
      print('Error in getThongBaoByTaiKhoanSinhVien: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Tạo mới một thông báo yêu cầu
  Future<ThongBaoYeuCau> createThongBaoYeuCau(ThongBaoYeuCau thongBao) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(thongBao.toJson()),
      );

      if (response.statusCode == 201) {
        return ThongBaoYeuCau.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create ThongBaoYeuCau');
      }
    } catch (e) {
      print('Error in createThongBaoYeuCau: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Cập nhật một thông báo yêu cầu
  Future<void> updateThongBaoYeuCau(ThongBaoYeuCau thongBao) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${thongBao.maTBYC}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(thongBao.toJson()),
      );

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('ThongBaoYeuCau not found');
        } else {
          throw Exception('Failed to update ThongBaoYeuCau');
        }
      }
    } catch (e) {
      print('Error in updateThongBaoYeuCau: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Xoá thông báo theo mã
  Future<void> deleteThongBaoYeuCau(String maTBYC) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$maTBYC'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('ThongBaoYeuCau not found');
        } else {
          throw Exception('Failed to delete ThongBaoYeuCau');
        }
      }
    } catch (e) {
      print('Error in deleteThongBaoYeuCau: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
}
