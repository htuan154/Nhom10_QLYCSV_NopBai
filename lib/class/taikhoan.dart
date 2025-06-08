import 'nhanvien.dart';
import 'loaitaikhoan.dart';

class TaiKhoan {
  final String maTK;
  final String tenDangNhap;
  final String matKhau;
  final String maNV;
  final String maLoai;
  final NhanVien? nhanVien;
  final LoaiTaiKhoan? loaiTaiKhoan;

  TaiKhoan({
    required this.maTK,
    required this.tenDangNhap,
    required this.matKhau,
    required this.maNV,
    required this.maLoai,
    this.nhanVien,
    this.loaiTaiKhoan,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      maTK: json['ma_TK'],
      tenDangNhap: json['tenDangNhap'],
      matKhau: json['matKhau'],
      maNV: json['ma_NV'],
      maLoai: json['ma_Loai'],
      nhanVien: json['nhanVien'] != null
          ? NhanVien.fromJson(json['nhanVien'])
          : null,
      loaiTaiKhoan: json['loaiTaiKhoan'] != null
          ? LoaiTaiKhoan.fromJson(json['loaiTaiKhoan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_TK': maTK,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'ma_NV': maNV,
      'ma_Loai': maLoai,
      'nhanVien': nhanVien?.toJson(),
      'loaiTaiKhoan': loaiTaiKhoan?.toJson(),
    };
  }

  @override
  String toString() {
    return 'TaiKhoan(maTK: $maTK, tenDangNhap: $tenDangNhap, matKhau: $matKhau, maNV: $maNV, maLoai: $maLoai, '
           'nhanVien: ${nhanVien?.toString()}, loaiTaiKhoan: ${loaiTaiKhoan?.toString()})';
  }

  TaiKhoan copyWith({
    String? maTK,
    String? tenDangNhap,
    String? matKhau,
    String? maNV,
    String? maLoai,
    NhanVien? nhanVien,
    LoaiTaiKhoan? loaiTaiKhoan,
  }) {
    return TaiKhoan(
      maTK: maTK ?? this.maTK,
      tenDangNhap: tenDangNhap ?? this.tenDangNhap,
      matKhau: matKhau ?? this.matKhau,
      maNV: maNV ?? this.maNV,
      maLoai: maLoai ?? this.maLoai,
      nhanVien: nhanVien ?? this.nhanVien,
      loaiTaiKhoan: loaiTaiKhoan ?? this.loaiTaiKhoan,
    );
  }
}
