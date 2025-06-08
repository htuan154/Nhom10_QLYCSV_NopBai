import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/thongbaochatyeucau.dart';

class ApiThongBaoChatYeuCauService {
  static const String _baseUrl =
      'https://api-appmobile-test.onrender.com/api/ThongBaoChatYeuCau';

  // Lấy tất cả thông báo chat yêu cầu
  Future<List<ThongBaoChatYeuCau>> getAllThongBaoChatYeuCau() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ThongBaoChatYeuCau.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load list');
      }
    } catch (e) {
      print('Error getAllThongBaoChatYeuCau: $e');
      throw Exception('Connection failed');
    }
  }

  // Lấy thông báo theo mã
  Future<ThongBaoChatYeuCau> getThongBaoChatYeuCauById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        return ThongBaoChatYeuCau.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Not found');
      }
    } catch (e) {
      print('Error getThongBaoChatYeuCauById: $e');
      throw Exception('Connection failed');
    }
  }

  // Lấy danh sách thông báo theo mã tài khoản
  Future<List<ThongBaoChatYeuCau>> getThongBaoByMaTK(String maTK) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/TaiKhoan/$maTK'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ThongBaoChatYeuCau.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        // Không có thông báo nào
        return [];
      } else {
        throw Exception('Failed to load notifications for account');
      }
    } catch (e) {
      print('Error getThongBaoByMaTK: $e');
      throw Exception('Connection failed');
    }
  }

  // Tạo mới
  Future<ThongBaoChatYeuCau> createThongBaoChatYeuCau(
      ThongBaoChatYeuCau tb) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tb.toJson()),
      );

      if (response.statusCode == 201) {
        return ThongBaoChatYeuCau.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create');
      }
    } catch (e) {
      print('Error createThongBaoChatYeuCau: $e');
      throw Exception('Connection failed');
    }
  }

  // Cập nhật
  Future<void> updateThongBaoChatYeuCau(
      String id, ThongBaoChatYeuCau tb) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tb.toJson()),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update');
      }
    } catch (e) {
      print('Error updateThongBaoChatYeuCau: $e');
      throw Exception('Connection failed');
    }
  }

  // Xoá
  Future<void> deleteThongBaoChatYeuCau(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      print('Error deleteThongBaoChatYeuCau: $e');
      throw Exception('Connection failed');
    }
  }

  // Gửi thông báo đến tất cả người xử lý
  Future<void> sendToAllXuLy(String maYeuCau, String noiDung) async {
    try {
      final uri = Uri.parse('$_baseUrl/SendToAllXuLy')
          .replace(queryParameters: {'ma_YC': maYeuCau, 'noiDung': noiDung});

      final response = await http.post(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to send notifications');
      }
    } catch (e) {
      print('Error sendToAllXuLy: $e');
      throw Exception('Connection failed');
    }
  }
}
