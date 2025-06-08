import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/loaitaikhoan.dart';

class ApiLoaiTaiKhoanService {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/LoaiTaiKhoans';
  // Get all LoaiTaiKhoan
  Future<List<LoaiTaiKhoan>> getAllLoaiTaiKhoan() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<LoaiTaiKhoan> loaiTaiKhoans = body.map((dynamic item) => LoaiTaiKhoan.fromJson(item)).toList();
        return loaiTaiKhoans;
      } else {
        throw Exception('Failed to load LoaiTaiKhoans - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllLoaiTaiKhoan: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Get LoaiTaiKhoan by ID
  Future<LoaiTaiKhoan> getLoaiTaiKhoanById(String id) async {
    try {
      // Extract the base part without the endpoint
      String baseDomain = _getBaseDomain(baseUrl);
      
      final response = await http.get(
        Uri.parse('$baseDomain/api/LoaiTaiKhoans/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return LoaiTaiKhoan.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('LoaiTaiKhoan not found');
      } else {
        throw Exception('Failed to get LoaiTaiKhoan - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getLoaiTaiKhoanById: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Create new LoaiTaiKhoan
  Future<LoaiTaiKhoan> createLoaiTaiKhoan(LoaiTaiKhoan loaiTaiKhoan) async {
    try {
      // Extract the base part without the endpoint
      String baseDomain = _getBaseDomain(baseUrl);
      
      // Prepare the JSON payload
      final jsonPayload = loaiTaiKhoan.toJson();
      print('Sending JSON payload: $jsonPayload');
      
      final response = await http.post(
        Uri.parse('$baseDomain/api/LoaiTaiKhoans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(jsonPayload),
      );
      
      print('Create Response status: ${response.statusCode}');
      print('Create Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return LoaiTaiKhoan.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create LoaiTaiKhoan - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createLoaiTaiKhoan: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Update LoaiTaiKhoan
  Future<void> updateLoaiTaiKhoan(String id, LoaiTaiKhoan loaiTaiKhoan) async {
    try {
      // Extract the base part without the endpoint
      String baseDomain = _getBaseDomain(baseUrl);
      
      // Prepare the JSON payload
      final jsonPayload = loaiTaiKhoan.toJson();
      print('Sending JSON payload for update: $jsonPayload');
      
      final response = await http.put(
        Uri.parse('$baseDomain/api/LoaiTaiKhoans/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(jsonPayload),
      );
      
      print('Update Response status: ${response.statusCode}');
      print('Update Response body: ${response.body}');
      
      if (response.statusCode != 204) {
        if (response.statusCode == 400) {
          throw Exception('Bad request - Check if ID matches the object ID');
        } else if (response.statusCode == 404) {
          throw Exception('LoaiTaiKhoan not found');
        } else {
          throw Exception('Failed to update LoaiTaiKhoan - Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in updateLoaiTaiKhoan: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Delete LoaiTaiKhoan
  Future<void> deleteLoaiTaiKhoan(String id) async {
    try {
      // Extract the base part without the endpoint
      String baseDomain = _getBaseDomain(baseUrl);
      
      final response = await http.delete(
        Uri.parse('$baseDomain/api/LoaiTaiKhoans/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Delete Response status: ${response.statusCode}');
      
      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('LoaiTaiKhoan not found');
        } else {
          throw Exception('Failed to delete LoaiTaiKhoan - Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in deleteLoaiTaiKhoan: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Helper method to extract base domain from URL
  String _getBaseDomain(String url) {
    Uri uri = Uri.parse(url);
    
    // If the path contains the API endpoint, extract just the base part
    if (uri.path.contains('/api/LoaiTaiKhoans')) {
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    
    return url;
  }
}