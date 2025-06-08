import 'tai_khoan_sinh_vien.dart';
import 'loai_yeu_cau.dart';
import 'xu_ly_yeu_cau.dart';

class Request {
  final String maYC;
  final String? maLoaiYC;
  final LoaiYeuCau? loaiYeuCau;
  final String maTKSV;
  final TaiKhoanSinhVien? taiKhoanSinhVien;
  final String noiDung;
  final DateTime ngayTao;
  final String trangThai;
  final List<XuLyYeuCau>? xuLyYeuCaus;

  Request({
    required this.maYC,
    this.maLoaiYC,
    this.loaiYeuCau,
    required this.maTKSV,
    this.taiKhoanSinhVien,
    required this.noiDung,
    required this.ngayTao,
    required this.trangThai,
    this.xuLyYeuCaus,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      maYC: json['ma_YC'],
      maLoaiYC: json['ma_loaiYC'],
      loaiYeuCau: json['loaiYeuCau'] != null ? LoaiYeuCau.fromJson(json['loaiYeuCau']) : null,
      maTKSV: json['ma_TKSV'],
      taiKhoanSinhVien: json['taiKhoanSinhVien'] != null
          ? TaiKhoanSinhVien.fromJson(json['taiKhoanSinhVien'])
          : null,
      noiDung: json['noiDung'],
      ngayTao: DateTime.parse(json['ngayTao']),
      trangThai: json['trangThai'],
      xuLyYeuCaus: json['xuLyYeuCaus'] != null
          ? List<XuLyYeuCau>.from(
              json['xuLyYeuCaus'].map((x) => XuLyYeuCau.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_YC': maYC,
      'ma_loaiYC': maLoaiYC,
      'loaiYeuCau': loaiYeuCau?.toJson(),
      'ma_TKSV': maTKSV,
      'taiKhoanSinhVien': taiKhoanSinhVien?.toJson(),
      'noiDung': noiDung,
      'ngayTao': ngayTao.toIso8601String(),
      'trangThai': trangThai,
      'xuLyYeuCaus': xuLyYeuCaus?.map((x) => x.toJson()).toList(),
    };
  }
}
