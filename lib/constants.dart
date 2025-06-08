import 'package:flutter/material.dart';


const Color backgroundColor2 = Color(0xFF17203A);
const Color backgroundColorLight = Color(0xFFF2F6FF);
const Color backgroundColorDark = Color(0xFF25254B);
const Color shadowColorLight = Color(0xFF4A5367);
const Color shadowColorDark = Colors.black;


class AppConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:5085/api/';
  
  // Định nghĩa các màn hình
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String nhanVienListRoute = '/nhan-vien';
  static const String nhanVienDetailRoute = '/nhan-vien-detail';
  static const String nhanVienAddRoute = '/nhan-vien-add';
  static const String nhanVienEditRoute = '/nhan-vien-edit';
  static const String taiKhoanAddRoute = '/tai-khoan-add';
  
  // Các thông báo
  static const String errorLoadingData = 'Có lỗi khi tải dữ liệu';
  static const String errorSavingData = 'Có lỗi khi lưu dữ liệu';
  static const String successSavingData = 'Lưu dữ liệu thành công';
  static const String successAddingData = 'Thêm dữ liệu thành công';
  static const String successUpdatingData = 'Cập nhật dữ liệu thành công';
  static const String successDeletingData = 'Xóa dữ liệu thành công';
  
  // Các nút và nhãn
  static const String addButton = 'Thêm';
  static const String editButton = 'Sửa';
  static const String deleteButton = 'Xóa';
  static const String saveButton = 'Lưu';
  static const String cancelButton = 'Hủy';
  static const String confirmButton = 'Xác nhận';
  static const String backButton = 'Trở lại';
  
  // Thông báo xác nhận
  static const String confirmDeleteMessage = 'Bạn có chắc chắn muốn xóa?';
  static const String confirmLogoutMessage = 'Bạn có chắc chắn muốn đăng xuất?';
}