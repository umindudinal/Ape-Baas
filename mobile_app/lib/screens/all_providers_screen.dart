import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'booking_screen.dart';
import 'provider_details_screen.dart';

const List<String> allSriLankaDistricts = [
  'සියලුම දිස්ත්‍රික්ක',
  'කොළඹ (Colombo)',
  'ගම්පහ (Gampaha)',
  'කළුතර (Kalutara)',
  'මහනුවර (Kandy)',
  'මාතලේ (Matale)',
  'නුවරඑළිය (Nuwara Eliya)',
  'ගාල්ල (Galle)',
  'මාතර (Matara)',
  'හම්බන්තොට (Hambantota)',
  'යාපනය (Jaffna)',
  'කිලිනොච්චිය (Kilinochchi)',
  'මන්නාරම (Mannar)',
  'වවුනියාව (Vavuniya)',
  'මුලතිව් (Mullaitivu)',
  'මඩකලපුව (Batticaloa)',
  'අම්පාර (Ampara)',
  'ත්‍රිකුණාමලය (Trincomalee)',
  'කුරුණෑගල (Kurunegala)',
  'පුත්තලම (Puttalam)',
  'අනුරාධපුරය (Anuradhapura)',
  'පොළොන්නරුව (Polonnaruwa)',
  'බදුල්ල (Badulla)',
  'මොණරාගල (Monaragala)',
  'රත්නපුරය (Ratnapura)',
  'කෑගල්ල (Kegalle)',
];

final List<Map<String, dynamic>> allServiceCategories = [
  {'name': 'සියලුම කාණ්ඩ', 'label': 'සියලුම කාණ්ඩ (All Categories)', 'icon': Icons.apps_rounded, 'color': AppColors.deepNavy},
  {'name': 'Masonry', 'label': 'මේසන් වැඩ - Masonry', 'icon': Icons.foundation_rounded, 'color': AppColors.deepNavy},
  {'name': 'Carpentry', 'label': 'වඩු වැඩ - Carpentry', 'icon': Icons.handyman_rounded, 'color': AppColors.deepNavy},
  {'name': 'Plumbing', 'label': 'ජලනල වැඩ - Plumbing', 'icon': Icons.plumbing_rounded, 'color': AppColors.deepNavy},
  {'name': 'Electrical Work', 'label': 'විදුලි වැඩ - Electrical Work', 'icon': Icons.electrical_services_rounded, 'color': AppColors.deepNavy},
  {'name': 'Painting', 'label': 'තීන්ත ගෑමේ වැඩ - Painting', 'icon': Icons.format_paint_rounded, 'color': AppColors.deepNavy},
  {'name': 'Tiling', 'label': 'ටයිල් ඇල්ලීමේ වැඩ - Tiling', 'icon': Icons.grid_on_rounded, 'color': AppColors.deepNavy},
  {'name': 'Welding', 'label': 'පෑස්සුම් වැඩ - Welding', 'icon': Icons.precision_manufacturing_rounded, 'color': AppColors.deepNavy},
  {'name': 'Aluminum Fabrication', 'label': 'ඇලුමිනියම් වැඩ - Aluminum Fabrication', 'icon': Icons.door_sliding_rounded, 'color': AppColors.deepNavy},
  {'name': 'Roofing', 'label': 'වහල සෙවිලි කිරීමේ වැඩ - Roofing', 'icon': Icons.roofing_rounded, 'color': AppColors.deepNavy},
  {'name': 'A/C Repair', 'label': 'වායු සමීකරණ අලුත්වැඩියාව - A/C Repair', 'icon': Icons.ac_unit_rounded, 'color': AppColors.deepNavy},
  {'name': 'Landscaping', 'label': 'ගෙවතු අලංකරණය - Landscaping', 'icon': Icons.park_rounded, 'color': AppColors.deepNavy},
];

class AllProvidersScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedDistrict;

  const AllProvidersScreen({super.key, this.selectedCategory, this.selectedDistrict});

  @override
  State<AllProvidersScreen> createState() => _AllProvidersScreenState();
}

class _AllProvidersScreenState extends State<AllProvidersScreen> {
  Future<List<dynamic>>? _providersFuture;

  String _searchQuery = '';
  String _selectedDistrict = 'සියලුම දිස්ත්‍රික්ක';
  String _selectedCategoryName = 'සියලුම කාණ්ඩ';
  List<Map<String, dynamic>> _dynamicCategories = [];

  IconData _getCategoryIcon(String iconName, String nameEn) {
    final text = '$nameEn $iconName'.toLowerCase();
    if (text.contains('solar') || text.contains('sun')) return Icons.wb_sunny_rounded;
    if (text.contains('zap') || text.contains('electr') || text.contains('power') || text.contains('light') || text.contains('bulb') || text.contains('wire')) return Icons.electrical_services_rounded;
    if (text.contains('wrench') || text.contains('droplets') || text.contains('plumb') || text.contains('water') || text.contains('tap') || text.contains('gully') || text.contains('pump') || text.contains('well') || text.contains('pipe')) return Icons.plumbing_rounded;
    if (text.contains('hammer') || text.contains('carpent') || text.contains('wood') || text.contains('roof') || text.contains('furniture') || text.contains('curtain') || text.contains('fenc')) return Icons.handyman_rounded;
    if (text.contains('wind') || text.contains('snowflake') || text.contains('ac') || text.contains('air') || text.contains('cool') || text.contains('fan')) return Icons.ac_unit_rounded;
    if (text.contains('building') || text.contains('mason') || text.contains('brick') || text.contains('concrete') || text.contains('demolit')) return Icons.foundation_rounded;
    if (text.contains('paint') || text.contains('color') || text.contains('wall')) return Icons.format_paint_rounded;
    if (text.contains('grid') || text.contains('layers') || text.contains('tile') || text.contains('floor') || text.contains('interlock')) return Icons.grid_on_rounded;
    if (text.contains('trees') || text.contains('garden') || text.contains('tree') || text.contains('landscape') || text.contains('lawn')) return Icons.park_rounded;
    if (text.contains('sparkles') || text.contains('clean') || text.contains('wash') || text.contains('deep')) return Icons.cleaning_services_rounded;
    if (text.contains('camera') || text.contains('cctv') || text.contains('security')) return Icons.videocam_rounded;
    if (text.contains('bug') || text.contains('pest')) return Icons.bug_report_rounded;
    if (text.contains('truck') || text.contains('car') || text.contains('moving') || text.contains('transport')) return Icons.local_shipping_rounded;
    if (text.contains('key') || text.contains('lock')) return Icons.lock_rounded;
    if (text.contains('tv') || text.contains('dish')) return Icons.tv_rounded;
    if (text.contains('cpu') || text.contains('smartphone') || text.contains('it') || text.contains('computer')) return Icons.computer_rounded;
    if (text.contains('flame') || text.contains('weld') || text.contains('metal') || text.contains('gas')) return Icons.precision_manufacturing_rounded;
    if (text.contains('scissors') || text.contains('tailor')) return Icons.content_cut_rounded;
    if (text.contains('shield')) return Icons.security_rounded;
    
    return Icons.construction_rounded;
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null && widget.selectedCategory!.isNotEmpty) {
      _selectedCategoryName = widget.selectedCategory!;
    }
    if (widget.selectedDistrict != null && widget.selectedDistrict!.isNotEmpty) {
      _selectedDistrict = widget.selectedDistrict!;
    }

    _loadProviders();
    _loadCategoriesFromBackend();
  }

  void _loadCategoriesFromBackend() async {
    final list = await ApiService.getCategories();
    if (list.isNotEmpty && mounted) {
      final activeList = list.where((c) => c['status'] == 'Active').toList();
      final mapped = <Map<String, dynamic>>[
        {'name': 'සියලුම කාණ්ඩ', 'label': 'සියලුම කාණ්ඩ (All Categories)', 'icon': Icons.apps_rounded, 'color': AppColors.deepNavy}
      ];
      for (int i = 0; i < activeList.length; i++) {
        final c = activeList[i];
        final String nameEn = c['nameEn'] ?? c['name_en'] ?? '';
        final String nameSi = c['nameSi'] ?? c['name_si'] ?? nameEn;
        final String iconStr = c['icon'] ?? 'Wrench';
        mapped.add({
          'name': nameEn,
          'label': '$nameSi ($nameEn)',
          'icon': _getCategoryIcon(iconStr, nameEn),
          'color': AppColors.deepNavy,
        });
      }
      setState(() {
        _dynamicCategories = mapped;
      });
    }
  }

  void _loadProviders() {
    setState(() {
      _providersFuture = ApiService.getAllProviders();
    });
  }

  Future<void> _handleRefresh() async {
    _loadProviders();
    await Future.delayed(const Duration(milliseconds: 600));
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

  List<dynamic> _filterProviders(List<dynamic> providers) {
    return providers.where((p) {
      final String name = (p['full_name'] ?? p['name'] ?? '').toString().toLowerCase();
      final String category = (p['service_category'] ?? p['category'] ?? '').toString().toLowerCase();
      final String district = (p['district'] ?? '').toString().toLowerCase();
      final String city = (p['city'] ?? '').toString().toLowerCase();
      final String address = (p['address'] ?? '').toString().toLowerCase();

      final String query = _searchQuery.toLowerCase().trim();
      final bool matchesSearch = query.isEmpty ||
          name.contains(query) ||
          category.contains(query) ||
          district.contains(query) ||
          city.contains(query) ||
          address.contains(query);

      final bool matchesDistrict = _selectedDistrict == 'සියලුම දිස්ත්‍රික්ක' ||
          district.contains(_selectedDistrict.split(' ')[0].toLowerCase()) ||
          address.contains(_selectedDistrict.split(' ')[0].toLowerCase());

      final bool matchesCategory = _selectedCategoryName == 'සියලුම කාණ්ඩ' ||
          category.contains(_selectedCategoryName.toLowerCase());

      return matchesSearch && matchesDistrict && matchesCategory;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDistrict = 'සියලුම දිස්ත්‍රික්ක';
      _selectedCategoryName = 'සියලුම කාණ්ඩ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = _dynamicCategories.isNotEmpty ? _dynamicCategories : allServiceCategories;
    final safeCategoryName = availableCategories.any((c) => c['name'] == _selectedCategoryName)
        ? _selectedCategoryName
        : 'සියලුම කාණ්ඩ';

    final safeDistrict = allSriLankaDistricts.contains(_selectedDistrict)
        ? _selectedDistrict
        : 'සියලුම දිස්ත්‍රික්ක';

    final bool hasActiveFilter = _searchQuery.isNotEmpty ||
        _selectedDistrict != 'සියලුම දිස්ත්‍රික්ක' ||
        _selectedCategoryName != 'සියලුම කාණ්ඩ';

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text(
          'සියලුම සේවා සපයන්නන්',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppColors.navyDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter & Search Controls Header Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Dual Dropdowns Row (District & Category)
                Row(
                  children: [
                    // District Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: safeDistrict,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.deepNavy),
                            style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDistrict = val;
                                });
                              }
                            },
                            items: allSriLankaDistricts.map((d) {
                              return DropdownMenuItem<String>(
                                value: d,
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 15, color: AppColors.deepNavy),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        d,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Category Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: safeCategoryName,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.deepNavy),
                            style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategoryName = val;
                                });
                              }
                            },
                            items: availableCategories.map((c) {
                              return DropdownMenuItem<String>(
                                value: c['name'],
                                child: Row(
                                  children: [
                                    Icon(
                                      c['icon'] as IconData, 
                                      size: 15, 
                                      color: AppColors.deepNavy,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        c['label'].toString(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Reset Filters Button
                if (hasActiveFilter) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _resetFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.filter_alt_off_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'පෙරහන් ඉවත් කරන්න (Reset)',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Main Providers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.deepNavy,
              child: FutureBuilder<List<dynamic>>(
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                      Icons.engineering_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'දැනට සේවා සපයන්නන් නොමැත',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyDark,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'අපගේ වේදිකාවට නව සේවා සපයන්නන් (බාස්වරුන්) නිරන්තරයෙන් එක්වෙමින් පවතී. කරුණාකර මද වේලාවකින් නැවත පරීක්ෂා කරන්න.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
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
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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

                  final filteredList = _filterProviders(snapshot.data!);

                  if (filteredList.isEmpty) {
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
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.navySubtle,
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: const Center(
                                  child: Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'ගැලපෙන බාස්වරුන් හමු නොවීය',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'තෝරාගත් දිස්ත්‍රික්කය, නගරය හෝ කාණ්ඩයට අදාළ බාස්වරුන් මෙම ප්‍රදේශයේ නොමැත. කරුණාකර ෆිල්ටර වෙනස් කරන්න.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 19),
                                  label: const Text(
                                    'සියලුම බාස්වරුන් පෙන්වන්න',
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
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final provider = filteredList[index];
                      final name = provider['full_name'] ?? provider['name'] ?? 'සේවා සපයන්නා';
                      final experience = provider['experience_years'] ?? provider['experience'] ?? 0;
                      final isVerified = provider['is_verified'] == true;
                      final city = provider['city'] ?? provider['district'] ?? provider['address'] ?? '';
                      final categoryName = (provider['service_category'] ?? provider['category'] ?? 'General').toString();
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
            ),
          ),
        ],
      ),
    );
  }
}
