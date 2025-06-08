import 'taikhoan.dart';  // Import `TaiKhoan` để sử dụng mối quan hệ với `TaiKhoan`

class TinTuc {
  final String maTT;
  final String maTK;
  final String noiDung;
  final DateTime ngayTao;
  final TaiKhoan? taiKhoan; 

  TinTuc({
    required this.maTT,
    required this.maTK,
    required this.noiDung,
    required this.ngayTao,
    this.taiKhoan,  
  });

  factory TinTuc.fromJson(Map<String, dynamic> json) {
    return TinTuc(
      maTT: json['ma_TT'],
      maTK: json['ma_TK'],
      noiDung: json['noiDung'],
      ngayTao: DateTime.parse(json['ngayTao']),
      taiKhoan: json['taiKhoan'] != null
          ? TaiKhoan.fromJson(json['taiKhoan'])
          : null,  
    );
  }

  @override
  String toString() {
    return 'TinTuc(maTT: $maTT, maTK: $maTK, noiDung: $noiDung, ngayTao: $ngayTao, taiKhoan: ${taiKhoan?.toString() ?? "null"})';
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ma_TT': maTT,
      'ma_TK': maTK,
      'noiDung': noiDung,
      'ngayTao': ngayTao.toIso8601String(),
      'taiKhoan': taiKhoan?.toJson(),  // Chuyển đổi TaiKhoan thành JSON nếu có
    };
  }
}
