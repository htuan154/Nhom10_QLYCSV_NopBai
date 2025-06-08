import 'sinhvien.dart';

class TaiKhoanSinhVien {
  final String maTKSV;
  final String tenDangNhap;
  final String matKhau;
  final String maSV;
  final SinhVien? sinhVien;

  TaiKhoanSinhVien({
    required this.maTKSV,
    required this.tenDangNhap,
    required this.matKhau,
    required this.maSV,
    this.sinhVien,
  });

  factory TaiKhoanSinhVien.fromJson(Map<String, dynamic> json) {
    return TaiKhoanSinhVien(
      maTKSV: json['ma_TKSV'],
      tenDangNhap: json['tenDangNhap'],
      matKhau: json['matKhau'],
      maSV: json['ma_SV'],
      sinhVien: json['sinhVien'] != null
          ? SinhVien.fromJson(json['sinhVien'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_TKSV': maTKSV,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'ma_SV': maSV,
      'sinhVien': sinhVien?.toJson(),
    };
  }
}
