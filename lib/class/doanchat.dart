class DoanChat {
  final String maDC;
  final String maYC;
  final DateTime ngayTao;
  final String maNguoiGui;
  final String noiDung;

  DoanChat({
    required this.maDC,
    required this.maYC,
    required this.ngayTao,
    required this.maNguoiGui,
    required this.noiDung,
  });

  factory DoanChat.fromJson(Map<String, dynamic> json) {
    return DoanChat(
      maDC: json['ma_DC'],
      maYC: json['ma_YC'],
      ngayTao: DateTime.parse(json['ngayTao']),
      maNguoiGui: json['maNguoiGui'],
      noiDung: json['noiDung'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Ma_DC': maDC,
      'Ma_YC': maYC,
      'NgayTao': ngayTao.toIso8601String(),
      'MaNguoiGui': maNguoiGui,
      'NoiDung': noiDung,
    };
  }
}
