import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  double _avgRating = 0.0;
  int _totalReviews = 0;
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;
  Map<String, dynamic>? _fetchedProviderDetails;

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

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _fetchProviderDetails();
  }

  void _fetchProviderDetails() async {
    final providerId = widget.provider['id'] ?? widget.provider['user_id'] ?? widget.provider['provider_id'];
    if (providerId != null) {
      final details = await ApiService.getProviderDetails(providerId.toString());
      if (details != null && mounted) {
        setState(() {
          _fetchedProviderDetails = details;
        });
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('දුරකථන අංකය: $phoneNumber')),
        );
      }
    }
  }

  void _fetchReviews() async {
    final providerId = widget.provider['id'] ?? widget.provider['user_id'] ?? widget.provider['provider_id'];
    if (providerId != null) {
      final res = await ApiService.getProviderReviews(providerId.toString());
      if (mounted) {
        setState(() {
          _avgRating = (res['average_rating'] as num?)?.toDouble() ?? 0.0;
          _totalReviews = res['total_reviews'] ?? 0;
          _reviews = res['reviews'] ?? [];
          _isLoadingReviews = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  String _formatCategoriesInSinhala(String categoryStr) {
    if (categoryStr.isEmpty || categoryStr == 'සඳහන් කර නැත') return 'සඳහන් කර නැත';
    final parts = categoryStr.split(',').map((s) => s.trim()).toList();

    final Map<String, String> translationMap = {
      'Masonry': 'මේසන් වැඩ (Masonry)',
      'Carpentry': 'වඩු වැඩ (Carpentry)',
      'Plumbing': 'ජලනල වැඩ (Plumbing)',
      'Electrical Work': 'විදුලි වැඩ (Electrical Work)',
      'Painting': 'තීන්ත ගෑමේ වැඩ (Painting)',
      'Tiling': 'ටයිල් ඇල්ලීමේ වැඩ (Tiling)',
      'Welding': 'පෑස්සුම් වැඩ (Welding)',
      'Aluminum Fabrication': 'ඇලුමිනියම් වැඩ (Aluminum)',
      'Roofing': 'වහල සෙවිලි කිරීම (Roofing)',
      'A/C Repair': 'වායු සමීකරණ අලුත්වැඩියාව (A/C)',
      'Landscaping': 'ගෙවතු අලංකරණය (Landscaping)',
      'Ceiling Installation': 'සිවිලිම් ගැසීම (Ceiling)',
      'Cleaning Services': 'පවිත්ර කිරීමේ සේවා (Cleaning)',
      'Appliance Repair': 'ගෘහ උපකරණ අලුත්වැඩියාව',
      'Solar Panel Installation': 'සූර්ය පැනල (Solar)',
      'CCTV & Security Systems': 'CCTV පද්ධති (Security)',
    };

    return parts.map((p) => translationMap[p] ?? p).join(', ');
  }

  String _getPrimarySinhalaCategory(String categoryStr) {
    if (categoryStr.isEmpty || categoryStr == 'සඳහන් කර නැත') return 'සඳහන් කර නැත';
    final firstPart = categoryStr.split(',').first.trim();
    final Map<String, String> translationMap = {
      'Masonry': 'මේසන් වැඩ',
      'Carpentry': 'වඩු වැඩ',
      'Plumbing': 'ජලනල වැඩ',
      'Electrical Work': 'විදුලි වැඩ',
      'Painting': 'තීන්ත ගෑමේ වැඩ',
      'Tiling': 'ටයිල් ඇල්ලීම',
      'Welding': 'පෑස්සුම් වැඩ',
      'Aluminum Fabrication': 'ඇලුමිනියම් වැඩ',
      'Roofing': 'වහල වැඩ',
      'A/C Repair': 'A/C අලුත්වැඩියාව',
      'Landscaping': 'ගෙවතු අලංකරණය',
    };
    return translationMap[firstPart] ?? firstPart;
  }

  Map<String, dynamic> _getCategoryItemData(String rawCat) {
    final clean = rawCat.trim();
    final lower = clean.toLowerCase();

    String titleSi = clean;
    String titleEn = clean;
    IconData icon = Icons.handyman_rounded;

    if (lower.contains('mason')) {
      titleSi = 'මේසන් සහ ගොඩනැගිලි වැඩ';
      titleEn = 'Masonry & Construction';
      icon = Icons.foundation_rounded;
    } else if (lower.contains('carpent') || lower.contains('wood')) {
      titleSi = 'වඩු කාර්මික සේවා';
      titleEn = 'Carpentry & Woodwork';
      icon = Icons.handyman_rounded;
    } else if (lower.contains('plumb') || lower.contains('water')) {
      titleSi = 'නළ එළීමේ සහ ජලනල සේවා';
      titleEn = 'Plumbing & Water Lines';
      icon = Icons.plumbing_rounded;
    } else if (lower.contains('electr') || lower.contains('zap')) {
      titleSi = 'විදුලි කාර්මික සේවා';
      titleEn = 'Electrician Services';
      icon = Icons.electrical_services_rounded;
    } else if (lower.contains('paint')) {
      titleSi = 'තීන්ත ආලේපන සේවා';
      titleEn = 'House Painting';
      icon = Icons.format_paint_rounded;
    } else if (lower.contains('tile') || lower.contains('floor')) {
      titleSi = 'ටයිල් එළීම සහ පොළොව සැකසීම';
      titleEn = 'Tile Laying & Flooring';
      icon = Icons.grid_on_rounded;
    } else if (lower.contains('weld') || lower.contains('flame')) {
      titleSi = 'පෑස්සුම් සහ ලෝහ වැඩ';
      titleEn = 'Welding & Metal Fabrication';
      icon = Icons.precision_manufacturing_rounded;
    } else if (lower.contains('alum')) {
      titleSi = 'ඇලුමිනියම් සේවා';
      titleEn = 'Aluminum Fabrication';
      icon = Icons.door_sliding_rounded;
    } else if (lower.contains('roof')) {
      titleSi = 'වහල සෙවිලි කිරීම සහ අලුත්වැඩියාව';
      titleEn = 'Roofing & Ceiling Work';
      icon = Icons.roofing_rounded;
    } else if (lower.contains('ac') || lower.contains('air') || lower.contains('cool')) {
      titleSi = 'ඒසී (A/C) අලුත්වැඩියාව සහ නඩත්තුව';
      titleEn = 'AC Repair & Service';
      icon = Icons.ac_unit_rounded;
    } else if (lower.contains('garden') || lower.contains('landscap')) {
      titleSi = 'ගෙවතු අලංකරණය සහ නඩත්තුව';
      titleEn = 'Gardening & Landscaping';
      icon = Icons.park_rounded;
    } else if (lower.contains('clean')) {
      titleSi = 'පිරිසිදු කිරීමේ සේවා';
      titleEn = 'House Deep Cleaning';
      icon = Icons.cleaning_services_rounded;
    } else if (lower.contains('solar') || lower.contains('sun')) {
      titleSi = 'සූර්ය පැනල (Solar) සවිකිරීම';
      titleEn = 'Solar Panel Installation';
      icon = Icons.wb_sunny_rounded;
    } else if (lower.contains('cctv') || lower.contains('secur')) {
      titleSi = 'CCTV සහ ආරක්ෂිත පද්ධති';
      titleEn = 'CCTV & Security Systems';
      icon = Icons.videocam_rounded;
    } else if (lower.contains('appliance')) {
      titleSi = 'ගෘහ උපකරණ අලුත්වැඩියාව';
      titleEn = 'Appliance Repair';
      icon = Icons.home_repair_service_rounded;
    }

    return {
      'titleSi': titleSi,
      'titleEn': titleEn,
      'icon': icon,
    };
  }

  void _showCategoriesDialog(String categoryStr) {
    if (categoryStr.isEmpty || categoryStr == 'සඳහන් කර නැත') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('සේවා කාණ්ඩයන් ඇතුළත් කර නොමැත.')),
      );
      return;
    }

    final categoryList = categoryStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header Box
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.navySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handyman_rounded, color: AppColors.deepNavy, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ලබාදෙන සියලුම සේවාවන්',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'මෙම සේවා සපයන්නා විසින් ලබාදෙන සේවා ${categoryList.length} ක්',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFEEF2F6)),
              ),

              // Service Cards List
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categoryList.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final itemData = _getCategoryItemData(categoryList[idx]);
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.navySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              itemData['icon'] as IconData,
                              color: AppColors.deepNavy,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemData['titleSi'].toString(),
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  itemData['titleEn'].toString(),
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle_rounded, size: 13, color: AppColors.successGreen),
                                SizedBox(width: 4),
                                Text(
                                  'ලබාදේ',
                                  style: TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'තේරුණා (Close)',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageUrl.startsWith('data:image')
                    ? Image.memory(Uri.parse(imageUrl).data!.contentAsBytes(), fit: BoxFit.contain)
                    : Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = {
      ...widget.provider,
      ...(_fetchedProviderDetails ?? {}),
    };
    final fullName = provider['full_name'] ?? provider['name'] ?? 'සේවා සපයන්නා';
    final email = provider['email'] ?? 'නොමැත';
    final phone = provider['phone'] ?? 'නොමැත';
    final category = provider['service_category'] ?? 'සඳහන් කර නැත';
    final nic = provider['nic_number'] ?? 'සඳහන් කර නැත';
    final experience = provider['experience_years'] ?? 0;
    final radius = provider['working_radius_km'] ?? 0;
    final isVerified = provider['is_verified'] ?? false;
    final address = provider['address'] ?? 'සඳහන් කර නැත';
    final List portfolioImages = provider['portfolio_images'] is List ? provider['portfolio_images'] : [];
    final profileImageUrl = (provider['profile_image_url'] ?? provider['profile_image'] ?? provider['profile_picture'] ?? provider['avatar'] ?? '').toString();
    final imgProvider = _getImageProvider(profileImageUrl);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text(
          'සේවා සපයන්නාගේ විස්තර',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Profile Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Solid Navy Banner
                  Container(
                    width: double.infinity,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.navyDark,
                    ),
                  ),

                  // Avatar Overlapping Banner
                  Transform.translate(
                    offset: const Offset(0, -45),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isVerified
                                      ? AppColors.successGreen
                                      : AppColors.navyDark,
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: AppColors.navySubtle,
                                  backgroundImage: imgProvider,
                                  child: imgProvider == null
                                      ? Text(
                                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P',
                                          style: const TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.deepNavy,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (isVerified)
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 24),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),

                        // Ratings & Verified Status Badges under Provider Name
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            // Rating Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    _avgRating > 0 ? _avgRating.toStringAsFixed(1) : 'අලුත්',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '($_totalReviews)',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                                  ),
                                ],
                              ),
                            ),
                            // Verification Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isVerified ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.warningAmber.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                                    size: 14,
                                    color: isVerified ? AppColors.successGreen : AppColors.warningAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isVerified ? 'Verified Baas' : 'Pending Verification',
                                    style: TextStyle(
                                      color: isVerified ? AppColors.successGreen : const Color(0xFF92400E),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Highlights Stats Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'අත්දැකීම්',
                            value: 'වසර $experience',
                            icon: Icons.workspace_premium_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'සේවා කාණ්ඩය',
                            value: _getPrimarySinhalaCategory(category),
                            icon: Icons.category_rounded,
                            onTap: () => _showCategoriesDialog(category),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'සේවා සීමාව',
                            value: 'කි.මී. $radius',
                            icon: Icons.location_on_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Professional Details Section Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'වෘත්තීය සහ සම්බන්ධතා විස්තර',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                    ),
                    _buildInfoTile(
                      icon: Icons.category_outlined,
                      title: 'සේවා කාණ්ඩය (Category)',
                      value: _formatCategoriesInSinhala(category),
                      onTap: () => _showCategoriesDialog(category),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      icon: Icons.phone_android_outlined,
                      title: 'දුරකථන අංකය',
                      value: phone,
                      onTap: () => _makePhoneCall(phone),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'ලිපිනය',
                      value: address,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Work Portfolio / Past Work Gallery Section
            if (portfolioImages.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepNavy.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_library_outlined, color: AppColors.navyDark, size: 22),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'කරන ලද වැඩවල ඡායාරූප (Work Gallery)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.navySubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${portfolioImages.length} Photos',
                              style: const TextStyle(fontSize: 11, color: AppColors.deepNavy, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: portfolioImages.length,
                          separatorBuilder: (ctx, idx) => const SizedBox(width: 12),
                          itemBuilder: (ctx, idx) {
                            final imgUrl = portfolioImages[idx].toString();
                            return GestureDetector(
                              onTap: () => _openImagePreview(context, imgUrl),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: imgUrl.startsWith('data:image')
                                      ? Image.memory(
                                          Uri.parse(imgUrl).data!.contentAsBytes(),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => const Center(
                                            child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Ratings & Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'පාරිභෝගික සමාලෝචන & Ratings',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_avgRating.toStringAsFixed(1)} / 5.0 ($_totalReviews)',
                                style: const TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                    ),

                    if (_isLoadingReviews)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(color: AppColors.deepNavy)),
                      )
                    else if (_reviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: const [
                              Icon(Icons.rate_review_outlined, size: 36, color: AppColors.textMuted),
                              SizedBox(height: 8),
                              Text('තවම පාරිභෝගික සමාලෝචන ලැබී නැත.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFEEF2F6)),
                        itemBuilder: (context, index) {
                          final r = _reviews[index];
                          final customerProfile = r['profiles'];
                          final cName = customerProfile != null ? customerProfile['full_name'] ?? 'පාරිභෝගිකයා' : 'පාරිභෝගිකයා';
                          final String cImage = customerProfile != null ? customerProfile['profile_image_url'] ?? '' : '';
                          final int rRating = r['rating'] ?? 5;
                          final String rComment = r['comment'] ?? '';
                          final String rDate = r['created_at'] != null ? r['created_at'].toString().split('T')[0] : '';
                          final cAvatar = _getImageProvider(cImage);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.navySubtle,
                                    backgroundImage: cAvatar,
                                    child: cAvatar == null
                                        ? Text(
                                            cName.isNotEmpty ? cName[0].toUpperCase() : 'C',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                        Text(rDate, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIdx) => Icon(
                                        starIdx < rRating ? Icons.star_rounded : Icons.star_border_rounded,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (rComment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 46),
                                  child: Text(
                                    rComment,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.3),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 6 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverId: provider['id'] ?? '',
                      receiverName: fullName,
                      receiverPhone: phone,
                      receiverImage: profileImageUrl,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.deepNavy, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.navySubtle,
                fixedSize: const Size(48, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              tooltip: 'පණිවිඩ යවන්න (Chat)',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(phone),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.successGreen, size: 18),
                  label: const Text(
                    'ඇමතුමක්',
                    style: TextStyle(color: AppColors.successGreen, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.successGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(provider: provider),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'වෙන් කරන්න',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyDark,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.navySubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navyLight.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.deepNavy, size: 20),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.navySubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.deepNavy, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(
                  value.isNotEmpty ? value : 'සඳහන් කර නැත',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
