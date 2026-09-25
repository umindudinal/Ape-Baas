import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import 'customer_bookings_screen.dart';
import 'provider_home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String role; // 'customer' හෝ 'provider'

  const NotificationsScreen({super.key, this.role = 'customer'});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notificationsList = [];
  String _selectedTab = 'සියල්ල';

  @override
  void initState() {
    super.initState();
    _loadAllNotifications();
  }

  Future<void> _loadAllNotifications() async {
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    String role = prefs.getString('role') ?? widget.role;

    List<String> clearedIds = prefs.getStringList('cleared_notification_ids') ?? [];
    List<String> readIds = prefs.getStringList('read_notification_ids') ?? [];

    List<Map<String, dynamic>> candidateList = [];

    // 1. Get FCM Notifications stored in NotificationService with strict role filtering
    final fcmItems = NotificationService().getReceivedNotifications();
    for (var item in fcmItems) {
      final Map<String, dynamic> data = item['data'] ?? {};
      final String recipientRole = (data['recipientRole'] ?? item['recipientRole'] ?? '').toString();
      final String title = (item['title'] ?? '').toString();

      if (role == 'customer') {
        if (recipientRole == 'provider' || title.contains('අලුත් සේවා ඉල්ලීමක්') || title.contains('නව සේවා ඉල්ලීමක්')) {
          continue; // Skip provider notifications for customer
        }
      } else if (role == 'provider') {
        if (recipientRole == 'customer') {
          continue; // Skip customer notifications for provider
        }
      }
      candidateList.add(item);
    }

    // 2. Fetch User Bookings to generate real booking status notifications
    if (userId.isNotEmpty) {
      try {
        List<dynamic> bookings = [];
        if (role == 'provider') {
          bookings = await ApiService.getProviderBookings(userId);
        } else {
          bookings = await ApiService.getCustomerBookings(userId);
        }

        for (var b in bookings) {
          final String status = b['status'] ?? 'pending';
          final String issue = b['issue'] ?? 'සේවා ඉල්ලීම';
          final String date = b['date'] ?? '';
          final String bId = (b['id'] ?? '').toString();

          if (role == 'customer') {
            if (status == 'accepted') {
              candidateList.add({
                'id': 'b_acc_$bId',
                'title': '✅ සේවා ඉල්ලීම භාරගන්නා ලදී',
                'body': 'ඔබගේ සේවා ඉල්ලීම ($issue) සේවා සපයන්නා විසින් සාර්ථකව භාරගන්නා ලදී.',
                'type': 'booking',
                'timestamp': date.isNotEmpty ? date : 'මෑතදී',
                'isRead': false,
                'data': {'bookingId': bId},
                'icon': Icons.check_circle_rounded,
                'color': AppColors.successGreen,
              });
            } else if (status == 'completed') {
              candidateList.add({
                'id': 'b_comp_$bId',
                'title': '🎉 සේවාව අවසන් කරන ලදී',
                'body': 'ඔබගේ සේවා ඉල්ලීම ($issue) සාර්ථකව අවසන් කර ඇත.',
                'type': 'booking',
                'timestamp': date.isNotEmpty ? date : 'මෑතදී',
                'isRead': true,
                'data': {'bookingId': bId},
                'icon': Icons.verified_rounded,
                'color': AppColors.deepNavy,
              });
            } else if (status == 'cancelled') {
              candidateList.add({
                'id': 'b_canc_$bId',
                'title': '❌ සේවා ඉල්ලීම අවලංගු විය',
                'body': 'ඔබගේ සේවා ඉල්ලීම ($issue) අවලංගු කර ඇත.',
                'type': 'booking',
                'timestamp': date.isNotEmpty ? date : 'මෑතදී',
                'isRead': true,
                'data': {'bookingId': bId},
                'icon': Icons.cancel_rounded,
                'color': AppColors.errorRed,
              });
            }
          } else {
            // Provider Notifications
            if (status == 'pending') {
              candidateList.add({
                'id': 'b_pend_$bId',
                'title': '🛠️ නව සේවා ඉල්ලීමක් පැමිණ ඇත',
                'body': 'ඔබට අලුත් සේවා ඉල්ලීමක් පැමිණ ඇත: $issue',
                'type': 'booking',
                'timestamp': date.isNotEmpty ? date : 'මෑතදී',
                'isRead': false,
                'data': {'bookingId': bId},
                'icon': Icons.build_circle_rounded,
                'color': AppColors.warningAmber,
              });
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching bookings for notifications: $e");
      }
    }

    // 3. Fetch Admin Push Broadcast Announcements from Backend
    try {
      final broadcasts = await ApiService.getAdminBroadcasts(role);
      for (var bc in broadcasts) {
        final String title = bc['title'] ?? 'නිවේදනයයි';
        final String message = bc['message'] ?? bc['body'] ?? '';
        final String bcId = (bc['id'] ?? '').toString();
        final String date = bc['created_at'] ?? bc['sentAt'] ?? 'මෑතදී';

        candidateList.add({
          'id': 'bc_$bcId',
          'title': title.startsWith('📢') ? title : '📢 $title',
          'body': message,
          'type': 'system',
          'timestamp': date,
          'isRead': false,
          'icon': Icons.campaign_rounded,
          'color': AppColors.navyDark,
        });
      }
    } catch (e) {
      debugPrint("Error fetching admin broadcasts: $e");
    }

    if (candidateList.isEmpty) {
      candidateList.add({
        'id': 'system_welcome',
        'title': '📢 "අපේ බාස්" වෙතින් සාදරයෙන් පිළිගනිමු!',
        'body': 'ඔබගේ සියලුම ගෘහස්ත සේවා (විදුලි, ජලනල, මේසන් ආදී) 24/7 පහසුවෙන්ම ලබා ගැනීමට අප සූදානම්.',
        'type': 'system',
        'timestamp': 'පද්ධති පණිවිඩය',
        'isRead': true,
        'icon': Icons.campaign_rounded,
        'color': AppColors.deepNavy,
      });
    }

    // Filter out cleared notifications and apply read status
    List<Map<String, dynamic>> finalList = [];
    for (var item in candidateList) {
      String id = (item['id'] ?? '').toString();
      if (id.isNotEmpty && clearedIds.contains(id)) {
        continue; // Cleared/Deleted by user
      }
      if (id.isNotEmpty && readIds.contains(id)) {
        item['isRead'] = true;
      }
      finalList.add(item);
    }

    int unreadCount = finalList.where((n) => n['isRead'] == false).length;
    NotificationService.unreadCountNotifier.value = unreadCount;

    if (mounted) {
      setState(() {
        _notificationsList = finalList;
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> readIds = prefs.getStringList('read_notification_ids') ?? [];

    setState(() {
      for (var n in _notificationsList) {
        n['isRead'] = true;
        String id = (n['id'] ?? '').toString();
        if (id.isNotEmpty && !readIds.contains(id)) {
          readIds.add(id);
        }
      }
    });

    await prefs.setStringList('read_notification_ids', readIds);
    NotificationService.unreadCountNotifier.value = 0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('සියලුම දැනුම්දීම් කියවූ ලෙස ලකුණු කරන ලදී.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  void _clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> clearedIds = prefs.getStringList('cleared_notification_ids') ?? [];

    for (var n in _notificationsList) {
      String id = (n['id'] ?? '').toString();
      if (id.isNotEmpty && !clearedIds.contains(id)) {
        clearedIds.add(id);
      }
    }

    await prefs.setStringList('cleared_notification_ids', clearedIds);

    setState(() {
      _notificationsList.clear();
    });
    NotificationService.unreadCountNotifier.value = 0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('සියලුම දැනුම්දීම් ඉවත් කරන ලදී.'),
          backgroundColor: AppColors.navyDark,
        ),
      );
    }
  }

  void _deleteSingleNotification(String id) async {
    if (id.isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> clearedIds = prefs.getStringList('cleared_notification_ids') ?? [];
    if (!clearedIds.contains(id)) {
      clearedIds.add(id);
      await prefs.setStringList('cleared_notification_ids', clearedIds);
    }

    setState(() {
      _notificationsList.removeWhere((n) => (n['id'] ?? '').toString() == id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('දැනුම්දීම ඉවත් කරන ලදී.'),
          backgroundColor: AppColors.navyDark,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredList {
    if (_selectedTab == 'සේවා') {
      return _notificationsList.where((n) => n['type'] == 'booking').toList();
    } else if (_selectedTab == 'පණිවිඩ') {
      return _notificationsList.where((n) => n['type'] == 'chat' || n['type'] == 'message').toList();
    }
    return _notificationsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text(
          'දැනුම්දීම් (Notifications)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppColors.navyDark,
        elevation: 0,
        actions: [
          if (_notificationsList.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: (val) {
                if (val == 'read_all') {
                  _markAllAsRead();
                } else if (val == 'clear_all') {
                  _clearAll();
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'read_all',
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded, color: AppColors.navyDark, size: 18),
                      SizedBox(width: 8),
                      Text('සියල්ල කියවූ ලෙස ලකුණු කරන්න', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 18),
                      SizedBox(width: 8),
                      Text('සියල්ල ඉවත් කරන්න', style: TextStyle(fontSize: 13, color: AppColors.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs Header
          Container(
            color: AppColors.navyDark,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildTabChip('සියල්ල'),
                const SizedBox(width: 8),
                _buildTabChip('සේවා'),
                const SizedBox(width: 8),
                _buildTabChip('පණිවිඩ'),
              ],
            ),
          ),

          // Main List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navyDark))
                : _filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAllNotifications,
                        color: AppColors.navyDark,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final item = _filteredList[index];
                            return _buildNotificationCard(item, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label) {
    final bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.navyDark : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, int index) {
    final String itemId = (item['id'] ?? index.toString()).toString();
    final bool isRead = item['isRead'] ?? true;
    final IconData iconData = item['icon'] ?? Icons.notifications_active_rounded;
    final Color iconColor = item['color'] ?? AppColors.deepNavy;

    return Dismissible(
      key: Key(itemId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) {
        _deleteSingleNotification(itemId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? AppColors.navyDark.withValues(alpha: 0.08) : AppColors.navyDark.withValues(alpha: 0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item['title'] ?? 'දැනුම්දීමයි',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item['body'] ?? '',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textDark, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  item['timestamp'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            onTap: () async {
              setState(() {
                item['isRead'] = true;
              });
              if (itemId.isNotEmpty) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> readIds = prefs.getStringList('read_notification_ids') ?? [];
                if (!readIds.contains(itemId)) {
                  readIds.add(itemId);
                  await prefs.setStringList('read_notification_ids', readIds);
                }
              }
              if (item['type'] == 'booking') {
                if (widget.role == 'provider') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerBookingsScreen()),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.navyDark.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_rounded, size: 48, color: AppColors.navyDark),
          ),
          const SizedBox(height: 16),
          const Text(
            'දැනුම්දීම් කිසිවක් නොමැත',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'ඔබට පැමිණෙන සියලුම නව දැනුම්දීම් මෙහි දිස්වනු ඇත.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
