class LoaiTaiKhoan {
  final String maLoai;
  final String tenLoai;
  final List<dynamic> taiKhoans;

  LoaiTaiKhoan({
    required this.maLoai,
    required this.tenLoai,
    this.taiKhoans = const [], // mặc định là rỗng
  });

  factory LoaiTaiKhoan.fromJson(Map<String, dynamic> json) {
    return LoaiTaiKhoan(
      maLoai: json['ma_Loai'],
      tenLoai: json['ten_Loai'],
      taiKhoans: json['taiKhoans'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_Loai': maLoai,
      'ten_Loai': tenLoai,
      'taiKhoans': taiKhoans,
    };
  }
}
