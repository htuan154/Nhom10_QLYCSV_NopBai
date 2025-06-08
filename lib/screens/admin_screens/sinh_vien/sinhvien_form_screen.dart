import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doan_qlsv_nhom10/class/sinhvien.dart';
import 'package:doan_qlsv_nhom10/class/lop.dart';
import 'package:doan_qlsv_nhom10/services/api_sinhvien.dart';
import 'package:doan_qlsv_nhom10/services/api_lop.dart';
import 'package:doan_qlsv_nhom10/class/tai_khoan_sinh_vien.dart';
import 'package:doan_qlsv_nhom10/services/api_taikhoansinhvien.dart';
import 'package:doan_qlsv_nhom10/class/thongbao.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_thongbao.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';

class SinhVienFormScreen extends StatefulWidget {
  final SinhVien? sinhVien;
  final String token;
  final Lop? initialLop; // Thêm tham số lớp ban đầu

  SinhVienFormScreen({this.sinhVien, required this.token, this.initialLop});

  @override
  _SinhVienFormScreenState createState() => _SinhVienFormScreenState();
}

class _SinhVienFormScreenState extends State<SinhVienFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Lop> lopList = [];
  Lop? selectedLop;

  late String maSV;
  String tenSV = '', diaChi = '', email = '', gioiTinh = 'Nam', lopHoc = '';
  String loaiHinhDaoTao = 'Chính quy',
      nganh = 'Công nghệ thông tin',
      bacDaoTao = 'Đại học';
  late DateTime ngaySinh;
  int khoaHoc = DateTime.now().year;
  String maLop = '';

  // Thêm các API service cho thông báo
  late ApiThongBaoService _apiThongBao;
  late ApiNewsService _apiNews;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo API services
    _apiThongBao = ApiThongBaoService(widget.token);
    _apiNews = ApiNewsService(widget.token);
    
    if (widget.sinhVien != null) {
      final sv = widget.sinhVien!;
      maSV = sv.maSV;
      tenSV = sv.tenSV;
      diaChi = sv.diaChi;
      email = sv.email;
      gioiTinh = sv.gioiTinh;
      lopHoc = sv.lopHoc;
      loaiHinhDaoTao = sv.loaiHinhDaoTao;
      nganh = sv.nganh;
      bacDaoTao = sv.bacDaoTao;
      ngaySinh = sv.ngaySinh;
      khoaHoc = sv.khoaHoc;
      maLop = sv.maLop;
    } else {
      maSV = '';
      ngaySinh = DateTime.now();

      // Nếu có lớp ban đầu, sử dụng nó
      if (widget.initialLop != null) {
        maLop = widget.initialLop!.maLop;
        lopHoc = widget.initialLop!.tenLop;
      }
    }

    _fetchLops();
  }

  Future<void> _fetchLops() async {
    final api = LopApiClient();
    try {
      lopList = await api.getLops();

      if (lopList.isEmpty) return;

      setState(() {
        // Nếu có initialLop, ưu tiên chọn lớp đó
        if (widget.initialLop != null) {
          selectedLop = lopList.firstWhere(
            (lp) => lp.maLop == widget.initialLop!.maLop,
            orElse: () => lopList.first,
          );
        } else {
          selectedLop = lopList.firstWhere(
            (lp) => lp.maLop == maLop,
            orElse: () => lopList.first,
          );
        }
      });
    } catch (e) {
      print('Lỗi khi tải danh sách lớp: $e');
    }
  }

  // Hàm tạo thông báo cho sinh viên mới
  Future<void> _taoThongBaoChoSinhVienMoi(String maTKSV) async {
    try {
      // Lấy danh sách tất cả tin tức
      final tinTucs = await _apiNews.getTinTucs();
      
      if (tinTucs.isEmpty) {
        print('Không có tin tức nào để tạo thông báo');
        return;
      }

      // Lấy tất cả thông báo hiện có để kiểm tra trùng lặp
      final allThongBaos = await _apiThongBao.getThongBaos();
      
      int successCount = 0;

      // Tạo thông báo cho từng tin tức
      for (var tinTuc in tinTucs) {
        // Kiểm tra xem thông báo đã tồn tại chưa
        final exists = allThongBaos.any((tb) => 
            tb.maTT == tinTuc.maTT && tb.maTKSV == maTKSV);

        if (!exists) {
          final thongBao = ThongBao(
            maTT: tinTuc.maTT,
            maTKSV: maTKSV,
            ngayTao: DateTime.now(),
            trangThai: 'Chưa xem',
          );
          
          await _apiThongBao.createThongBao(thongBao);
          successCount++;
        }
      }

      if (successCount > 0) {
        print('Đã tạo $successCount thông báo cho sinh viên mới');
      }
    } catch (e) {
      print('Lỗi khi tạo thông báo cho sinh viên mới: $e');
      // Không hiển thị lỗi cho người dùng vì đây là chức năng phụ
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Tạo maNV nếu là thêm mới
      final timestamp = DateTime.now();
      final formattedTime =
          '${timestamp.year}${_twoDigits(timestamp.month)}${_twoDigits(timestamp.day)}'
          '${_twoDigits(timestamp.hour)}${_twoDigits(timestamp.minute)}${_twoDigits(timestamp.second)}';
      final fixedMaSV =
          widget.sinhVien?.maSV ?? 'SV${email.hashCode}$formattedTime';

      final sv = SinhVien(
        maSV: fixedMaSV,
        tenSV: tenSV,
        diaChi: diaChi,
        email: email,
        gioiTinh: gioiTinh,
        lopHoc: selectedLop?.tenLop ?? '',
        loaiHinhDaoTao: loaiHinhDaoTao,
        nganh: nganh,
        bacDaoTao: bacDaoTao,
        ngaySinh: ngaySinh,
        khoaHoc: khoaHoc,
        maLop: selectedLop?.maLop ?? '',
        lop: selectedLop,
      );

      final apiSV = ApiServiceSinhVien(widget.token);
      final apiTKSV = ApiServiceTaiKhoanSinhVien(widget.token);

      try {
        if (widget.sinhVien == null) {
          final createdSV = await apiSV.createSinhVien(sv);

          if (createdSV != null) {
            final maSVStripped = createdSV.maSV?.replaceFirst('SV', '') ?? '';

            final taiKhoanSV = TaiKhoanSinhVien(
              maTKSV: 'TK$maSVStripped',
              tenDangNhap: createdSV.email ?? '',
              matKhau: DateFormat('ddMMyyyy').format(createdSV.ngaySinh!),
              maSV: createdSV.maSV ?? '',
              sinhVien: null,
            );

            try {
              final createTKResult =
                  await apiTKSV.createTaiKhoanSinhVien(taiKhoanSV);

              if (createTKResult == null || createTKResult.maTKSV == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Tạo tài khoản sinh viên mặc định thất bại')),
                );
              } else {
                // Tạo thông báo cho sinh viên mới sau khi tạo tài khoản thành công
                await _taoThongBaoChoSinhVienMoi(createTKResult.maTKSV!);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Lỗi khi tạo tài khoản: ${e.toString()}')),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Thêm sinh viên thành công')),
            );
            Navigator.pop(context, true);
          }
        } else {
          final result = await apiSV.updateSinhVien(maSV, sv);
          if (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật sinh viên thành công')),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật sinh viên thất bại')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickNgaySinh(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ngaySinh,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => ngaySinh = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
            widget.sinhVien == null ? 'Thêm sinh viên' : 'Cập nhật sinh viên'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Tên sinh viên'),
                  initialValue: tenSV,
                  onSaved: (value) => tenSV = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Không được bỏ trống' : null,
                ),
              DropdownButtonFormField<String>(
                value: gioiTinh,
                decoration: InputDecoration(labelText: 'Giới tính'),
                items: ['Nam', 'Nữ'].map((gt) {
                  return DropdownMenuItem(value: gt, child: Text(gt));
                }).toList(),
                onChanged: (value) => setState(() => gioiTinh = value!),
                onSaved: (value) => gioiTinh = value!,
                validator: (value) =>
                    value == null ? 'Vui lòng chọn giới tính' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Địa chỉ'),
                initialValue: diaChi,
                onSaved: (value) => diaChi = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Không được bỏ trống' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                initialValue: email,
                onSaved: (value) => email = value!,
                validator: (value) {
                  if (value!.isEmpty) return 'Không được bỏ trống';
                  if (!value.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              // Nếu có initialLop thì hiển thị trường đã khóa
              widget.initialLop != null
                  ? TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Lớp',
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                      ),
                      initialValue:
                          '${selectedLop?.maLop ?? ''} - ${selectedLop?.tenLop ?? ''}',
                      enabled: false,
                    )
                  : DropdownButtonFormField<Lop>(
                      value: selectedLop,
                      items: lopList.map((lop) {
                        return DropdownMenuItem<Lop>(
                          value: lop,
                          child: Text('${lop.maLop} - ${lop.tenLop}'),
                        );
                      }).toList(),
                      onChanged: (Lop? newValue) {
                        setState(() {
                          selectedLop = newValue;
                          maLop = newValue?.maLop ?? '';
                          lopHoc = newValue?.tenLop ?? '';
                        });
                      },
                      decoration: InputDecoration(labelText: 'Lớp'),
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn lớp' : null,
                    ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ngành'),
                initialValue: nganh,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Loại hình đào tạo'),
                initialValue: loaiHinhDaoTao,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bậc đào tạo'),
                initialValue: bacDaoTao,
                enabled: false,
              ),
              ListTile(
                title: Text(
                    'Ngày sinh: ${ngaySinh.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickNgaySinh(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Khóa học'),
                initialValue: khoaHoc.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    khoaHoc = int.tryParse(value!) ?? DateTime.now().year,
                validator: (value) {
                  if (value!.isEmpty) return 'Không được bỏ trống';
                  if (int.tryParse(value) == null) return 'Phải là số';
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text('Lưu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}