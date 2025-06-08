import 'yeucau.dart';  

class LichSuYeuCau {
  final String maLSYC;
  final String trangThaiMoi;
  final String trangThaiCu;
  final String maYC;
  final Request yeuCau;

  LichSuYeuCau({
    required this.maLSYC,
    required this.trangThaiMoi,
    required this.trangThaiCu,
    required this.maYC,
    required this.yeuCau,
  });

  // Factory method to create an instance from JSON
  factory LichSuYeuCau.fromJson(Map<String, dynamic> json) {
    return LichSuYeuCau(
      maLSYC: json['ma_LSYC'],
      trangThaiMoi: json['trangThaiMoi'],
      trangThaiCu: json['trangThaiCu'],
      maYC: json['ma_YC'],
      yeuCau: Request.fromJson(json['yeuCau']),  // Chuyển dữ liệu của YeuCau
    );
  }

  // Convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'ma_LSYC': maLSYC,
      'trangThaiMoi': trangThaiMoi,
      'trangThaiCu': trangThaiCu,
      'ma_YC': maYC,
      'yeuCau': yeuCau.toJson(),  // Chuyển đối tượng YeuCau thành JSON
    };
  }
}
