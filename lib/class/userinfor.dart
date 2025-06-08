class UserInfo {
  final String maTK;
  final String tenDangNhap;
  final String matKhau;
  final String maNV;
  final String maLoai;

  UserInfo({
    required this.maTK,
    required this.tenDangNhap,
    required this.matKhau,
    required this.maNV,
    required this.maLoai,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      maTK: json['ma_TK'],
      tenDangNhap: json['tenDangNhap'],
      matKhau: json['matKhau'],
      maNV: json['ma_NV'],
      maLoai: json['ma_Loai'],
    );
  }
}
