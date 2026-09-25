import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'provider_jobs_screen.dart';
import 'provider_messages_screen.dart';
import 'provider_profile_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final GlobalKey<ProviderJobsScreenState> _jobsKey = GlobalKey<ProviderJobsScreenState>();
  final GlobalKey<ProviderMessagesScreenState> _messagesKey = GlobalKey<ProviderMessagesScreenState>();
  int _selectedIndex = 0;
  Future<List<dynamic>>? _bookingsFuture;
  
  String _providerName = '';
  String _profileImageUrl = '';
  double _avgRating = 0.0;
  int _totalReviews = 0;
  bool _isOnline = true;
  int _acceptedJobsCount = 0;

  bool _isVerified = false;
  String _verificationStatus = 'Pending';
  String _rejectionReason = '';

  @override
  void initState() {
    super.initState();
    _loadProviderInfo();
    _loadBookings();
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
    if (cleanPhone.isEmpty || cleanPhone == 'නොමැත') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('දුරකථන අංකය සපයා නොමැත.')),
        );
      }
      return;
    }
    final Uri launchUri = Uri.parse('tel:$cleanPhone');
    try {
      final launched = await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('දුරකථන අංකය: $phoneNumber')),
        );
      }
    } catch (e) {
      debugPrint("Could not launch phone call: $e");
    }
  }

  void _loadProviderInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('full_name') ?? 'සේවා සපයන්නා';
    String providerId = prefs.getString('user_id') ?? '';
    String savedImage = prefs.getString('profile_image_url') ?? '';

    if (providerId.isNotEmpty) {
      NotificationService().syncFcmToken(userId: providerId).catchError((_) {});
    }

    setState(() {
      _providerName = name;
      _profileImageUrl = savedImage;
    });

    if (providerId.isNotEmpty) {
      final myJobs = await ApiService.getMyJobs(providerId);
      final details = await ApiService.getProviderDetails(providerId);
      final reviewsRes = await ApiService.getProviderReviews(providerId);
      if (mounted) {
        setState(() {
          _acceptedJobsCount = myJobs.length;
          _avgRating = (reviewsRes['average_rating'] ?? 0.0).toDouble();
          _totalReviews = reviewsRes['total_reviews'] ?? 0;
          if (details != null) {
            _isVerified = details['is_verified'] ?? false;
            _verificationStatus = details['verification_status'] ?? (details['is_verified'] == true ? 'Approved' : 'Pending');
            _rejectionReason = details['rejection_reason'] ?? '';
            if (details['profile_image_url'] != null && details['profile_image_url'].toString().isNotEmpty) {
              _profileImageUrl = details['profile_image_url'];
            }
          }
        });
      }
    }
  }

  void _loadBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? providerId = prefs.getString('user_id');

    if (providerId != null) {
      setState(() {
        _bookingsFuture = ApiService.getProviderBookings(providerId);
      });
      _jobsKey.currentState?.reloadJobs();
    }
  }

  Future<void> _handleRefresh() async {
    _loadProviderInfo();
    _loadBookings();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Widget _buildVerificationBanner() {
    if (_verificationStatus == 'Rejected') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.errorRed.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gpp_bad_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ගිණුම් ඉල්ලීම ප්‍රතික්ෂේප කර ඇත',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verification Status: Rejected',
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ප්‍රතික්ෂේප කිරීමට හේතුව:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rejectionReason.isNotEmpty ? _rejectionReason : 'ලියකියවිලි හෝ NIC ඡායාරූප තහවුරු කිරීමට නොහැකි විය.',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textDark, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (!_isVerified || _verificationStatus == 'Pending') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.warningAmber.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFB45309), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ගිණුම් අනුමැතිය (Pending Approval)',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ඔබගේ ගිණුම සක්‍රිය කිරීම සඳහා Admin අනුමැතිය ලැබෙන තෙක් රැඳී සිටින්න.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.navyDark, Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'වෘත්තීය සේවා විශිෂ්ටත්වය',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ගුණාත්මක සේවාවක් සපයා පාරිභෝගිකයින්ගෙන් 5-Star Ratings ලබා ගන්න.',
                    style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.deepNavy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Banner Card with Gradient & Glassmorphism
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navyDark, Color(0xFF0F2642), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2A00192C),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF10B981),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Flexible(
                                  child: Text(
                                    'අපේ බාස් Pro Portal',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Online / Offline Duty Status Toggle Switch
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isOnline = !_isOnline;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isOnline ? '🟢 ඔබ සේවයේ නිරතයි (Online)' : '🔴 ඔබ විවේකයේ පසුවේ (Offline)'),
                                backgroundColor: _isOnline ? AppColors.successGreen : AppColors.navyDark,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isOnline ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isOnline ? const Color(0xFF10B981).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isOnline ? const Color(0xFF10B981) : Colors.amber,
                                    shape: BoxShape.circle,
                                    boxShadow: _isOnline
                                        ? [const BoxShadow(color: Color(0xFF10B981), blurRadius: 6, spreadRadius: 1)]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isOnline ? 'සේවයේ (Online)' : 'විවේකයේ',
                                  style: TextStyle(
                                    color: _isOnline ? const Color(0xFF10B981) : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _providerName.isNotEmpty ? _providerName : 'සේවා සපයන්නා',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  if (_isVerified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 22),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          _avgRating.toStringAsFixed(1),
                                          style: const TextStyle(color: Colors.amber, fontSize: 12.5, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '($_totalReviews Reviews)',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _isVerified
                                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                      : [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.2)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.navyLight,
                                backgroundImage: _getImageProvider(_profileImageUrl),
                                child: _getImageProvider(_profileImageUrl) == null
                                    ? Text(
                                        _providerName.isNotEmpty ? _providerName[0].toUpperCase() : 'P',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                      )
                                    : null,
                              ),
                            ),
                            if (_isVerified)
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF10B981),
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Verification Status Notification Card (Approved / Pending / Rejected)
            _buildVerificationBanner(),

            const SizedBox(height: 20),

            // Overview Dashboard Stats Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'කාර්ය සාධන සාරාංශය (Overview)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.navySubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'සජීවී දත්ත',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'භාරගත් වැඩ',
                          value: '$_acceptedJobsCount',
                          subtitle: 'ලබාදුන් සේවා',
                          icon: Icons.task_alt_rounded,
                          color: AppColors.successGreen,
                          bgColor: const Color(0xFFECFDF5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'අද ආදායම',
                          value: 'රු. 0',
                          subtitle: 'ලද ගෙවීම්',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.deepNavy,
                          bgColor: AppColors.navySubtle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'ශ්‍රේණිගත කිරීම',
                          value: '⭐ ${_avgRating.toStringAsFixed(1)}',
                          subtitle: '($_totalReviews ලැබුණු අදහස්)',
                          icon: Icons.star_rounded,
                          color: Colors.amber.shade800,
                          bgColor: const Color(0xFFFFFBEB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'සේවා තත්ත්වය',
                          value: _isOnline ? 'සක්‍රියයි' : 'විවේකයේ',
                          subtitle: _isOnline ? 'ඉල්ලීම් භාරගත හැක' : 'තාවකාලිකව නවතා ඇත',
                          icon: Icons.sensors_rounded,
                          color: _isOnline ? const Color(0xFF10B981) : Colors.grey.shade700,
                          bgColor: _isOnline ? const Color(0xFFECFDF5) : Colors.grey.shade100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Pro Service Excellence Hero Banner Card
            _buildProHeroBanner(),

            const SizedBox(height: 14),

            // New Requests Section Header (Wrapped in Row with Expanded title)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'නව සේවා ඉල්ලීම් (New Requests)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navySubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'සක්‍රිය',
                      style: TextStyle(color: AppColors.deepNavy, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // FutureBuilder for Bookings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<List<dynamic>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.deepNavy)),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline_rounded, color: AppColors.errorRed),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'දත්ත ලබා ගැනීමේ ගැටළුවක්! කරුණාකර නැවත උත්සාහ කරන්න.',
                              style: TextStyle(color: AppColors.errorRed, fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(color: AppColors.deepNavy.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: AppColors.navySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inbox_rounded, size: 42, color: AppColors.deepNavy),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'දැනට නව ඉල්ලීම් නොමැත',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'පාරිභෝගිකයින් සේවා ඉල්ලූ වහාම මෙහි පෙන්වනු ඇත.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final bookings = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return GestureDetector(
                        onTap: () => _showRequestDetailsDialog(booking),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepNavy.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.navySubtle,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.handyman_rounded, color: AppColors.deepNavy, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking['issue'] ?? 'ගැටළුව සඳහන් කර නැත',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.navyLight),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                booking['address'] ?? 'ලිපිනය නොමැත',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.navyAccent),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            booking['service_date'] ?? 'දිනය නොමැත',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _showRequestDetailsDialog(booking),
                                    icon: const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.deepNavy),
                                    label: const Text('විස්තර', style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.deepNavy, width: 1.2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.emeraldGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.successGreen.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await ApiService.acceptBooking(booking['id'].toString());

                                        if (!context.mounted) return;
                                        if (result['success']) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(result['message']), backgroundColor: AppColors.successGreen),
                                          );
                                          _loadBookings();
                                          _loadProviderInfo();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(result['message']), backgroundColor: AppColors.errorRed),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                                      label: const Text('භාරගන්න', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  void _showRequestDetailsDialog(Map<String, dynamic> booking) {
    final customerName = booking['customer_name'] ?? booking['customer']?['full_name'] ?? 'පාරිභෝගිකයා';
    final customerPhone = booking['customer_phone'] ?? booking['customer']?['phone'] ?? 'නොමැත';
    final customerImgStr = (booking['customer_image_url'] ?? (booking['customer'] != null ? booking['customer']['profile_image_url'] : '') ?? '').toString();
    final custImgProvider = _getImageProvider(customerImgStr);
    final issue = booking['issue'] ?? 'විස්තර සඳහන් කර නැත';
    final address = booking['address'] ?? 'ලිපිනය නොමැත';
    final date = booking['service_date'] ?? 'දිනය නොමැත';
    final createdAt = booking['created_at'] != null ? booking['created_at'].toString().split('T')[0] : '';
    final bookingId = (booking['id'] ?? '').toString();

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
                child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'නව සේවා ඉල්ලීමේ විස්තර',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'New Service Request Summary',
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
                // Customer Info Card
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
                      const Text('පාරිභෝගිකයාගේ විස්තර (Customer Info):', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.navySubtle,
                            backgroundImage: custImgProvider,
                            child: custImgProvider == null
                                ? Text(
                                    customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.deepNavy),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: AppColors.navyDark),
                                ),
                                if (customerPhone.isNotEmpty && customerPhone != 'නොමැත') ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '📞 $customerPhone',
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (customerPhone.isNotEmpty && customerPhone != 'නොමැත')
                            IconButton.filledTonal(
                              icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.successGreen, size: 20),
                              onPressed: () => _makePhoneCall(customerPhone),
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

                // Request Details Section Card
                const Text('ඉල්ලීමේ සම්පූර්ණ විස්තර (Service Details):', style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
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
                      _buildDetailItem(Icons.calendar_month_rounded, 'සේවාව අවශ්‍ය දිනය', date),
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
                        _buildDetailItem(Icons.access_time_rounded, 'ඉල්ලීම ලැබුණු දිනය', createdAt),
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
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('වහන්න (Close)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final result = await ApiService.acceptBooking(bookingId);
                    if (!context.mounted) return;
                    if (result['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message']), backgroundColor: AppColors.successGreen),
                      );
                      _loadBookings();
                      _loadProviderInfo();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message']), backgroundColor: AppColors.errorRed),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                  label: const Text('වැඩේ භාරගන්න', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
        Icon(icon, size: 17, color: AppColors.deepNavy),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 13.5, color: AppColors.navyDark, fontWeight: FontWeight.w600, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceBg,
        appBar: _selectedIndex == 0
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.navyDark,
                elevation: 0,
                title: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 32),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'අපේ බාස් Provider',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                actions: [
                  ValueListenableBuilder<int>(
                    valueListenable: NotificationService.unreadCountNotifier,
                    builder: (context, unreadCount, child) {
                      return IconButton(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 23),
                            if (unreadCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen(role: 'provider')),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              )
            : null,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),
            ProviderJobsScreen(key: _jobsKey),
            ProviderMessagesScreen(key: _messagesKey),
            const SettingsScreen(isProvider: true),
          ],
        ),

        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 4 : 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              activeIcon: Icons.dashboard_rounded,
              inactiveIcon: Icons.dashboard_outlined,
              label: 'ඩෑෂ්බෝඩ්',
            ),
            _buildNavItem(
              index: 1,
              activeIcon: Icons.assignment_turned_in_rounded,
              inactiveIcon: Icons.assignment_turned_in_outlined,
              label: 'මගේ වැඩ',
            ),
            _buildNavItem(
              index: 2,
              activeIcon: Icons.chat_bubble_rounded,
              inactiveIcon: Icons.chat_bubble_outline_rounded,
              label: 'පණිවිඩ',
            ),
            _buildNavItem(
              index: 3,
              activeIcon: Icons.settings_rounded,
              inactiveIcon: Icons.settings_outlined,
              label: 'සැකසුම්',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          _jobsKey.currentState?.reloadJobs();
        } else if (index == 2) {
          _messagesKey.currentState?.reloadConversations();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? const Color(0xFFFFC107) : Colors.white60,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}