import 'package:doan_qlsv_nhom10/class/sinhvien.dart';

class Lop {
  String maLop;
  String tenLop;
  List<SinhVien> sinhViens;

  Lop({
    required this.maLop,
    required this.tenLop,
    List<SinhVien>? sinhViens,
  }) : sinhViens = sinhViens ?? [];

  // Có thể thêm phương thức để hỗ trợ JSON (nếu bạn cần)
  factory Lop.fromJson(Map<String, dynamic> json) {
    return Lop(
      maLop: json['maLop'],
      tenLop: json['tenLop'],
      sinhViens: (json['sinhViens'] as List<dynamic>?)
          ?.map((item) => SinhVien.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maLop': maLop,
      'tenLop': tenLop,
      'sinhViens': sinhViens.map((sv) => sv.toJson()).toList(),
    };
  }
}