import 'taikhoan.dart';
import 'yeucau.dart';

class XuLyYeuCau {
  final String maYC;
  final String maTK;
  final DateTime ngayXuLy;
  final String trangThaiCu;
  final String trangThaiMoi;

  final Request? yeuCau;      
  final TaiKhoan? taiKhoan;   

  XuLyYeuCau({
    required this.maYC,
    required this.maTK,
    required this.ngayXuLy,
    required this.trangThaiCu,
    required this.trangThaiMoi,
    this.yeuCau,
    this.taiKhoan,
  });

  factory XuLyYeuCau.fromJson(Map<String, dynamic> json) {
    return XuLyYeuCau(
      maYC: json['ma_YC'] as String,
      maTK: json['ma_TK'] as String,
      ngayXuLy: DateTime.parse(json['ngayXuLy']),
      trangThaiCu: json['trangThai_cu'] ?? '',
      trangThaiMoi: json['trangThai_moi'] ?? '',
      yeuCau: json['yeuCau'] != null ? Request.fromJson(json['yeuCau']) : null,
      taiKhoan: json['taiKhoan'] != null ? TaiKhoan.fromJson(json['taiKhoan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ma_YC': maYC,
      'ma_TK': maTK,
      'ngayXuLy': ngayXuLy.toIso8601String(),
      'trangThai_cu': trangThaiCu,
      'trangThai_moi': trangThaiMoi,
    };

    // Chỉ thêm nếu không null
    if (yeuCau != null) {
      data['yeuCau'] = yeuCau!.toJson();
    }
    if (taiKhoan != null) {
      data['taiKhoan'] = taiKhoan!.toJson();
    }

    return data;
  }
}
