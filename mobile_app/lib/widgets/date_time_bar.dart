import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable DateTime & Status Bar Header widget for ApeBaas mobile app.
/// Ensures system status bar icons (time, wifi, mobile data, battery) remain
/// perfectly visible with proper safe area padding and contrast.
class DateTimeBar extends StatefulWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Brightness iconBrightness;
  final bool showLiveTime;
  final Widget? title;
  final List<Widget>? actions;

  const DateTimeBar({
    super.key,
    this.backgroundColor = const Color(0xFF001730),
    this.iconBrightness = Brightness.light,
    this.showLiveTime = true,
    this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<DateTimeBar> createState() => _DateTimeBarState();
}

class _DateTimeBarState extends State<DateTimeBar> {
  late String _currentTime;
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    _currentTime = '$hour:$minute $period';

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    _currentDate = '$weekday, ${now.day.toString().padLeft(2, '0')} $month';
  }


  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkBackground = widget.backgroundColor.computeLuminance() < 0.5;
    final overlayStyle = isDarkBackground
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Container(
        color: widget.backgroundColor,
        padding: EdgeInsets.fromLTRB(
          18,
          statusBarHeight + 12,
          18,
          14,
        ),
        child: Row(
          children: [
            if (widget.showLiveTime) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentTime,
                    style: TextStyle(
                      color: isDarkBackground ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentDate,
                    style: TextStyle(
                      color: isDarkBackground ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            if (widget.title != null) Expanded(child: widget.title!),
            if (widget.actions != null) ...widget.actions!,
          ],
        ),
      ),
    );
  }
}
