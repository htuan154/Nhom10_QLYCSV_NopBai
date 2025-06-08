import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/doanchat.dart';

class ApiDoanChatService {
  static const String _baseUrl = 'https://api-appmobile-test.onrender.com/api/DoanChats';

  // Lấy tất cả đoạn chat
  Future<List<DoanChat>> getAllDoanChats() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => DoanChat.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load DoanChats');
      }
    } catch (e) {
      print('Error in getAllDoanChats: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Lấy đoạn chat theo mã yêu cầu (maYC)
  Future<List<DoanChat>> getDoanChatsByYeuCau(String maYC) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/byyeucau/$maYC'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => DoanChat.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load DoanChats for maYC: $maYC');
      }
    } catch (e) {
      print('Error in getDoanChatsByYeuCau: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<DoanChat>> getDoanChatsByTaiKhoan(String maTK) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bytaikhoan/$maTK'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => DoanChat.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load DoanChats for maTK: $maTK');
      }
    } catch (e) {
      print('Error in getDoanChatsByTaiKhoan: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Tạo mới một đoạn chat
  Future<DoanChat> createDoanChat(DoanChat chat) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(chat.toJson()),
      );

      if (response.statusCode == 201) {
        return DoanChat.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create DoanChat');
      }
    } catch (e) {
      print('Error in createDoanChat: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Xoá đoạn chat theo mã
  Future<void> deleteDoanChat(String maDC) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$maDC'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('DoanChat not found');
        } else {
          throw Exception('Failed to delete DoanChat');
        }
      }
    } catch (e) {
      print('Error in deleteDoanChat: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
}
