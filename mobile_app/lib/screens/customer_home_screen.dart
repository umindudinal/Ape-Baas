import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'provider_list_screen.dart';
import 'customer_profile_screen.dart';
import 'all_providers_screen.dart';
import 'provider_details_screen.dart';
import 'settings_screen.dart';
import 'customer_messages_screen.dart';
import 'customer_bookings_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  String _customerName = 'පාරිභෝගිකයා';
  String _profileImageUrl = '';
  String _customerLocation = 'ශ්‍රී ලංකාව';
  final GlobalKey<CustomerBookingsScreenState> _bookingsKey = GlobalKey<CustomerBookingsScreenState>();
  
  Future<List<dynamic>>? _topProvidersFuture;

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

  List<Map<String, dynamic>> get _promoBanners => [
    {
      'title': '100% සහතිකලත් වෘත්තීය බාස්ලා',
      'subtitle': 'ඔබගේ ප්‍රදේශයේම අත්දැකීම් සහිත නිපුණ සේවා සපයන්නන් විශ්වාසයෙන් තෝරාගන්න',
      'tag': '🛡️ VERIFIED PRO BAASES',
      'buttonText': 'හොඳම බාස් තෝරන්න',
      'buttonBg': const Color(0xFFFFC107),
      'buttonTextColor': const Color(0xFF001730),
      'icon': Icons.verified_user_rounded,
      'gradient': const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': '24/7 ක්ෂණික හදිසි අලුත්වැඩියා',
      'subtitle': 'විදුලි, ජලනල, A/C හා මේසන් හදිසි දෝෂ සඳහා විනාඩි 30න් කඩිනම් සහාය',
      'tag': '⚡ 24/7 EMERGENCY REPAIRS',
      'buttonText': 'දැන්ම ඉල්ලුම් කරන්න',
      'buttonBg': Colors.white,
      'buttonTextColor': const Color(0xFF065F46),
      'icon': Icons.flash_on_rounded,
      'gradient': const LinearGradient(
        colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'විශ්වාසනීය සහ සුරක්ෂිත සේවාව',
      'subtitle': 'පාරිභෝගික 5-Star Ratings & Reviews පරික්ෂා කර හොඳම සේවාව ලබාගන්න',
      'tag': '⭐ TOP RATED EXPERTS',
      'buttonText': 'සේවා සියල්ල බලන්න',
      'buttonBg': const Color(0xFFFFC107),
      'buttonTextColor': const Color(0xFF1E1B4B),
      'icon': Icons.stars_rounded,
      'gradient': const LinearGradient(
        colors: [Color(0xFF311B92), Color(0xFF4A148C), Color(0xFF7B1FA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'සාධාරණ සහ විනිවිදභාවයෙන් යුතු ගාස්තු',
      'subtitle': 'අමතර රහස් ගාස්තු නැත, ඔබගේ නිවාස සේවා සඳහා සරල හා සාධාරණ අය කිරීම් පමණි',
      'tag': '🏷️ BEST PRICE GUARANTEE',
      'buttonText': 'බාස්ලා සොයන්න',
      'buttonBg': const Color(0xFFFFC107),
      'buttonTextColor': const Color(0xFF7C2D12),
      'icon': Icons.sell_rounded,
      'gradient': const LinearGradient(
        colors: [Color(0xFF7C2D12), Color(0xFFC2410C), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    _loadTopProviders();
  }

  void _loadTopProviders() {
    if (mounted) {
      setState(() {
        _topProvidersFuture = ApiService.getAllProviders();
      });
    }
  }

  bool _isPhoneMissing = false;
  bool _isAddressMissing = false;

  void _loadCustomerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    String savedName = prefs.getString('full_name') ?? '';
    String savedImage = prefs.getString('profile_image_url') ?? '';
    String savedCity = prefs.getString('city') ?? '';
    String savedDistrict = prefs.getString('district') ?? '';
    String savedPhone = prefs.getString('phone') ?? '';
    String savedAddress = prefs.getString('address') ?? '';

    if (userId.isNotEmpty) {
      NotificationService().syncFcmToken(userId: userId).catchError((_) {});
    }

    String loc = savedCity.isNotEmpty ? savedCity : savedDistrict;
    if (loc.isEmpty) loc = 'ශ්‍රී ලංකාව';

    bool phoneEmpty = savedPhone.isEmpty || savedPhone == '+94700000000' || savedPhone == 'නොමැත';
    bool addressEmpty = (savedAddress.isEmpty && savedCity.isEmpty && savedDistrict.isEmpty);

    if (mounted) {
      setState(() {
        if (savedName.isNotEmpty) {
          _customerName = savedName;
        }
        _profileImageUrl = savedImage;
        _customerLocation = loc;
        _isPhoneMissing = phoneEmpty;
        _isAddressMissing = addressEmpty;
      });
    }

    if (userId.isNotEmpty) {
      final profile = await ApiService.getUserProfile(userId);
      if (profile != null && mounted) {
        final phone = (profile['phone'] ?? savedPhone).toString().trim();
        final city = (profile['city'] ?? savedCity).toString().trim();
        final dist = (profile['district'] ?? savedDistrict).toString().trim();
        final addr = (profile['address'] ?? savedAddress).toString().trim();

        final pMissing = phone.isEmpty || phone == '+94700000000' || phone == 'නොමැත';
        final aMissing = addr.isEmpty && city.isEmpty && dist.isEmpty;

        setState(() {
          if (profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) {
            _customerName = profile['full_name'];
          }
          if (profile['profile_image_url'] != null && profile['profile_image_url'].toString().isNotEmpty) {
            _profileImageUrl = profile['profile_image_url'];
          }
          if (city.isNotEmpty) {
            _customerLocation = city;
          } else if (dist.isNotEmpty) {
            _customerLocation = dist;
          }
          _isPhoneMissing = pMissing;
          _isAddressMissing = aMissing;
        });
      }
    }
  }

  final List<Map<String, dynamic>> _featuredServices = [
    {
      'name': 'Electrician Services',
      'label': 'විදුලි කාර්මික\nසේවා',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFF0284C7),
      'bgColor': const Color(0xFFE0F2FE),
    },
    {
      'name': 'Plumbing & Water Lines',
      'label': 'නළ එළීමේ සහ\nජලනල සේවා',
      'icon': Icons.plumbing_rounded,
      'color': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFDBEAFE),
    },
    {
      'name': 'Carpentry & Woodwork',
      'label': 'වඩු කාර්මික\nසේවා',
      'icon': Icons.handyman_rounded,
      'color': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFEF3C7),
    },
    {
      'name': 'Masonry & Construction',
      'label': 'මේසන් සහ\nගොඩනැගිලි වැඩ',
      'icon': Icons.foundation_rounded,
      'color': const Color(0xFFEA580C),
      'bgColor': const Color(0xFFFFEDD5),
    },
    {
      'name': 'House Painting',
      'label': 'තීන්ත\nආලේපනය',
      'icon': Icons.format_paint_rounded,
      'color': const Color(0xFF7C3AED),
      'bgColor': const Color(0xFFEDE9FE),
    },
    {
      'name': 'House Moving & Transport',
      'label': 'නිවාස හා ගෘහභාණ්ඩ\nප්‍රවාහනය',
      'icon': Icons.local_shipping_rounded,
      'color': const Color(0xFF059669),
      'bgColor': const Color(0xFFD1FAE5),
    },
  ];

  Widget _buildPinnedTopBar() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        color: const Color(0xFF001730),
        padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 12, 18, 14),
        child: Row(
          children: [
            // Location Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFFFFC107), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _customerLocation.isNotEmpty ? _customerLocation : 'ශ්‍රී ලංකාව',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 14),
                ],
              ),
            ),
            const Spacer(),

            // Notification Button with Dynamic Unread Count Badge
            ValueListenableBuilder<int>(
              valueListenable: NotificationService.unreadCountNotifier,
              builder: (context, unreadCount, child) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen(role: 'customer')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF001730),
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'ආයුබෝවන්',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text('🙏', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _customerName.isNotEmpty ? _customerName : 'පාරිභෝගිකයා',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Profile Avatar placed in Welcome Banner
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFFF59E0B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: AppColors.navyLight,
                    backgroundImage: _getImageProvider(_profileImageUrl),
                    child: _getImageProvider(_profileImageUrl) == null
                        ? const Icon(Icons.account_circle_outlined, color: Colors.white, size: 30)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return _PromoBannerSliderWidget(promoBanners: _promoBanners);
  }

  Widget _buildPopularServicesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'බහුලව භාවිතා වන සේවා',
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllProvidersScreen()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'සියල්ල බලන්න',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: _featuredServices.length,
            itemBuilder: (context, index) {
              final service = _featuredServices[index];
              final Color iconColor = (service['color'] is Color) ? service['color'] as Color : AppColors.deepNavy;
              final Color bgColor = (service['bgColor'] is Color) ? service['bgColor'] as Color : AppColors.navySubtle;
              final IconData iconData = (service['icon'] is IconData) ? service['icon'] as IconData : Icons.construction_rounded;
              final String labelText = (service['label'] ?? service['name'] ?? '').toString();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderListScreen(
                        categoryName: (service['name'] ?? '').toString(),
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgColor.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          size: 26,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labelText,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopProvidersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'ප්‍රමුඛ සේවා සපයන්නන් (Top Baases)',
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllProvidersScreen()),
                  );
                },
                child: const Text(
                  'සියල්ල බලන්න',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: _topProvidersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 170,
                child: Center(child: CircularProgressIndicator(color: AppColors.deepNavy, strokeWidth: 2)),
              );
            }
            final providers = snapshot.data ?? [];
            final displayProviders = providers.isNotEmpty ? providers.take(6).toList() : [
              {'full_name': 'Umindu Dinal', 'service_category': 'විදුලි කාර්මික සේවා', 'rating': 4.9},
              {'full_name': 'Kamal Perera', 'service_category': 'ජලනල වැඩ', 'rating': 4.8},
            ];

            return SizedBox(
              height: 222,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayProviders.length,
                itemBuilder: (context, index) {
                  final p = displayProviders[index];
                  final pName = p['full_name'] ?? p['name'] ?? 'Umindu Dinal';
                  final pCat = p['service_category'] ?? p['category'] ?? 'විදුලි කාර්මික සේවා';
                  final double rating = ((p['rating'] ?? p['average_rating']) as num?)?.toDouble() ?? 0.0;
                  final int totalReviews = (p['total_reviews'] as num?)?.toInt() ?? 0;
                  final imgStr = (p['profile_image_url'] ?? '').toString();
                  final imgProvider = _getImageProvider(imgStr);

                  return GestureDetector(
                    onTap: () {
                      if (providers.isNotEmpty && index < providers.length) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProviderDetailsScreen(provider: p)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllProvidersScreen()),
                        );
                      }
                    },
                    child: Container(
                      width: 156,
                      margin: const EdgeInsets.only(right: 14, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.07),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Enlarged Profile Photo Container
                          Container(
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.deepNavy,
                                  AppColors.navyAccent.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepNavy.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 33,
                              backgroundColor: AppColors.navySubtle,
                              backgroundImage: imgProvider,
                              child: imgProvider == null
                                  ? Text(
                                      pName.isNotEmpty ? pName[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.deepNavy,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            pName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            pCat,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rating > 0 ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: rating > 0 ? const Color(0xFFFDE68A) : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: rating > 0 ? const Color(0xFFF59E0B) : Colors.grey.shade400,
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  rating > 0 ? rating.toStringAsFixed(1) : 'අලුත්',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: rating > 0 ? const Color(0xFFB45309) : AppColors.textMuted,
                                  ),
                                ),
                                if (totalReviews > 0) ...[
                                  const SizedBox(width: 3),
                                  Text(
                                    '($totalReviews)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileCompletionBanner() {
    if (!_isPhoneMissing && !_isAddressMissing) return const SizedBox.shrink();

    final List<String> missingFields = [];
    if (_isPhoneMissing) missingFields.add('දුරකථන අංකය (Phone)');
    if (_isAddressMissing) missingFields.add('ලිපිනය / නගරය (Address)');

    final missingText = missingFields.join(' සහ ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.error_outline_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ගිණුමේ විස්තර අසම්පූර්ණයි',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Profile Information Incomplete',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'සේවා පහසුවෙන් වෙන්කරවා ගැනීමට (Booking) කරුණාකර ඔබගේ $missingText ඇතුළත් කර ගිණුම සම්පූර්ණ කරන්න.',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF92400E),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerProfileScreen()),
                );
                _loadCustomerName();
              },
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 18),
              label: const Text(
                'දැන්ම විස්තර සම්පූර්ණ කරන්න (Edit Profile)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        _buildPinnedTopBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadCustomerName();
              _loadTopProviders();
              await Future.delayed(const Duration(milliseconds: 400));
            },
            color: AppColors.deepNavy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingHeader(),
                  _buildProfileCompletionBanner(),
                  _buildBannerSection(),
                  _buildPopularServicesSection(),
                  _buildTopProvidersSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
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
              activeIcon: Icons.home_rounded,
              inactiveIcon: Icons.home_outlined,
              label: 'මුල් පිටුව',
            ),
            _buildNavItem(
              index: 1,
              activeIcon: Icons.calendar_month_rounded,
              inactiveIcon: Icons.calendar_month_outlined,
              label: 'වෙන්කිරීම්',
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
          _bookingsKey.currentState?.reloadBookings();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
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
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeBody(),
            CustomerBookingsScreen(
              key: _bookingsKey,
              onFindServices: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            const CustomerMessagesScreen(),
            const SettingsScreen(isProvider: false),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
}

class _PromoBannerSliderWidget extends StatefulWidget {
  final List<Map<String, dynamic>> promoBanners;

  const _PromoBannerSliderWidget({required this.promoBanners});

  @override
  State<_PromoBannerSliderWidget> createState() => _PromoBannerSliderWidgetState();
}

class _PromoBannerSliderWidgetState extends State<_PromoBannerSliderWidget> {
  int _activePromoIndex = 0;
  late final PageController _promoPageController;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _promoPageController = PageController();
    _startPromoAutoSlide();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoPageController.dispose();
    super.dispose();
  }

  void _startPromoAutoSlide() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoPageController.hasClients && mounted) {
        int nextPage = (_activePromoIndex + 1) % widget.promoBanners.length;
        _promoPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: SizedBox(
            height: 192,
            child: PageView.builder(
              controller: _promoPageController,
              onPageChanged: (idx) {
                if (mounted) {
                  setState(() {
                    _activePromoIndex = idx;
                  });
                }
              },
              itemCount: widget.promoBanners.length,
              itemBuilder: (context, index) {
                final banner = widget.promoBanners[index];
                final Gradient gradient = (banner['gradient'] is Gradient)
                    ? banner['gradient'] as Gradient
                    : AppColors.brandCombinedGradient;

                final Color btnBg = (banner['buttonBg'] is Color) ? banner['buttonBg'] as Color : Colors.white;
                final Color btnTextColor = (banner['buttonTextColor'] is Color) ? banner['buttonTextColor'] as Color : AppColors.navyDark;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllProvidersScreen()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -25,
                          child: Icon(
                            (banner['icon'] is IconData) ? banner['icon'] as IconData : Icons.star_rounded,
                            size: 160,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              (banner['icon'] is IconData) ? banner['icon'] as IconData : Icons.star_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (banner['tag'] ?? '').toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 55),
                                    child: Text(
                                      (banner['title'] ?? '').toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 60),
                                    child: Text(
                                      (banner['subtitle'] ?? '').toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11.5,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: btnBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (banner['buttonText'] ?? 'වැඩිදුර විස්තර').toString(),
                                          style: TextStyle(
                                            color: btnTextColor,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: btnTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promoBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _activePromoIndex == index ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _activePromoIndex == index ? AppColors.deepNavy : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}