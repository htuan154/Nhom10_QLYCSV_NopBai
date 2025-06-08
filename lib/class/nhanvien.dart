class NhanVien {
  String? maNV;
  String? tenNV;
  String? diaChi;
  DateTime? ngaySinh;  // Cambiado a DateTime en lugar de String
  int? namVaoLam;      // Se mantiene como int
  String? chucVu;
  String? email;
  String? gioiTinh;
  String? soDienThoai;
  dynamic taiKhoans;

  NhanVien({
    this.maNV,
    this.tenNV,
    this.diaChi,
    this.ngaySinh,
    this.namVaoLam,
    this.chucVu,
    this.email,
    this.gioiTinh,
    this.soDienThoai,
    this.taiKhoans,
  });

  factory NhanVien.fromJson(Map<String, dynamic> json) {
    return NhanVien(
      maNV: json['ma_NV'],
      tenNV: json['ten_NV'],
      diaChi: json['diaChi'],
      // Convertir la fecha de string a DateTime
      ngaySinh: json['ngaySinh'] != null ? DateTime.parse(json['ngaySinh']) : null,
      // Asegurar que namVaoLam sea int
      namVaoLam: json['namVaoLam'] is int ? json['namVaoLam'] : (json['namVaoLam'] != null ? int.tryParse(json['namVaoLam'].toString()) : null),
      chucVu: json['chucVu'],
      email: json['email'],
      gioiTinh: json['gioitinh'],
      soDienThoai: json['sdt'],
      taiKhoans: json['taiKhoans'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_NV': maNV,
      'ten_NV': tenNV,
      'diaChi': diaChi,
      // Convertir DateTime a formato ISO string para JSON
      'ngaySinh': ngaySinh?.toIso8601String(),
      'namVaoLam': namVaoLam,
      'chucVu': chucVu,
      'email': email,
      'gioitinh': gioiTinh,
      'sdt': soDienThoai,
      'taiKhoans': taiKhoans,
    };
  }

  @override
  String toString() {
    // Formatear ngaySinh para mostrar de manera más amigable
    String fechaNacimiento = ngaySinh != null 
        ? '${ngaySinh!.year}-${ngaySinh!.month.toString().padLeft(2, '0')}-${ngaySinh!.day.toString().padLeft(2, '0')}'
        : 'null';
        
    return 'NhanVien(maNV: $maNV, tenNV: $tenNV, diaChi: $diaChi, ngaySinh: $fechaNacimiento, '
           'namVaoLam: $namVaoLam, chucVu: $chucVu, email: $email, gioiTinh: $gioiTinh, '
           'soDienThoai: $soDienThoai, taiKhoans: $taiKhoans)';
  }
  
  // Método auxiliar para formatear la fecha de nacimiento
  String? get formattedNgaySinh {
    if (ngaySinh == null) return null;
    return '${ngaySinh!.day.toString().padLeft(2, '0')}/${ngaySinh!.month.toString().padLeft(2, '0')}/${ngaySinh!.year}';
  }
}