import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const BookingScreen({super.key, required this.provider});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

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

  List<String> get _quickSuggestions {
    final cat = (widget.provider['service_category'] ?? widget.provider['category'] ?? '').toString();
    return _getSuggestionsForCategory(cat);
  }

  List<String> _getSuggestionsForCategory(String categoryStr) {
    final catLower = categoryStr.toLowerCase().trim();
    final List<String> suggestions = [];

    void addIfMatches(List<String> keywords, List<String> items) {
      if (keywords.any((kw) => catLower.contains(kw))) {
        for (var item in items) {
          if (!suggestions.contains(item)) {
            suggestions.add(item);
          }
        }
      }
    }

    // 1. Masonry
    addIfMatches(
      ['mason', 'මේසන්', 'ගඩොල්', 'ප්ලාස්ටර්', 'ගොඩනැගිලි'],
      [
        'බිත්ති බැඳීම / ප්ලාස්ටර් කිරීම',
        'කොන්ක්‍රීට් වැඩ / අඩිතාලම',
        'ගෙබිම මට්ටම් කිරීම',
        'ප්ලාස්ටර් පලුදු අලුත්වැඩියා කිරීම',
        'ගඩොල් / බ්ලොක් ගල් ඇල්ලීම',
      ],
    );

    // 2. Carpentry
    addIfMatches(
      ['carpent', 'වඩු', 'ලී', 'wood'],
      [
        'දොරවල් / ජනේල සවිකිරීම',
        'ලී පරාල / වහල වඩු වැඩ',
        'කබඩ් / ඇඳන් අලුත්වැඩියාව',
        'ලොක් / අගුළු සවිකිරීම',
        'ලී ඔප දැමීම (Varnish / Polish)',
      ],
    );

    // 3. Plumbing
    addIfMatches(
      ['plumb', 'ජලනල', 'ජල නළ', 'පයිප්ප', 'water'],
      [
        'ජල නළ කාන්දුව / පයිප්ප සවිකිරීම',
        'සිංක් / කොමඩ් අවහිරතා ඉවත් කිරීම',
        'වතුර ටැප් / වැල් අලුත්වැඩියාව',
        'ජල ටැංකියට නළ සම්බන්ධ කිරීම',
        'Bathroom Fittings / Shower සවිකිරීම',
      ],
    );

    // 4. Electrical Work
    addIfMatches(
      ['electric', 'විදුලි', 'වයරින්', 'zap', 'light'],
      [
        'විදුලි පංකා / ලයිට් අලුත්වැඩියාව',
        'නව වයරින් පද්ධතියක් සවි කිරීම',
        'Main Switch / Trip Switch දෝෂය',
        'ප්ලග් පොයින්ට් සවිකිරීම',
        'DB Box / Breaker අලුත්වැඩියාව',
      ],
    );

    // 5. A/C Repair
    addIfMatches(
      ['ac', 'air', 'cool', 'වායු සමීකරණ', 'wind'],
      [
        'A/C ගෑස් නැවත පිරවීම (Gas Refill)',
        'A/C සර්විස් කිරීම / Cleaning',
        'වතුර කාන්දු වීම / Cool නොවීමට හේතු',
        'A/C සවිකිරීම / ගලවා ඉවත් කිරීම',
      ],
    );

    // 6. Painting
    addIfMatches(
      ['paint', 'තීන්ත', 'color', 'wall'],
      [
        'ඇතුළත / පිටත බිත්ති තීන්ත ගෑම',
        'Weather Shield තීන්ත ආලේපය',
        'පුට්ටි (Putty) ගෑම සහ සිනිඳු කිරීම',
        'වහල / යකඩ තීන්ත ගෑම',
      ],
    );

    // 7. Tiling
    addIfMatches(
      ['tile', 'ටයිල්', 'floor', 'grid'],
      [
        'නානකාමර ටයිල් ඇල්ලීම',
        'සාලය / මුළුතැන්ගෙයි ටයිල් ඇල්ලීම',
        'ටයිල් කැඩුණු ස්ථාන පිළිසකර කිරීම',
        'Titanium / Interlock එළීම',
      ],
    );

    // 8. Welding & Aluminum
    addIfMatches(
      ['weld', 'පෑස්සුම්', 'metal', 'flame', 'alum', 'ඇලුමිනියම්'],
      [
        'යකඩ ගේට්ටු / ග්‍රිල් සවිකිරීම',
        'ඇලුමිනියම් දොර ජනේල සවිකිරීම',
        'යකඩ වහල ෆ්‍රේම් පෑස්සීම',
        'Partition / Sliding Door සවිකිරීම',
      ],
    );

    // 9. Roofing
    addIfMatches(
      ['roof', 'වහල', 'ceiling', 'සිවිලිම්'],
      [
        'වහල වතුර කාන්දුව සෑදීම',
        'උළු / ෂීට් සෙවිලි කිරීම',
        'Gutter / පීලි සවිකිරීම',
        'සිවිලිම් ගැසීම (Ceiling Work)',
      ],
    );

    // 10. Gardening & Landscaping
    addIfMatches(
      ['garden', 'ගෙවතු', 'tree', 'park', 'landscap'],
      [
        'තණකොළ වැවීම / කැපීම (Lawn Mowing)',
        'ගස් වැල් කැපීම සහ ශාක අලංකරණය',
        'ගෙවතු නිර්මාණය සහ පැළ සිටුවීම',
      ],
    );

    // 11. Cleaning Services
    addIfMatches(
      ['clean', 'පිරිසිදු', 'sparkles', 'wash'],
      [
        'නිවාස Deep Cleaning',
        'නානකාමර සෝදා පිරිසිදු කිරීම',
        'සෝෆා / කාපට් සේදීම',
      ],
    );

    // 12. Solar Panel
    addIfMatches(
      ['solar', 'sun', 'සූර්ය'],
      [
        'සූර්ය පැනල පද්ධතිය සවිකිරීම',
        'Solar Inverter දෝෂ පරීක්ෂාව',
        'Solar Panels Clean කිරීම',
      ],
    );

    // 13. CCTV & Security
    addIfMatches(
      ['cctv', 'secur', 'camera', 'ආරක්ෂිත'],
      [
        'CCTV කැමරා සවිකිරීම',
        'Network / DVR සැකසීම',
        'Security Alarm සවිකිරීම',
      ],
    );

    if (suggestions.isEmpty) {
      return [
        'අලුත්වැඩියා කටයුතු',
        'නඩත්තු සේවා',
        'නව උපාංග/පද්ධති සවිකිරීම',
        'පරීක්ෂා කර බලා උපදෙස් ලබා ගැනීම',
      ];
    }

    return suggestions;
  }

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate!);
  }

  void _loadUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    String savedAddress = (prefs.getString('address') ?? '').trim();
    String district = (prefs.getString('district') ?? '').trim();
    String city = (prefs.getString('city') ?? '').trim();

    List<String> parts = [];
    if (savedAddress.isNotEmpty) parts.add(savedAddress);
    if (city.isNotEmpty && !savedAddress.contains(city)) parts.add(city);
    if (district.isNotEmpty && !savedAddress.contains(district) && !city.contains(district)) parts.add(district);

    String fullLoc = parts.join(', ');

    if (fullLoc.isNotEmpty && mounted) {
      setState(() {
        _addressController.text = fullLoc;
      });
    }

    if (userId.isNotEmpty) {
      try {
        final profile = await ApiService.getUserProfile(userId);
        if (profile != null && mounted) {
          String pAddr = (profile['address'] ?? '').toString().trim();
          String pCity = (profile['city'] ?? '').toString().trim();
          String pDist = (profile['district'] ?? '').toString().trim();

          List<String> pParts = [];
          if (pAddr.isNotEmpty) pParts.add(pAddr);
          if (pCity.isNotEmpty && !pAddr.contains(pCity)) pParts.add(pCity);
          if (pDist.isNotEmpty && !pAddr.contains(pDist) && !pCity.contains(pDist)) pParts.add(pDist);

          String pFull = pParts.join(', ');
          if (pFull.isNotEmpty) {
            setState(() {
              _addressController.text = pFull;
            });
            if (pAddr.isNotEmpty) prefs.setString('address', pAddr);
            if (pCity.isNotEmpty) prefs.setString('city', pCity);
            if (pDist.isNotEmpty) prefs.setString('district', pDist);
          }
        }
      } catch (e) {
        debugPrint("Error fetching user profile for address: $e");
      }
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('user_id');

    if (customerId == null || customerId.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('පරිශීලක හැඳුනුම් අංකය හමු නොවීය. නැවත Log in වන්න.'), backgroundColor: AppColors.errorRed),
        );
      }
      return;
    }

    final providerId = (widget.provider['id'] ?? widget.provider['user_id'] ?? widget.provider['provider_id'] ?? '').toString();

    if (providerId.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('සේවා සපයන්නාගේ අංකය (ID) හමු නොවීය.'), backgroundColor: AppColors.errorRed),
        );
      }
      return;
    }

    final result = await ApiService.createBooking(
      customerId: customerId,
      providerId: providerId,
      issue: _issueController.text.trim(),
      address: _addressController.text.trim(),
      date: _dateController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text('ඉල්ලීම සාර්ථකයි!', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyDark, fontSize: 18)),
                ),
              ],
            ),
            content: Text(
              result['message'] ?? 'ඔබගේ සේවා වෙන්කිරීමේ ඉල්ලීම සාර්ථකව යවන ලදී. සේවා සපයන්නා කෙටි වේලාවකින් ඔබව සම්බන්ධ කරගනු ඇත.',
              style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('හරි (OK)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'දෝෂයක් සිදු විය'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerName = widget.provider['full_name'] ?? widget.provider['name'] ?? 'සේවා සපයන්නා';
    final category = widget.provider['service_category'] ?? widget.provider['category'] ?? 'General';
    final isVerified = widget.provider['is_verified'] ?? false;
    final profileImageUrl = (widget.provider['profile_image_url'] ?? widget.provider['profile_image'] ?? widget.provider['profile_picture'] ?? widget.provider['avatar'] ?? '').toString();
    final imgProvider = _getImageProvider(profileImageUrl);
    final rating = (widget.provider['rating'] ?? 4.8).toDouble();

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text(
          'සේවාව වෙන්කරගැනීම (Book Baas)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Selected Provider Hero Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.navyDark,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33001730),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar Ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isVerified
                              ? AppColors.emeraldGradient
                              : const LinearGradient(colors: [Colors.white, Colors.white70]),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.navySubtle,
                          backgroundImage: imgProvider,
                          child: imgProvider == null
                              ? Text(
                                  providerName.isNotEmpty ? providerName[0].toUpperCase() : 'P',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name, Category & Verified
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'තෝරාගත් සේවා සපයන්නා:',
                              style: TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    providerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 20),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    category.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Booking Form Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.edit_note_rounded, color: AppColors.deepNavy, size: 24),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'වෙන්කිරීමේ විස්තර ඇතුළත් කරන්න',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                      ),

                      // Field 1: Issue / Problem Description Input
                      const Text(
                        '1. අවශ්‍යතාවය / ගැටළුව (Issue Description) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _issueController,
                        maxLines: 3,
                        validator: (val) => val == null || val.trim().isEmpty ? 'කරුණාකර අවශ්‍යතාවය සඳහන් කරන්න' : null,
                        decoration: InputDecoration(
                          hintText: 'උදා: විදුලි පංකාව ක්‍රියා නොකරයි. නව වයරින් පද්ධතියක් සවි කිරීමට අවශ්‍යයි...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.surfaceBg,
                          contentPadding: const EdgeInsets.all(14),
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
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Issue Suggestions Chips
                      const Text(
                        '💡 ක්ෂණික තේරීම් (Quick Suggestions):',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickSuggestions.length,
                          itemBuilder: (context, idx) {
                            final sug = _quickSuggestions[idx];
                            final isSelected = _issueController.text == sug;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                  size: 15,
                                  color: isSelected ? Colors.white : AppColors.deepNavy,
                                ),
                                label: Text(
                                  sug,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white : AppColors.deepNavy,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: isSelected ? AppColors.deepNavy : AppColors.navySubtle,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onPressed: () {
                                  setState(() {
                                    _issueController.text = sug;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Field 2: Service Date Picker Input
                      const Text(
                        '2. සේවාව අවශ්‍ය දිනය (Service Date) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.navySubtle,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.calendar_month_rounded, color: AppColors.deepNavy, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('තෝරාගත් දිනය:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _dateController.text.isNotEmpty ? _dateController.text : 'දිනය තෝරන්න',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down_circle_rounded, color: AppColors.deepNavy, size: 22),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Field 3: Customer Address Input
                      const Text(
                        '3. සේවා ස්ථානය / ලිපිනය (Service Address) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        validator: (val) => val == null || val.trim().isEmpty ? 'ලිපිනය ඇතුළත් කරන්න' : null,
                        decoration: InputDecoration(
                          hintText: 'ඔබගේ නිවාස සේවා ස්ථානයේ ලිපිනය...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.deepNavy),
                          filled: true,
                          fillColor: AppColors.surfaceBg,
                          contentPadding: const EdgeInsets.all(14),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Submit Booking Button Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitBooking,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      label: Text(
                        _isLoading ? 'ඉල්ලීම යවමින් පවතී...' : 'සේවා ඉල්ලීම යවන්න (Send Request)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'සේවා සපයන්නා ඉල්ලීම භාරගත් පසු ඔබට ඇමතුමක් ලැබෙනු ඇත.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}