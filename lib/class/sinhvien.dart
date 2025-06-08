import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';

class SinhVien {
  String maSV;
  String tenSV;
  String diaChi;
  DateTime ngaySinh;
  int khoaHoc;
  String loaiHinhDaoTao;
  String nganh;
  String lopHoc;
  String email;
  String maLop;
  String bacDaoTao;
  Lop? lop;
  String gioiTinh;
  List<TaiKhoanSinhVien> taiKhoanSinhViens;

  static int _currentMaSV = 0;

  SinhVien({
    String? maSV,
    required this.tenSV,
    required this.diaChi,
    required this.ngaySinh,
    required this.khoaHoc,
    required this.loaiHinhDaoTao,
    required this.nganh,
    required this.lopHoc,
    required this.email,
    required this.maLop,
    required this.gioiTinh,
    required this.bacDaoTao,
    this.lop,
    List<TaiKhoanSinhVien>? taiKhoanSinhViens,
  })  : maSV = maSV ?? _generateNextMaSV(),
        taiKhoanSinhViens = taiKhoanSinhViens ?? [];

  static String _generateNextMaSV() {
    _currentMaSV++;
    return _currentMaSV.toString().padLeft(10, '0');
  }

  factory SinhVien.fromJson(Map<String, dynamic> json) {
    return SinhVien(
      maSV: json['ma_SV'],
      tenSV: json['ten_SV'],
      diaChi: json['diaChi'],
      ngaySinh: DateTime.parse(json['ngaySinh']),
      khoaHoc: json['khoaHoc'],
      loaiHinhDaoTao: json['loaiHinhDaoTao'],
      nganh: json['nganh'],
      lopHoc: json['lopHoc'],
      email: json['email'],
      maLop: json['maLop'],
      gioiTinh: json['gioi_Tinh'], // ✅ sửa lại đúng key
      bacDaoTao: json['bacDaoTao'], // ✅ sửa lại đúng key
      lop: json['lop'] != null ? Lop.fromJson(json['lop']) : null,
      taiKhoanSinhViens: (json['taiKhoanSinhViens'] as List<dynamic>?)
              ?.map((item) => TaiKhoanSinhVien.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'Ma_SV': maSV,
    'Ten_SV': tenSV,
    'DiaChi': diaChi,
    'NgaySinh': ngaySinh.toIso8601String(),
    'KhoaHoc': khoaHoc,
    'BacDaoTao': bacDaoTao,
    'LoaiHinhDaoTao': loaiHinhDaoTao,
    'Nganh': nganh,
    'LopHoc': lopHoc,
    'Email': email,
    'MaLop': maLop,
    'Gioi_Tinh': gioiTinh,
    'Lop': lop?.toJson(),
    'TaiKhoanSinhViens': taiKhoanSinhViens.map((tk) => tk.toJson()).toList(),
  };
}

@override
String toString() {
  return 'SinhVien{'
      'maSV: $maSV, '
      'tenSV: $tenSV, '
      'diaChi: $diaChi, '
      'ngaySinh: $ngaySinh, '
      'khoaHoc: $khoaHoc, '
      'loaiHinhDaoTao: $loaiHinhDaoTao, '
      'nganh: $nganh, '
      'lopHoc: $lopHoc, '
      'email: $email, '
      'maLop: $maLop, '
      'bacDaoTao: $bacDaoTao, '
      'gioiTinh: $gioiTinh, '
      'lop: ${lop?.toString()}, '
      'taiKhoanSinhViens: ${taiKhoanSinhViens.map((e) => e.toString()).toList()}'
      '}';
}

}
