import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../class/tin_tuc.dart';

class ApiNewsService {
  final String baseUrl = 'https://api-appmobile-test.onrender.com/api/TinTuc'; // URL của API
  final String token; // Token xác thực

  // Constructor với token xác thực
  ApiNewsService(this.token);

  // GET danh sách tin tức
  Future<List<TinTuc>> getTinTucs() async {
    try {
      print('Đang kết nối tới: $baseUrl');
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => TinTuc.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập danh sách tin tức');
      } else {
        throw Exception('Lỗi khi tải danh sách tin tức: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tải danh sách tin tức: ${e.toString()}');
    }
  }

  // GET danh sách tin tức theo tài khoản
  Future<List<TinTuc>> getTinTucsByTaiKhoan(String maTK) async {
    try {
      print('Đang kết nối tới: $baseUrl/bytaikhoan/$maTK');
      
      final response = await http.get(
        Uri.parse('$baseUrl/bytaikhoan/$maTK'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => TinTuc.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy tin tức cho tài khoản $maTK');
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập tin tức của tài khoản');
      } else {
        throw Exception('Lỗi khi tải tin tức theo tài khoản: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tải tin tức theo tài khoản: ${e.toString()}');
    }
  }

  // GET tin tức theo mã tin tức
Future<TinTuc> getTinTucById(String maTT) async {
  try {
    print('Đang kết nối tới: $baseUrl/$maTT');

    final response = await http.get(
      Uri.parse('$baseUrl/$maTT'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Kết nối tới server quá thời gian (10s)');
    });

    print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
    print('Phản hồi từ server - Nội dung: ${response.body}');

    if (response.statusCode == 200) {
      // Nếu lấy thành công, parse dữ liệu trả về
      return TinTuc.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy tin tức với mã: $maTT');
    } else if (response.statusCode == 401) {
      throw Exception('Không có quyền truy cập tin tức');
    } else {
      throw Exception('Lỗi khi tải tin tức theo mã: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('Lỗi Socket: ${e.toString()}');
    throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
  } on FormatException catch (e) {
    print('Lỗi định dạng: ${e.toString()}');
    throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
  } on TimeoutException catch (e) {
    print('Lỗi timeout: ${e.toString()}');
    throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
  } catch (e, stackTrace) {
    print('Lỗi không xác định: ${e.toString()}');
    print('Stack trace: $stackTrace');
    throw Exception('Lỗi khi tải tin tức theo mã: ${e.toString()}');
  }
}

  // POST tạo tin tức mới
  Future<TinTuc> createTinTuc(TinTuc tinTuc) async {
    try {
      print('Đang kết nối tới: $baseUrl');
      print('Dữ liệu gửi đi: ${jsonEncode(tinTuc.toJson())}');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(tinTuc.toJson()),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');
      
      if (response.statusCode == 201) {
        return TinTuc.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền tạo tin tức mới');
      } else {
        throw Exception('Lỗi khi tạo tin tức mới: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi tạo tin tức mới: ${e.toString()}');
    }
  }

  // DELETE xóa tin tức
  Future<bool> deleteTinTuc(String maTT) async {
    try {
      print('Đang kết nối tới: $baseUrl/$maTT');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$maTT'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Kết nối tới server quá thời gian (10s)');
      });
      
      print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
      print('Phản hồi từ server - Nội dung: ${response.body}');

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy tin tức với mã $maTT');
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền xóa tin tức');
      } else {
        throw Exception('Lỗi khi xóa tin tức: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      print('Lỗi Socket: ${e.toString()}');
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
    } on FormatException catch (e) {
      print('Lỗi định dạng: ${e.toString()}');
      throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
    } on TimeoutException catch (e) {
      print('Lỗi timeout: ${e.toString()}');
      throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
    } catch (e, stackTrace) {
      print('Lỗi không xác định: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw Exception('Lỗi khi xóa tin tức: ${e.toString()}');
    }
  }

  // PUT cập nhật thông tin tin tức
  // PUT cập nhật thông tin tin tức
Future<TinTuc> updateTinTuc(TinTuc tinTuc) async {
  try {
    print('Đang kết nối tới: $baseUrl/${tinTuc.maTT}');
    print('Dữ liệu gửi đi: ${jsonEncode(tinTuc.toJson())}');

    final response = await http.put(
      Uri.parse('$baseUrl/${tinTuc.maTT}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(tinTuc.toJson()),
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Kết nối tới server quá thời gian (10s)');
    });

    print('Phản hồi từ server - Mã trạng thái: ${response.statusCode}');
    print('Phản hồi từ server - Nội dung: ${response.body}');

    if (response.statusCode == 200) {
      return TinTuc.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 204) {
      // Không có nội dung trả về, nhưng vẫn coi là thành công
      return tinTuc;
    } else if (response.statusCode == 400) {
      throw Exception('Dữ liệu không hợp lệ: ID không khớp');
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy tin tức với mã ${tinTuc.maTT}');
    } else if (response.statusCode == 401) {
      throw Exception('Không có quyền cập nhật tin tức');
    } else {
      throw Exception('Lỗi khi cập nhật tin tức: ${response.statusCode} - ${response.body}');
    }
  } on SocketException catch (e) {
    print('Lỗi Socket: ${e.toString()}');
    throw Exception('Không thể kết nối đến máy chủ. Kiểm tra đường dẫn URL và mạng: ${e.message}');
  } on FormatException catch (e) {
    print('Lỗi định dạng: ${e.toString()}');
    throw Exception('Lỗi định dạng dữ liệu từ server: ${e.message}');
  } on TimeoutException catch (e) {
    print('Lỗi timeout: ${e.toString()}');
    throw Exception('Kết nối đến máy chủ quá thời gian: ${e.message}');
  } catch (e, stackTrace) {
    print('Lỗi không xác định: ${e.toString()}');
    print('Stack trace: $stackTrace');
    throw Exception('Lỗi khi cập nhật tin tức: ${e.toString()}');
  }
}

}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}