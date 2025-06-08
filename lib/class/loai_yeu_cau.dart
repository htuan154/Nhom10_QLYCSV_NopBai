class LoaiYeuCau {
  final String maLoaiYC;
  final String tenLoaiYC;

  LoaiYeuCau({
    required this.maLoaiYC,
    required this.tenLoaiYC,
  });

  factory LoaiYeuCau.fromJson(Map<String, dynamic> json) {
    return LoaiYeuCau(
      maLoaiYC: json['ma_loaiYC'],
      tenLoaiYC: json['ten_loaiYC'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Ma_loaiYC': maLoaiYC,
      'Ten_loaiYC': tenLoaiYC,
    };
  }
}
