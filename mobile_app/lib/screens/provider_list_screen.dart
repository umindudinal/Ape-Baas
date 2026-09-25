import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'booking_screen.dart';
import 'provider_details_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String categoryName;

  const ProviderListScreen({super.key, required this.categoryName});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  late Future<List<dynamic>> _providersFuture;

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
    _loadProviders();
  }

  void _loadProviders() {
    setState(() {
      _providersFuture = ApiService.getAllProviders();
    });
  }

  List<String> _getKeywordsForCategory(String target) {
    final t = target.toLowerCase();
    if (t.contains('mason') || t.contains('මේසන්') || t.contains('ගඩොල්')) return ['mason', 'මේසන්', 'ගොඩනැගිලි'];
    if (t.contains('carpent') || t.contains('වඩු') || t.contains('ලී')) return ['carpent', 'වඩු', 'ලී', 'wood'];
    if (t.contains('plumb') || t.contains('ජලනල') || t.contains('නළ') || t.contains('පයිප්ප')) return ['plumb', 'ජලනල', 'නළ', 'water', 'pipe'];
    if (t.contains('electr') || t.contains('විදුලි') || t.contains('zap') || t.contains('වයරින්')) return ['electr', 'විදුලි', 'වයරින්', 'zap', 'light'];
    if (t.contains('ac') || t.contains('air') || t.contains('වායු') || t.contains('cool')) return ['ac', 'air', 'cool', 'වායු'];
    if (t.contains('paint') || t.contains('තීන්ත')) return ['paint', 'තීන්ත', 'color'];
    if (t.contains('tile') || t.contains('ටයිල්')) return ['tile', 'ටයිල්', 'floor'];
    if (t.contains('weld') || t.contains('පෑස්සුම්')) return ['weld', 'පෑස්සුම්', 'metal'];
    if (t.contains('alum') || t.contains('ඇලුමිනියම්')) return ['alum', 'ඇලුමිනියම්'];
    if (t.contains('roof') || t.contains('වහල') || t.contains('ceiling')) return ['roof', 'වහල', 'ceiling'];
    if (t.contains('garden') || t.contains('ගෙවතු') || t.contains('landscap')) return ['garden', 'ගෙවතු', 'landscap'];
    if (t.contains('clean') || t.contains('පිරිසිදු')) return ['clean', 'පිරිසිදු', 'wash'];
    if (t.contains('solar') || t.contains('සූර්ය')) return ['solar', 'සූර්ය', 'sun'];
    if (t.contains('cctv') || t.contains('ආරක්ෂිත')) return ['cctv', 'secur', 'camera'];

    return t.split(' ').where((w) => w.length > 2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} සේවා',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.deepNavy));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.errorRed),
                  const SizedBox(height: 10),
                  const Text('දත්ත ලබා ගැනීමේ දෝෂයක්!', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadProviders,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepNavy),
                    child: const Text('නැවත උත්සාහ කරන්න', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final allProviders = snapshot.data ?? [];

          // Filter providers matching the selected category with smart keyword matching
          final matchingProviders = allProviders.where((p) {
            final providerCat = (p['service_category'] ?? p['category'] ?? '').toString().toLowerCase().trim();
            final targetCat = widget.categoryName.toLowerCase().trim();
            if (providerCat.isEmpty || providerCat == 'සඳහන් කර නැත') return false;

            if (targetCat.isEmpty || targetCat == 'සියලුම කාණ්ඩ' || targetCat == 'all') return true;

            if (providerCat.contains(targetCat) || targetCat.contains(providerCat)) return true;

            final keywords = _getKeywordsForCategory(targetCat);
            return keywords.any((kw) => providerCat.contains(kw));
          }).toList();

          if (matchingProviders.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepNavy.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dual-ring Icon Badge
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.navySubtle,
                              AppColors.warningAmber.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: AppColors.navyAccent.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.navyDark,
                                  AppColors.deepNavy,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepNavy.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_search_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${widget.categoryName} සඳහා සේවා සපයන්නන් හමු නොවීය',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyDark,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'මෙම කාණ්ඩය සඳහා නව සේවා සපයන්නන් ලියාපදිංචි වෙමින් පවතී. කරුණාකර මද වේලාවකින් නැවත පරීක්ෂා කරන්න.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _loadProviders,
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 19),
                          label: const Text(
                            'නැවත පූරණය කරන්න (Refresh)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNavy,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.76,
            ),
            itemCount: matchingProviders.length,
            itemBuilder: (context, index) {
              final provider = matchingProviders[index];
              final name = provider['full_name'] ?? provider['name'] ?? 'සේවා සපයන්නා';
              final experience = provider['experience_years'] ?? provider['experience'] ?? 0;
              final isVerified = provider['is_verified'] == true;
              final city = provider['city'] ?? provider['district'] ?? provider['address'] ?? '';
              final categoryName = (provider['service_category'] ?? provider['category'] ?? widget.categoryName).toString();
              final double rating = ((provider['rating'] ?? provider['average_rating']) as num?)?.toDouble() ?? 0.0;
              final int totalReviews = (provider['total_reviews'] as num?)?.toInt() ?? 0;
              final profileImageUrl = (provider['profile_image_url'] ?? provider['profile_image'] ?? provider['profile_picture'] ?? provider['avatar'] ?? '').toString();
              final imgProvider = _getImageProvider(profileImageUrl);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderDetailsScreen(provider: provider),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepNavy.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isVerified
                                      ? AppColors.emeraldGradient
                                      : AppColors.brandCombinedGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isVerified ? AppColors.successGreen : AppColors.deepNavy).withValues(alpha: 0.15),
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
                                          name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.deepNavy,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (isVerified)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 16),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 7),

                          // Name
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyDark,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Experience / Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.navySubtle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryName.isNotEmpty ? categoryName : 'අවු. $experience පළපුරුද්ද',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: AppColors.deepNavy, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Rating & Location
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: rating > 0 ? Colors.amber : Colors.grey.shade400,
                                size: 13,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating > 0 ? rating.toStringAsFixed(1) : 'අලුත්',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: rating > 0 ? const Color(0xFF92400E) : AppColors.textMuted,
                                ),
                              ),
                              if (totalReviews > 0) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '($totalReviews)',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ],
                              if (city.toString().isNotEmpty) ...[
                                const SizedBox(width: 4),
                                const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    city.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(provider: provider),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNavy,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
                          ),
                          child: const Text('වෙන් කරන්න', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}