import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';

/// Class API client để tương tác với LopController trên backend
class LopApiClient {
  final String apiUrl = 'https://api-appmobile-test.onrender.com/api/Lop';
  final http.Client _httpClient;

  /// Khởi tạo LopApiClient
  LopApiClient({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Tạo headers với token xác thực nếu có
  Map<String, String> _createHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Lấy danh sách tất cả các lớp
  Future<List<Lop>> getLops({String? token}) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(apiUrl),
        headers: _createHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> lopJsonList = json.decode(response.body);
        return lopJsonList.map((lopJson) => Lop.fromJson(lopJson)).toList();
      } else {
        throw Exception(
            'Không thể lấy danh sách lớp. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách lớp: $e');
    }
  }

  /// Lấy thông tin chi tiết của một lớp theo ID
  Future<Lop> getLop(String id, {String? token}) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$apiUrl/$id'),
        headers: _createHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return Lop.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy lớp với mã: $id');
      } else {
        throw Exception(
            'Không thể lấy thông tin lớp. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin lớp: $e');
    }
  }

  /// Tạo một lớp mới
  Future<Lop> createLop(Lop lop, {String? token}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(apiUrl),
        headers: _createHeaders(token: token),
        body: json.encode(lop.toJson()),
      );

      if (response.statusCode == 201) {
        return Lop.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Không thể tạo lớp mới. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo lớp mới: $e');
    }
  }

  /// Cập nhật thông tin của một lớp
  Future<bool> updateLop(String id, Lop lop, {String? token}) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$apiUrl/$id'),
        headers: _createHeaders(token: token),
        body: json.encode(lop.toJson()),
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật lớp: $e');
    }
  }

  /// Xóa một lớp theo ID
  Future<bool> deleteLop(String id, {String? token}) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$apiUrl/$id'),
        headers: _createHeaders(token: token),
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Lỗi khi xóa lớp: $e');
    }
  }

  /// Lấy danh sách sinh viên của một lớp
  Future<List<SinhVien>> getSinhViensByLop(String maLop, {String? token}) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$apiUrl/$maLop/sinhviens'),
        headers: _createHeaders(token: token),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> sinhVienJsonList = json.decode(response.body);
        return sinhVienJsonList
            .map((svJson) => SinhVien.fromJson(svJson))
            .toList();
      } else if (response.statusCode == 404) {
        // Xử lý khi API báo không có sinh viên trong lớp, không phải lỗi
        final body = response.body.toLowerCase();
        if (body.contains('không tìm thấy sinh viên') ||
            body.contains('không có sinh viên') ||
            body.contains('empty') ||
            body.contains('[]')) {
          // Trả về danh sách rỗng, không phải lỗi
          return [];
        } else {
          // 404 thật sự lỗi lớp không tồn tại
          throw Exception('Không tìm thấy lớp với mã: $maLop');
        }
      } else {
        throw Exception(
            'Không thể lấy danh sách sinh viên. Mã lỗi: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('LỖI TOÀN BỘ: $e');
      print('STACK TRACE: $stackTrace');
      throw Exception('Lỗi khi lấy danh sách sinh viên: $e');
    }
  }

  /// Thêm sinh viên vào lớp
  Future<bool> addSinhVienToLop(String maLop, String maSV, {String? token}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$apiUrl/$maLop/sinhviens/$maSV'),
        headers: _createHeaders(token: token),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Lỗi không xác định'
            : 'Lỗi không xác định';
        throw Exception('Không thể thêm sinh viên vào lớp: $errorMsg');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm sinh viên vào lớp: $e');
    }
  }

  /// Xóa sinh viên khỏi lớp
  Future<bool> removeSinhVienFromLop(String maLop, String maSV, {String? token}) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$apiUrl/$maLop/sinhviens/$maSV'),
        headers: _createHeaders(token: token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty 
            ? json.decode(response.body)['message'] ?? 'Lỗi không xác định'
            : 'Lỗi không xác định';
        throw Exception('Không thể xóa sinh viên khỏi lớp: $errorMsg');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa sinh viên khỏi lớp: $e');
    }
  }

  /// Đóng HTTP client khi không còn sử dụng
  void dispose() {
    _httpClient.close();
  }
}