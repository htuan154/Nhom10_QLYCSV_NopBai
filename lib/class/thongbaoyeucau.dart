class ThongBaoYeuCau {
  String maTBYC;
  String maYC;
  String maTKSV;
  String noiDung;
  DateTime ngayThongBao;
  String trangThai; 

  ThongBaoYeuCau({
    required this.maTBYC,
    required this.maYC,
    required this.maTKSV,
    required this.noiDung,
    required this.ngayThongBao,
    required this.trangThai,
  });

  factory ThongBaoYeuCau.fromJson(Map<String, dynamic> json) {
    return ThongBaoYeuCau(
      maTBYC: json['ma_TBYC'],
      maYC: json['ma_YC'],
      maTKSV: json['ma_TKSV'],
      noiDung: json['noiDung'],
      ngayThongBao: DateTime.parse(json['ngayThongBao']),
      trangThai: json['trangThai'], // Thêm dòng này
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_TBYC': maTBYC,
      'ma_YC': maYC,
      'ma_TKSV': maTKSV,
      'noiDung': noiDung,
      'ngayThongBao': ngayThongBao.toIso8601String(),
      'trangThai': trangThai, // Thêm dòng này
    };
  }
}
