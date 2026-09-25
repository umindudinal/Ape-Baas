import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'chat_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  final VoidCallback? onFindServices;

  const CustomerBookingsScreen({
    super.key,
    this.onFindServices,
  });

  @override
  State<CustomerBookingsScreen> createState() => CustomerBookingsScreenState();
}

class CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  String _selectedBookingTab = 'සියල්ල';
  Future<List<dynamic>>? _customerBookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadCustomerBookings();
  }

  void reloadBookings() {
    _loadCustomerBookings();
  }

  void _loadCustomerBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    if (userId.isNotEmpty && mounted) {
      setState(() {
        _customerBookingsFuture = ApiService.getCustomerBookings(userId);
      });
    }
  }

  ImageProvider? _getImageProvider(String imageStr) {
    if (imageStr.trim().isEmpty) return null;
    if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
      return NetworkImage(imageStr);
    }
    try {
      String cleanBase64 = imageStr;
      if (imageStr.contains(',')) {
        cleanBase64 = imageStr.split(',').last;
      }
      return MemoryImage(base64Decode(cleanBase64));
    } catch (e) {
      return null;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('දුරකථන ඇමතුම් ලබාගත නොහැකි විය: $cleanPhone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['සියල්ල', 'ක්‍රියාත්මකයි', 'අවසන් කළ ඒවා', 'අවලංගුයි'];

    return Column(
      children: [
        // Top Header Banner (Styled to match Settings Screen)
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 12, 14, 16),
            decoration: const BoxDecoration(
              color: AppColors.navyDark,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'මගේ වෙන්කිරීම් (My Bookings)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                  onPressed: _loadCustomerBookings,
                  tooltip: 'නැවත පූරණය කරන්න',
                ),
              ],
            ),
          ),
        ),

        // Filter Tabs Row in Body
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.map((tab) {
                final isSelected = _selectedBookingTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBookingTab = tab;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.deepNavy : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.deepNavy : AppColors.cardBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.deepNavy.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Bookings List Section
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadCustomerBookings();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.deepNavy,
            child: FutureBuilder<List<dynamic>>(
              future: _customerBookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.deepNavy));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.errorRed),
                        const SizedBox(height: 10),
                        const Text('දත්ත ලබා ගැනීමේ දෝෂයක්!', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadCustomerBookings,
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          label: const Text('නැවත උත්සාහ කරන්න', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNavy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: const BoxDecoration(
                              color: AppColors.navySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded, size: 50, color: AppColors.deepNavy),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'දැනට වෙන්කිරීම් කිසිවක් නොමැත',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ඔබ සේවාවන් වෙන්කරගත් පසු සියලුම විස්තර සහ තත්ත්වයන් (Status) මෙහි පෙන්වනු ඇත.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          if (widget.onFindServices != null)
                            ElevatedButton.icon(
                              onPressed: widget.onFindServices,
                              icon: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                              label: const Text('සේවාවන් සොයන්න (Find Baas)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepNavy,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                // Filter bookings by tab
                final allBookings = snapshot.data!;
                final filteredBookings = allBookings.where((b) {
                  final status = (b['status'] ?? 'pending').toString().toLowerCase();
                  if (_selectedBookingTab == 'ක්‍රියාත්මකයි') {
                    return status == 'pending' || status == 'accepted';
                  } else if (_selectedBookingTab == 'අවසන් කළ ඒවා') {
                    return status == 'completed';
                  } else if (_selectedBookingTab == 'අවලංගුයි') {
                    return status == 'cancelled';
                  }
                  return true;
                }).toList();

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_rounded, size: 50, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          '\'$_selectedBookingTab\' කාණ්ඩයේ වෙන්කිරීම් හමු නොවීය.',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final item = filteredBookings[index];
                    final status = (item['status'] ?? 'pending').toString().toLowerCase();
                    final providerName = item['provider_name'] ?? item['provider']?['full_name'] ?? 'සේවා සපයන්නා';
                    final providerPhone = item['provider_phone'] ?? item['provider']?['phone'] ?? 'නොමැත';
                    final providerImgStr = (item['provider_image_url'] ?? (item['provider'] != null ? item['provider']['profile_image_url'] : '') ?? '').toString();
                    final provImgProvider = _getImageProvider(providerImgStr);
                    final issue = item['issue'] ?? 'විස්තර සඳහන් කර නැත';
                    final date = item['service_date'] ?? 'දිනය නොමැත';
                    final category = item['provider']?['service_category'] ?? item['category'] ?? '';

                    Color statusBgColor = const Color(0xFFFFFBEB);
                    Color statusTextColor = const Color(0xFF92400E);
                    Color statusBorderColor = AppColors.warningAmber.withValues(alpha: 0.4);
                    String statusText = 'රැඳී සිටින (Pending)';
                    IconData statusIcon = Icons.hourglass_top_rounded;

                    if (status == 'accepted') {
                      statusBgColor = AppColors.navySubtle;
                      statusTextColor = AppColors.deepNavy;
                      statusBorderColor = AppColors.navyLight.withValues(alpha: 0.4);
                      statusText = 'භාරගන්නා ලදී (Accepted)';
                      statusIcon = Icons.thumb_up_alt_rounded;
                    } else if (status == 'completed') {
                      statusBgColor = const Color(0xFFECFDF5);
                      statusTextColor = AppColors.successGreen;
                      statusBorderColor = AppColors.successGreen.withValues(alpha: 0.4);
                      statusText = 'අවසන් (Completed)';
                      statusIcon = Icons.check_circle_rounded;
                    } else if (status == 'cancelled') {
                      statusBgColor = const Color(0xFFFFE4E6);
                      statusTextColor = AppColors.errorRed;
                      statusBorderColor = AppColors.errorRed.withValues(alpha: 0.4);
                      statusText = 'අවලංගුයි (Cancelled)';
                      statusIcon = Icons.cancel_rounded;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Provider Avatar, Name, Category Pill & Status Badge
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.2), width: 1.5),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.navySubtle,
                                    backgroundImage: provImgProvider,
                                    child: provImgProvider == null
                                        ? Text(
                                            providerName.isNotEmpty ? providerName[0].toUpperCase() : 'P',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.deepNavy,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        providerName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navyDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (category.toString().isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.navySubtle,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            category.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(fontSize: 10, color: AppColors.deepNavy, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Quick Call Icon Button for Provider
                                if (providerPhone != 'නොමැත' && providerPhone.toString().trim().isNotEmpty) ...[
                                  InkWell(
                                    onTap: () => _makePhoneCall(providerPhone),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.4)),
                                      ),
                                      child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.successGreen, size: 15),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],

                                // Status Badge Box
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusBorderColor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, size: 12, color: statusTextColor),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            statusText,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: statusTextColor,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFEEF2F6)),

                          // Middle Section: Issue Description & Meta Details
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.navySubtle,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.handyman_rounded, size: 16, color: AppColors.deepNavy),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'අවශ්‍යතා / ගැටලුව:',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            issue,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13.5, color: AppColors.navyDark, height: 1.35, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Date & Location Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.deepNavy),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                date,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppColors.navyDark, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.deepNavy),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['address'] ?? 'ලිපිනය නොමැත',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Review Summary display if review exists
                                if (status == 'completed' && item['review'] != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFBEB),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              children: List.generate(
                                                5,
                                                (starIdx) => Icon(
                                                  starIdx < (item['review']['rating'] ?? 5) ? Icons.star_rounded : Icons.star_border_rounded,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${item['review']['rating']}.0 Rating',
                                              style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        if (item['review']['comment'] != null && item['review']['comment'].toString().trim().isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '"${item['review']['comment']}"',
                                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF78350F)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Bottom Actions Row (Call Button / Review Button / Details Button)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceBg,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(22),
                                bottomRight: Radius.circular(22),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Action 1: If Accepted, Call Baas Button
                                if (status == 'accepted') ...[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _makePhoneCall(providerPhone),
                                      icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 16),
                                      label: const Text(
                                        'බාස්ව අමතන්න',
                                        style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.successGreen,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],

                                // Action 2: If Completed & No Review yet, Add Review Button
                                if (status == 'completed' && item['review'] == null) ...[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openRatingDialog(item),
                                      icon: const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 18),
                                      label: const Text(
                                        'Rating & Review එකතු කරන්න',
                                        style: TextStyle(color: AppColors.deepNavy, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFFBEB),
                                        elevation: 0,
                                        side: BorderSide(color: AppColors.warningAmber.withValues(alpha: 0.4)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],

                                // Action 3: View Full Details Button
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showBookingDetailsDialog(item),
                                    icon: const Icon(Icons.info_outline_rounded, color: AppColors.deepNavy, size: 16),
                                    label: const Text(
                                      'විස්තර බලන්න',
                                      style: TextStyle(color: AppColors.deepNavy, fontSize: 12.5, fontWeight: FontWeight.bold),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.deepNavy, width: 1.2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showBookingDetailsDialog(Map<String, dynamic> booking) {
    final status = (booking['status'] ?? 'pending').toString().toLowerCase();
    final providerName = booking['provider_name'] ?? booking['provider']?['full_name'] ?? 'සේවා සපයන්නා';
    final providerPhone = booking['provider_phone'] ?? booking['provider']?['phone'] ?? 'නොමැත';
    final providerImgStr = (booking['provider_image_url'] ?? (booking['provider'] != null ? booking['provider']['profile_image_url'] : '') ?? '').toString();
    final provImgProvider = _getImageProvider(providerImgStr);
    final issue = booking['issue'] ?? 'විස්තර සඳහන් කර නැත';
    final address = booking['address'] ?? 'ලිපිනය නොමැත';
    final date = booking['service_date'] ?? 'දිනය නොමැත';
    final createdAt = booking['created_at'] != null ? booking['created_at'].toString().split('T')[0] : '';

    Color statusColor = AppColors.warningAmber;
    String statusText = 'රැඳී සිටින (Pending)';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (status == 'accepted') {
      statusColor = AppColors.deepNavy;
      statusText = 'භාරගන්නා ලදී (Accepted)';
      statusIcon = Icons.thumb_up_alt_rounded;
    } else if (status == 'completed') {
      statusColor = AppColors.successGreen;
      statusText = 'අවසන් (Completed)';
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'cancelled') {
      statusColor = AppColors.errorRed;
      statusText = 'අවලංගුයි (Cancelled)';
      statusIcon = Icons.cancel_rounded;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.navyDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'වෙන්කිරීමේ විස්තර',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Booking Details Summary',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                onPressed: () => Navigator.pop(ctx),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.92,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('වර්තමාන තත්ත්වය (Status):', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Provider Info Section Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('තෝරාගත් සේවා සපයන්නා (Baas Provider):', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.25), width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.navySubtle,
                              backgroundImage: provImgProvider,
                              child: provImgProvider == null
                                  ? Text(
                                      providerName.isNotEmpty ? providerName[0].toUpperCase() : 'P',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.deepNavy),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navyDark),
                                ),
                                if (providerPhone != 'නොමැත') ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '📞 $providerPhone',
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (providerPhone != 'නොමැත')
                            IconButton.filledTonal(
                              icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.successGreen, size: 20),
                              onPressed: () => _makePhoneCall(providerPhone),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFECFDF5),
                              ),
                              tooltip: 'ඇමතුමක් ගන්න',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Booking Requirements & Details Section
                const Text('වෙන්කිරීමේ තොරතුරු (Details):', style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(Icons.handyman_rounded, 'අවශ්‍යතාව / ගැටලුව', issue),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),
                      _buildDetailItem(Icons.calendar_month_rounded, 'සේවා දිනය', date),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),
                      _buildDetailItem(Icons.location_on_rounded, 'සේවා ස්ථානය / ලිපිනය', address),
                      if (createdAt.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        _buildDetailItem(Icons.access_time_rounded, 'ඉල්ලීම යැවූ දිනය', createdAt),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              if (status == 'pending')
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _cancelBooking(booking['id'] ?? booking['_id']);
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.errorRed),
                    label: const Text('අවලංගු කරන්න', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (status == 'pending') const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('හරි (Close)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.deepNavy),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, color: AppColors.navyDark, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _openRatingDialog(Map<String, dynamic> booking) {
    int rating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    final suggestions = [
      'ඉක්මන් සේවාව ⚡',
      'විශ්වාසවන්තයි 🛡️',
      'සාධාරණ මිළ 💰',
      'විශිෂ්ට නිමාව 🛠️',
      'සුහදශීලීයි 😊',
      'නියමිත වෙලාවට ආවා ⏰',
    ];

    String getRatingLabel(int r) {
      switch (r) {
        case 5:
          return 'ඉතාමත් හොඳයි! ⭐⭐⭐⭐⭐';
        case 4:
          return 'හොඳයි ⭐⭐⭐⭐';
        case 3:
          return 'සාමාන්‍යයි ⭐⭐⭐';
        case 2:
          return 'වැඩිදියුණු විය යුතුයි ⭐⭐';
        case 1:
          return 'අසන්තෝෂදායකයි ⭐';
        default:
          return '';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.navyDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'සමාලෝචනය සහ ශ්‍රේණිගත කිරීම',
                          style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rate & Review Your Service',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.pop(dialogCtx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.92,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Provider Name Summary
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.handyman_rounded, color: AppColors.deepNavy, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ලද සේවාව: ${booking['issue'] ?? 'සේවාව'}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Center(
                      child: Text(
                        'ඔබ ලබාදුන් ශ්‍රේණිගත කිරීම (Rating):',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Interactive 5 Star Rating Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              rating = starVal;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Icon(
                              starVal <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 34,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          getRatingLabel(rating),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Suggestions Title
                    const Text(
                      'ක්ෂණික අදහස් තේරීම් (Quick Suggestions):',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((chipText) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              if (commentController.text.isEmpty) {
                                commentController.text = chipText;
                              } else {
                                if (!commentController.text.contains(chipText)) {
                                  commentController.text = '${commentController.text.trim()}, $chipText';
                                }
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: commentController.text.contains(chipText) ? AppColors.navySubtle : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: commentController.text.contains(chipText) ? AppColors.deepNavy : AppColors.cardBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              chipText,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: commentController.text.contains(chipText) ? AppColors.deepNavy : AppColors.textDark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Comment Input Field
                    const Text(
                      'ඔබේ අදහස / අත්දැකීම (Review):',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.navyDark),
                      decoration: InputDecoration(
                        hintText: 'අදහස් මෙතන සටහන් කරන්න...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.deepNavy, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('අවලංගුයි', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setDialogState(() => isSubmitting = true);
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String customerId = prefs.getString('user_id') ?? '';
                              String bookingId = (booking['id'] ?? booking['_id'] ?? '').toString();
                              String providerId = (booking['provider_id'] ?? booking['provider']?['id'] ?? '').toString();

                              final result = await ApiService.submitReview(
                                bookingId: bookingId,
                                customerId: customerId,
                                providerId: providerId,
                                rating: rating,
                                comment: commentController.text.trim(),
                              );

                              if (dialogCtx.mounted) Navigator.pop(dialogCtx);

                              if (result['success'] == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'ඔබේ සමාලෝචනය සාර්ථකව ඇතුළත් කරන ලදී! 🌟'),
                                    backgroundColor: AppColors.successGreen,
                                  ),
                                );
                                _loadCustomerBookings();
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'සමාලෝචනය ඇතුළත් කිරීමට නොහැකි විය. නැවත උත්සාහ කරන්න.'),
                                    backgroundColor: AppColors.errorRed,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('ලබාදෙන්න', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _cancelBooking(dynamic bookingId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('වෙන්කිරීම අවලංගු කිරීම', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyDark)),
        content: const Text('ඔබට මෙම සේවා වෙන්කිරීම අවලංගු කිරීමට අවශ්‍ය බව තහවුරු කරන්න.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('නැත', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('ඔව්, අවලංගු කරන්න', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await ApiService.cancelBooking(bookingId.toString());
      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'වෙන්කිරීම සාර්ථකව අවලංගු කරන ලදී.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _loadCustomerBookings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'අවලංගු කිරීමට නොහැකි විය. නැවත උත්සාහ කරන්න.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}
