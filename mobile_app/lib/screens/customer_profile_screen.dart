import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'edit_profile_screen.dart';
import 'role_selection_screen.dart';
import 'settings_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _district = '';
  String _city = '';
  String _userId = '';
  String _profileImageUrl = '';
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    if (mounted) {
      setState(() {
        _fullName = prefs.getString('full_name') ?? 'පාරිභෝගිකයා';
        _email = prefs.getString('email') ?? 'නොමැත';
        _phone = prefs.getString('phone') ?? 'නොමැත';
        _address = prefs.getString('address') ?? '';
        _district = prefs.getString('district') ?? '';
        _city = prefs.getString('city') ?? '';
        _profileImageUrl = prefs.getString('profile_image_url') ?? '';
        _userId = userId;
      });
    }

    if (userId.isNotEmpty) {
      final profile = await ApiService.getUserProfile(userId);
      if (profile != null && mounted) {
        setState(() {
          if (profile['full_name'] != null &&
              profile['full_name'].toString().isNotEmpty) {
            _fullName = profile['full_name'];
          }
          if (profile['email'] != null &&
              profile['email'].toString().isNotEmpty) {
            _email = profile['email'];
          }
          if (profile['phone'] != null &&
              profile['phone'].toString().isNotEmpty) {
            _phone = profile['phone'];
          }
          if (profile['address'] != null &&
              profile['address'].toString().isNotEmpty) {
            _address = profile['address'];
          }
          if (profile['district'] != null &&
              profile['district'].toString().isNotEmpty) {
            _district = profile['district'];
          }
          if (profile['city'] != null &&
              profile['city'].toString().isNotEmpty) {
            _city = profile['city'];
          }
          if (profile['profile_image_url'] != null &&
              profile['profile_image_url'].toString().isNotEmpty) {
            _profileImageUrl = profile['profile_image_url'];
          }
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final refreshed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentProfile: {
            'full_name': _fullName,
            'phone': _phone,
            'email': _email,
            'id': _userId,
            'address': _address,
            'district': _district,
            'city': _city,
          },
          isProvider: false,
        ),
      ),
    );
    if (refreshed == true) {
      _loadUserData();
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

  Future<void> _updateProfilePhoto(String newImageUrl) async {
    if (_userId.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    final res = await ApiService.updateProfilePicture(
      userId: _userId,
      profileImageUrl: newImageUrl,
    );

    if (mounted) {
      if (res['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_url', newImageUrl);
      }
      setState(() {
        _isLoading = false;
        if (res['success']) {
          _profileImageUrl = newImageUrl;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: res['success']
              ? AppColors.successGreen
              : AppColors.errorRed,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ප්‍රොෆයිල් ඡායාරූපය වෙනස් කරන්න',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navySubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.deepNavy,
                  ),
                ),
                title: const Text(
                  'කැමරාව මඟින් ඡායාරූපයක් ගන්න',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.textDark,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 600,
                      maxHeight: 600,
                      imageQuality: 75,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      final base64Image =
                          'data:image/jpeg;base64,${base64Encode(bytes)}';
                      _updateProfilePhoto(base64Image);
                    }
                  } catch (e) {
                    debugPrint("❌ Camera Error: $e");
                  }
                },
              ),
              const Divider(height: 10, color: Color(0xFFEEF2F6)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navySubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.deepNavy,
                  ),
                ),
                title: const Text(
                  'ගැලරියෙන් තෝරන්න',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.textDark,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 600,
                      maxHeight: 600,
                      imageQuality: 75,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      final base64Image =
                          'data:image/jpeg;base64,${base64Encode(bytes)}';
                      _updateProfilePhoto(base64Image);
                    }
                  } catch (e) {
                    debugPrint("❌ Gallery Error: $e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider(_profileImageUrl);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: Column(
        children: [
          // Custom Top Header Bar (Matching Settings Screen)
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                18,
                MediaQuery.of(context).padding.top + 12,
                14,
                16,
              ),
              decoration: const BoxDecoration(color: AppColors.navyDark),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 12),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'ආපසු (Back)',
                    ),
                  ],
                  const Expanded(
                    child: Text(
                      'මගේ ගිණුම (Profile)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.deepNavy),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserData,
                    color: AppColors.deepNavy,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Profile Header Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.cardBorder.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepNavy.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _showImagePickerOptions,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient:
                                              AppColors.brandCombinedGradient,
                                        ),
                                        child: CircleAvatar(
                                          radius: 46,
                                          backgroundColor: Colors.white,
                                          backgroundImage: imageProvider,
                                          child: imageProvider == null
                                              ? CircleAvatar(
                                                  radius: 42,
                                                  backgroundColor:
                                                      AppColors.navySubtle,
                                                  child: Text(
                                                    _fullName.isNotEmpty
                                                        ? _fullName[0]
                                                              .toUpperCase()
                                                        : 'C',
                                                    style: const TextStyle(
                                                      fontSize: 34,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.deepNavy,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: AppColors.deepNavy,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _fullName.isNotEmpty
                                      ? _fullName
                                      : 'පාරිභෝගිකයා',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navyDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.navySubtle,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.navyLight.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.person_rounded,
                                        size: 16,
                                        color: AppColors.deepNavy,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'පාරිභෝගික ගිණුම (Customer)',
                                        style: TextStyle(
                                          color: AppColors.deepNavy,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Personal Information Card
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.cardBorder.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepNavy.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'පුද්ගලික තොරතුරු',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navyDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: _navigateToEditProfile,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.navySubtle,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.navyLight
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 14,
                                              color: AppColors.deepNavy,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.deepNavy,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFEEF2F6),
                                  ),
                                ),
                                _buildInfoTile(
                                  icon: Icons.person_rounded,
                                  iconColor: const Color(0xFF2563EB),
                                  bgColor: const Color(0xFFEFF6FF),
                                  title: 'සම්පූර්ණ නම',
                                  value: _fullName,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoTile(
                                  icon: Icons.email_rounded,
                                  iconColor: const Color(0xFFD97706),
                                  bgColor: const Color(0xFFFEF3C7),
                                  title: 'ඊමේල් ලිපිනය',
                                  value: _email,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoTile(
                                  icon: Icons.phone_android_rounded,
                                  iconColor: const Color(0xFF059669),
                                  bgColor: const Color(0xFFD1FAE5),
                                  title: 'දුරකථන අංකය',
                                  value: _phone,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoTile(
                                  icon: Icons.location_on_rounded,
                                  iconColor: const Color(0xFFE11D48),
                                  bgColor: const Color(0xFFFFE4E6),
                                  title: 'ලිපිනය (Address Details)',
                                  value: _address.isNotEmpty
                                      ? _address
                                      : 'සඳහන් කර නැත',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoTile(
                                  icon: Icons.map_rounded,
                                  iconColor: const Color(0xFF7C3AED),
                                  bgColor: const Color(0xFFEDE9FE),
                                  title: 'දිස්ත්‍රික්කය සහ නගරය',
                                  value:
                                      (_district.isNotEmpty || _city.isNotEmpty)
                                      ? "$_district${_city.isNotEmpty ? ' / $_city' : ''}"
                                      : 'සඳහන් කර නැත',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    Color? bgColor,
    required String title,
    required String value,
  }) {
    final effectiveBgColor = bgColor ?? iconColor.withValues(alpha: 0.12);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.isNotEmpty ? value : 'සඳහන් කර නැත',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
