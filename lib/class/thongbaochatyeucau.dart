class ThongBaoChatYeuCau {
  String? maTBCYC;
  String? maYC;
  String? maTK;
  String? noiDung;
  String? ngayThongBao;
  String? trangThai;

  ThongBaoChatYeuCau({
    this.maTBCYC,
    this.maYC,
    this.maTK,
    this.noiDung,
    this.ngayThongBao,
    this.trangThai,
  });

  factory ThongBaoChatYeuCau.fromJson(Map<String, dynamic> json) {
    return ThongBaoChatYeuCau(
      maTBCYC: json['ma_TBCYC'],
      maYC: json['ma_YC'],  
      maTK: json['ma_TK'],
      noiDung: json['noiDung'],
      ngayThongBao: json['ngayThongBao'],
      trangThai: json['trangThai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_TBCYC': maTBCYC,
      'ma_YC': maYC,
      'ma_TK': maTK,
      'noiDung': noiDung,
      'ngayThongBao': ngayThongBao,
      'trangThai': trangThai,
    };
  }
}
