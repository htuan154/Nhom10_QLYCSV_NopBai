class ThongBao {
  final String maTT;
  final String maTKSV;
  final DateTime ngayTao;
  final String trangThai;

  ThongBao({
    required this.maTT,
    required this.maTKSV,
    required this.ngayTao, 
    required this.trangThai,
  });

  Map<String, dynamic> toJson() {
    return {
      'Ma_TT': maTT,
      'Ma_TKSV': maTKSV,
      'NgayTao': ngayTao.toIso8601String(),
      'TrangThai': trangThai,
    };
  }

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    try {
      return ThongBao(
        maTT: json['ma_TT']?.toString() ?? (throw Exception("ma_TT bị null")),
        maTKSV:
            json['ma_TKSV']?.toString() ?? (throw Exception("ma_TKSV bị null")),
        ngayTao: json['ngayTao'] != null
            ? DateTime.parse(json['ngayTao'])
            : throw Exception("ngayTao bị null"),
        trangThai: json['trangThai']?.toString() ??
            (throw Exception("trangThai bị null")),
      );
    } catch (e) {
      print('Lỗi khi parse ThongBao: $e');
      print('Dữ liệu JSON: $json');
      rethrow;
    }
  }
}
