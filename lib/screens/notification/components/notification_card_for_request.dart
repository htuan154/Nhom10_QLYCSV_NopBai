import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationCardforRequest extends StatelessWidget {
  final String title;
  final String message;
  final String iconSrc;
  final Color color;
  final String time;
  final bool isUnread;
  final VoidCallback onDetailPressed;
  final VoidCallback? onTap;

  const NotificationCardforRequest({
    Key? key,
    required this.title,
    required this.iconSrc,
    required this.color,
    required this.onDetailPressed,
    this.message = "",
    this.time = "",
    this.isUnread = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isUnread
              ? Border.all(color: Colors.redAccent.withOpacity(0.4), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Nội dung thông báo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 6),
                  // Nội dung ngắn
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onDetailPressed,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Xem chi tiết"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 60,
              child: VerticalDivider(
                color: Colors.white38,
                thickness: 1,
              ),
            ),
            const SizedBox(width: 12),
            // Icon SVG hoặc icon Material
            iconSrc.endsWith('.svg')
                ? SvgPicture.asset(
                    iconSrc,
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  )
                : Icon(
                    isUnread
                        ? Icons.mark_email_unread
                        : Icons.mark_email_read,
                    color: Colors.white,
                    size: 32,
                  ),
          ],
        ),
      ),
    );
  }
}
