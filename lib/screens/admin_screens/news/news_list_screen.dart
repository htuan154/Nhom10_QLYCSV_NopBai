import 'package:flutter/material.dart';
import 'package:doan_qlsv_nhom10/class/tin_tuc.dart';
import 'package:doan_qlsv_nhom10/services/api_news_service.dart';
import 'add_edit_news_screen.dart';
import 'package:doan_qlsv_nhom10/class/taikhoan.dart';
import 'package:doan_qlsv_nhom10/screens/home/detail_tintuc.dart';

class NewsListScreen extends StatefulWidget {
  final String token;
  final TaiKhoan taiKhoan;

  const NewsListScreen(
      {super.key, required this.token, required this.taiKhoan});

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late ApiNewsService _apiService;
  late Future<List<TinTuc>> _futureNews;

  @override
  void initState() {
    super.initState();
    // Initialize ApiNewsService with the token from widget
    _apiService = ApiNewsService(widget.token);
    _loadNews();
  }

  void _loadNews() {
    _futureNews = _apiService.getTinTucs();
  }

  void _showOptionsMenu(TinTuc news, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'edit') {
        _navigateToEditScreen(news);
      } else if (value == 'delete') {
        _showDeleteConfirmation(news);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Danh Sách Tin Tức'),
      ),
      body: Column(
        children: [
          // Add button section - nằm sát dưới AppBar và bên phải
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _navigateToAddScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm tin tức'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // News list section
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadNews();
                });
              },
              child: FutureBuilder<List<TinTuc>>(
                future: _futureNews,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không có tin tức nào'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final news = snapshot.data![index];
                        return Card(
                          color: Colors.white,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              news.noiDung,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'Đăng bởi: ${news.taiKhoan?.maTK ?? news.maTK}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Ngày tạo: ${_formatDate(news.ngayTao)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTapDown: (TapDownDetails details) {
                                _showOptionsMenu(news, details.globalPosition);
                              },
                              child: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              // Show full news content+
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewsDetailPage(
                                          tinTuc: news,
                                        )),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddEditNewsScreen(
                token: widget.token,
                tinTuc: null,
                taiKhoan: widget.taiKhoan,
              )),
    );

    if (result == true) {
      setState(() {
        _loadNews();
      });
    }
  }

  void _navigateToEditScreen(TinTuc news) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNewsScreen(
          tinTuc: news,
          token: widget.token,
          taiKhoan: widget.taiKhoan,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _loadNews();
      });
    }
  }

  void _showDeleteConfirmation(TinTuc news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa tin tức này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTinTuc(news.maTT);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteTinTuc(String maTT) async {
    try {
      await _apiService.deleteTinTuc(maTT);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa tin tức thành công')),
      );
      setState(() {
        _loadNews();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa tin tức: $e')),
      );
    }
  }
}
