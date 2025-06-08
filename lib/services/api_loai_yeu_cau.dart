import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/loai_yeu_cau.dart';

class ApiLoaiYeuCauService {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/LoaiYeuCaus';

  // GET all LoaiYeuCau
  Future<List<LoaiYeuCau>> getAllLoaiYeuCau() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      print('GET status: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LoaiYeuCau.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load LoaiYeuCau - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllLoaiYeuCau: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // GET LoaiYeuCau by ID
  Future<LoaiYeuCau> getLoaiYeuCauById(String id) async {
    try {
      final baseDomain = _getBaseDomain(baseUrl);
      final response = await http.get(
        Uri.parse('$baseDomain/api/LoaiYeuCaus/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return LoaiYeuCau.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('LoaiYeuCau not found');
      } else {
        throw Exception(
            'Failed to get LoaiYeuCau - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getLoaiYeuCauById: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // POST create new LoaiYeuCau
  Future<LoaiYeuCau> createLoaiYeuCau(LoaiYeuCau loaiYeuCau) async {
    try {
      final baseDomain = _getBaseDomain(baseUrl);
      final bodyData = jsonEncode(loaiYeuCau.toJson());
      print('POST body: $bodyData');

      final response = await http.post(
        Uri.parse('$baseDomain/api/LoaiYeuCaus'),
        headers: {'Content-Type': 'application/json'},
        body: bodyData,
      );

      print('Create Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return LoaiYeuCau.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to create LoaiYeuCau - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in createLoaiYeuCau: $e');
      throw Exception('Failed to create LoaiYeuCau: $e');
    }
  }

  // PUT update LoaiYeuCau
  Future<void> updateLoaiYeuCau(String id, LoaiYeuCau loaiYeuCau) async {
    try {
      final baseDomain = _getBaseDomain(baseUrl);
      final bodyData = jsonEncode(loaiYeuCau.toJson());
      print('PUT body: $bodyData');

      final response = await http.put(
        Uri.parse('$baseDomain/api/LoaiYeuCaus/$id'),
        headers: {'Content-Type': 'application/json'},
        body: bodyData,
      );

      print('Update Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to update LoaiYeuCau - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in updateLoaiYeuCau: $e');
      throw Exception('Failed to update LoaiYeuCau: $e');
    }
  }

  // DELETE LoaiYeuCau
  Future<void> deleteLoaiYeuCau(String id) async {
    try {
      final baseDomain = _getBaseDomain(baseUrl);
      final response = await http.delete(
        Uri.parse('$baseDomain/api/LoaiYeuCaus/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete LoaiYeuCau - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in deleteLoaiYeuCau: $e');
      throw Exception('Failed to delete LoaiYeuCau: $e');
    }
  }

  // Helper to extract base domain from URL
  String _getBaseDomain(String url) {
    Uri uri = Uri.parse(url);
    if (uri.path.contains('/api/LoaiYeuCaus')) {
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return url;
  }
}
