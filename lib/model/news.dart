import 'package:flutter/material.dart' show Color;

//tạo các tin tức
class New {
  final String title, description, iconSrc;
  final Color color;
//
  New({
    required this.title,
    this.description = 'Thông tin cập nhật mới nhất cho sinh viên HUIT',
    this.iconSrc = "assets/icons/ios.svg",
    this.color = const Color(0xFF7553F6),
  });
}

// ignore: non_constant_identifier_names
final List<New> News = [
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần học kỳ mới là ngày 30/03/2025.",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Lịch thi cuối kỳ",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được công bố.",
    color: const Color(0xFF80A4FF),
  ),
];

final List<New> recentNews = [
  New(
    title: "Thông báo lịch thi",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
];

final List<New> notification_list = [
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
];

final List<New> history_list = [
  New(
    title: "Thông báo lịch thi tiếng anh đầu vào lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
  New(
    title: "Thông báo lịch thi lần 2",
    description: "Lịch thi học kỳ 2 năm học 2024 đã được cập nhật.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFF34A853),
  ),
  New(
    title: "Đăng ký học phần",
    description: "Hạn chót đăng ký học phần cho kỳ học mới: 30/03/2025.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFFA500),
  ),
  New(
    title: "Cơ hội học bổng",
    description: "Học bổng HUIT 2025 dành cho sinh viên xuất sắc.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color(0xFFFF4081),
  ),
  New(
    title: "Tuyển dụng thực tập",
    description: "Các công ty đối tác HUIT đang tuyển thực tập sinh IT.",
    iconSrc: "assets/icons/ios.svg",
    color: const Color.fromARGB(255, 156, 255, 184),
  ),
];
