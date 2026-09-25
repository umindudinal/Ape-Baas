import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'role_selection_screen.dart';
import 'customer_profile_screen.dart';
import 'provider_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isProvider;

  const SettingsScreen({super.key, this.isProvider = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _fullName = '';
  String _email = '';
  String _userId = '';
  String _profileImageUrl = '';

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'සිංහල (Sinhala)';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedImage = prefs.getString('profile_image_url') ?? '';
    String userId = prefs.getString('user_id') ?? '';

    if (mounted) {
      setState(() {
        _fullName =
            prefs.getString('full_name') ??
            (widget.isProvider ? 'සේවා සපයන්නා' : 'පාරිභෝගිකයා');
        _email = prefs.getString('email') ?? 'නොමැත';
        _userId = userId;
        _profileImageUrl = savedImage;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _selectedLanguage =
            prefs.getString('app_language') ?? 'සිංහල (Sinhala)';
      });
    }

    if (userId.isNotEmpty) {
      final profile = await ApiService.getUserProfile(userId);
      if (profile != null) {
        final dbImage = profile['profile_image_url']?.toString() ?? '';
        final dbName = profile['full_name']?.toString() ?? '';
        bool needUpdate = false;

        if (dbImage.isNotEmpty && dbImage != _profileImageUrl) {
          await prefs.setString('profile_image_url', dbImage);
          _profileImageUrl = dbImage;
          needUpdate = true;
        }
        if (dbName.isNotEmpty && dbName != _fullName) {
          await prefs.setString('full_name', dbName);
          _fullName = dbName;
          needUpdate = true;
        }
        if (needUpdate && mounted) {
          setState(() {});
        }
      }

      if (widget.isProvider) {
        final details = await ApiService.getProviderDetails(userId);
        if (details != null &&
            details['profile_image_url'] != null &&
            details['profile_image_url'].toString().isNotEmpty) {
          final provImage = details['profile_image_url'].toString();
          if (provImage != _profileImageUrl) {
            await prefs.setString('profile_image_url', provImage);
            if (mounted) {
              setState(() {
                _profileImageUrl = provImage;
              });
            }
          }
        }
      }
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

  Future<void> _toggleNotifications(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    setState(() => _notificationsEnabled = val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            val
                ? 'දැනුම්දීම් (Notifications) සක්‍රීය කරන ලදී.'
                : 'දැනුම්දීම් අක්‍රීය කරන ලදී.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleDarkMode(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', val);
    setState(() => _darkModeEnabled = val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            val ? 'Dark Theme සක්‍රීය විය.' : 'Light Theme සක්‍රීය විය.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'භාෂාව තෝරන්න',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Select Preferred Language',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(ctx),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Feature Notice Box
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.warningAmber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFB45309),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'සැලකිය යුතුයි: පද්ධතියේ සම්පූර්ණ භාෂාව වෙනස් කිරීමේ පහසුකම (Multi-language Support) ඉදිරි Update එකෙන් ලබාදෙනු ඇත.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF78350F),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildLanguageOptionCard(
                ctx: ctx,
                flag: '🇱🇰',
                title: 'සිංහල (Sinhala)',
                subtitle: 'ශ්‍රී ලංකාවේ ප්‍රධාන භාෂාව',
                value: 'සිංහල (Sinhala)',
              ),
              const SizedBox(height: 10),
              _buildLanguageOptionCard(
                ctx: ctx,
                flag: '🇬🇧',
                title: 'English',
                subtitle: 'International Language',
                value: 'English',
              ),
              const SizedBox(height: 10),
              _buildLanguageOptionCard(
                ctx: ctx,
                flag: '🇱🇰',
                title: 'தமிழ் (Tamil)',
                subtitle: 'தமிழ் மொழி සහාය',
                value: 'தமிழ் (Tamil)',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOptionCard({
    required BuildContext ctx,
    required String flag,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedLanguage == value;

    return InkWell(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_language', value);
        setState(() => _selectedLanguage = value);
        if (ctx.mounted) Navigator.pop(ctx);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'භාෂාව $value ලෙස වෙනස් කෙරිණි. (සම්පූර්ණ භාෂා සහාය ඊළඟ Update එකෙන් ලැබෙනු ඇත)',
              ),
              backgroundColor: AppColors.warningAmber,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : AppColors.cardBorder.withValues(alpha: 0.8),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF1E40AF)
                          : AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'මුරපදය වෙනස් කරන්න',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Change Account Password',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(dialogCtx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guidance Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'ඔබගේ ගිණුමේ ආරක්ෂාව සඳහා නව මුරපදය සඳහා අවම වශයෙන් අකුරු 6ක් භාවිතා කරන්න.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF1E40AF),
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: obscureOld,
                        decoration: InputDecoration(
                          labelText: 'වත්මන් මුරපදය (Current Password)',
                          labelStyle: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: AppColors.deepNavy,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureOld
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () =>
                                setDialogState(() => obscureOld = !obscureOld),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.cardBorder.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.deepNavy,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'වත්මන් මුරපදය ඇතුළත් කරන්න'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'නව මුරපදය (New Password)',
                          labelStyle: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.key_rounded,
                            size: 20,
                            color: AppColors.deepNavy,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () =>
                                setDialogState(() => obscureNew = !obscureNew),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.cardBorder.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.deepNavy,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'නව මුරපදයක් ඇතුළත් කරන්න';
                          }
                          if (val.length < 6) {
                            return 'අවම වශයෙන් අකුරු 6ක් තිබිය යුතුය';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'නව මුරපදය නැවත ඇතුළත් කරන්න',
                          labelStyle: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                            color: AppColors.deepNavy,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => setDialogState(
                              () => obscureConfirm = !obscureConfirm,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.cardBorder.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.deepNavy,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val != newPasswordController.text) {
                            return 'මුරපද සමාන නොවේ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.cardBorder,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'අවලංගුයි',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        if (_userId.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'පරිශීලක අංකය හමු නොවීය. නැවත ලොග් වන්න.',
                                              ),
                                              backgroundColor:
                                                  AppColors.errorRed,
                                            ),
                                          );
                                          return;
                                        }

                                        setDialogState(() => isLoading = true);

                                        final result =
                                            await ApiService.changePassword(
                                              userId: _userId,
                                              oldPassword:
                                                  oldPasswordController.text,
                                              newPassword:
                                                  newPasswordController.text,
                                            );

                                        setDialogState(() => isLoading = false);

                                        if (result['success'] == true) {
                                          if (dialogCtx.mounted) {
                                            Navigator.pop(dialogCtx);
                                          }
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['message'] ??
                                                      'මුරපදය සාර්ථකව යාවත්කාලීන කරන ලදී!',
                                                ),
                                                backgroundColor:
                                                    AppColors.successGreen,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['message'] ??
                                                      'මුරපදය වෙනස් කිරීමට නොහැකි විය.',
                                                ),
                                                backgroundColor:
                                                    AppColors.errorRed,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navyDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 1,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save කරන්න',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isProvider
                          ? 'රහස්‍යතා ප්‍රතිපත්තිය (Provider)'
                          : 'රහස්‍යතා ප්‍රතිපත්තිය (Customer)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Privacy Policy & Data Security',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(ctx),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyCard(
                  icon: Icons.shield_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: '1. පෞද්ගලික තොරතුරු ආරක්ෂාව',
                  desc: widget.isProvider
                      ? 'ඔබගේ නම, සේවා කාණ්ඩය, සේවා සපයන නගරය සහ දුරකථන අංකය පාරිභෝගිකයින් වෙත ඔබව සම්බන්ධ කරගැනීම සඳහා ප්‍රදර්ශනය කෙරේ.'
                      : 'ඔබගේ ලිපිනය සහ දුරකථන අංකය ආරක්ෂිතව තබාගන්නා අතර, ඔබ සේවා වෙන්කිරීමක් (Booking) සිදුකළ පසු පමණක් අදාළ සේවා සපයන්නා වෙත ලබාදේ.',
                ),
                const SizedBox(height: 10),
                _buildPolicyCard(
                  icon: Icons.badge_rounded,
                  iconColor: const Color(0xFF059669),
                  title: '2. හැඳුනුම්පත් (NIC) & ගිණුම් ආරක්ෂාව',
                  desc: widget.isProvider
                      ? 'ඔබ ලබාදෙන ජාතික හැඳුනුම්පත් ඡායාරූප Admin කණ්ඩායම විසින් ගිණුම තහවුරු කිරීම (Verification) සඳහා පමණක් භාවිතා කෙරෙන අතර කිසිදු බාහිර පාර්ශවයකට ප්‍රදර්ශනය නොකෙරේ.'
                      : 'ඔබගේ ගිණුම් විස්තර සහ මුරපද encrypted ක්‍රමයට පද්ධතියේ ඉතාම සුරක්ෂිතව තබාගනු ලැබේ.',
                ),
                const SizedBox(height: 10),
                _buildPolicyCard(
                  icon: Icons.star_half_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: '3. Ratings & Reviews ප්‍රතිපත්තිය',
                  desc: widget.isProvider
                      ? 'ඔබගේ සේවා තත්ත්වය සහ පාරිභෝගිකයින් ලබාදෙන Comment & Ratings පද්ධතියේ විනිවිදභාවය වෙනුවෙන් ප්‍රදර්ශනය කෙරේ.'
                      : 'ඔබ සේවා සපයන්නන් වෙනුවෙන් ලබාදෙන සමාලෝචන සහ Ratings පද්ධතියේ අනෙකුත් පාරිභෝගිකයින්ගේ දැනගැනීම සඳහා ප්‍රදර්ශනය වේ.',
                ),
                const SizedBox(height: 10),
                _buildPolicyCard(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: '4. දත්ත අලෙවි නොකිරීමේ සහතිකය',
                  desc:
                      'ඔබගේ කිසිදු පෞද්ගලික දත්තයක් හෝ තොරතුරක් කිසිදු තෙවන පාර්ශවයකට අලෙවි කිරීම හෝ ලබාදීම සිදු නොකෙරේ.',
                ),
                const SizedBox(height: 16),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                    child: const Text(
                      'තේරුණා (OK)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textDark,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final Uri launchUri = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'උදවු සහ සහාය (Help & Support)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '24/7 පාරිභෝගික සහාය කණ්ඩායම',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(ctx),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ඔබට පැනනගින ඕනෑම ගැටළුවක් සඳහා ඍජුවම අපගේ සේවා කණ්ඩායම හා සම්බන්ධ වන්න:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Hotline Contact Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.navySubtle,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.navyLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.deepNavy,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'හදිසි ඇමතුම් (Hotline)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '+94 77 123 4567',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _makePhoneCall('+94771234567'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepNavy,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        child: const Text(
                          'Call Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // WhatsApp Support Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp සහාය',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '+94 77 123 4567',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _openWhatsApp('94771234567'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        child: const Text(
                          'WhatsApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Email Support Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.email_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ඊමේල් ලිපිනය (Email)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1D4ED8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'support@hondabass.lk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _sendEmail('support@hondabass.lk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        child: const Text(
                          'Email Us',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // FAQ Quick Accordion Section Title
                const Text(
                  'නිතර අසන පැන්න (Quick FAQs)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 10),

                // FAQ Item 1: How to book
                _buildFaqTile(
                  question: '1. සේවාවක් වෙන්කර ගන්නේ කෙසේද?',
                  answer:
                      'ප්‍රධාන පිටුවෙන් ඔබ අවශ්‍ය සේවා කාණ්ඩය (Plumber, Electrician ආදී) තෝරා ඔබට ආසන්න බාස් කෙනෙකු තෝරා Booking ඉල්ලීම යවන්න.',
                ),
                const SizedBox(height: 8),

                // FAQ Item 2: Payments
                _buildFaqTile(
                  question: '2. ගෙවීම් සිදු කරන්නේ කෙසේද?',
                  answer:
                      'සේවාව සම්පූර්ණයෙන්ම අවසන් වූ පසු, බාස් වෙත ඍජුවම මුදල් ගෙවීම හෝ ඇප් එක මගින් ගෙවීම් තහවුරු කළ හැක.',
                ),
                const SizedBox(height: 8),

                // FAQ Item 3: Safety
                _buildFaqTile(
                  question: '3. සේවා සපයන්නන්ගේ විශ්වාසනීයත්වය?',
                  answer:
                      'සියලුම සේවා සපයන්නන්ගේ ජාතික හැඳුනුම්පත (NIC) පද්ධතියේ Admin කණ්ඩායම මගින් තහවුරු කර (Verified) ඇත.',
                ),
                const SizedBox(height: 16),

                // Operating Hours Note Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.warningAmber.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: AppColors.warningAmber,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'පාරිභෝගික සේවා පැය: සතියේ සෑම දිනකම පෙ.ව. 8:00 - ප.ව. 8:00 (24/7 හදිසි සහාය)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF78350F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.deepNavy,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'වසා දමන්න (Close)',
                      style: TextStyle(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: const BoxDecoration(
            color: AppColors.navyDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'අපේ බාස් (Ape Baas)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      'v1.0.0 Pro Edition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'Made in Sri Lanka 🇱🇰',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Platform Summary Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.navySubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.navyLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'ශ්‍රී ලංකාවේ සියලුම ගෘහාශ්‍රිත සහ වෘත්තීය සේවාවන් (Plumbing, Electrical, Carpentry, Masonry, Painting ආදී) විශ්වාසනීයව, නිවැරදිව සහ ක්ෂණිකව එකම තැනකින් ලබාගැනීම සඳහා නිර්මාණය කරන ලද ප්‍රමුඛතම ඩිජිටල් සේවා පද්ධතිය.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textDark,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ප්‍රධාන විශේෂාංග (Core Features)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Feature Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeatureBadge(
                      Icons.verified_rounded,
                      'Verified Providers',
                      const Color(0xFF059669),
                      const Color(0xFFD1FAE5),
                    ),
                    _buildFeatureBadge(
                      Icons.bolt_rounded,
                      'Instant Booking',
                      const Color(0xFFD97706),
                      const Color(0xFFFEF3C7),
                    ),
                    _buildFeatureBadge(
                      Icons.chat_rounded,
                      'Realtime Chat',
                      const Color(0xFF2563EB),
                      const Color(0xFFEFF6FF),
                    ),
                    _buildFeatureBadge(
                      Icons.star_rounded,
                      'Ratings & Reviews',
                      const Color(0xFF7C3AED),
                      const Color(0xFFEDE9FE),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEF2F6)),
                const SizedBox(height: 14),

                // Security & Tech Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'End-to-End Encrypted & Secure Platform',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Copyright Text
                const Text(
                  '© 2026 Ape Baas Services.\nAll Rights Reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.deepNavy,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'වසා දමන්න (Close)',
                      style: TextStyle(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(
    IconData icon,
    String label,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                  color: AppColors.errorRed.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ගිණුමෙන් ඉවත්වන්න',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Log Out Confirmation',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(ctx, false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.errorRed,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ඔබට නැවත ඇතුළු වීමට ඔබගේ Email සහ Password භාවිතා කිරීමට සිදුවේ.',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'ඔබට සැබවින්ම මෙතැනින් ඉවත්වීමට අවශ්‍යද?',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.navyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.cardBorder,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'නැත',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'ඉවත්වන්න',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider(_profileImageUrl);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: Column(
        children: [
          // Custom Top Header Bar (Matching Bookings, Messages, Home screens)
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
                  const Expanded(
                    child: Text(
                      'සැකසුම් (Settings)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: _logout,
                    tooltip: 'ගිණුමෙන් ඉවත්වන්න (Logout)',
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Settings Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Header Card Summary (Clickable to view Profile)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepNavy.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.isProvider
                                  ? const ProviderProfileScreen()
                                  : const CustomerProfileScreen(),
                            ),
                          );
                          _loadSettings();
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.navySubtle,
                                backgroundImage: imageProvider,
                                child: imageProvider == null
                                    ? Text(
                                        _fullName.isNotEmpty
                                            ? _fullName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.deepNavy,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fullName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _email,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navySubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.isProvider ? 'Provider' : 'Customer',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.deepNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Section 1: General Preferences
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'සාමාන්‍ය සැකසුම් (General Preferences)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  _buildSettingsContainer([
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'දැනුම්දීම් (Notifications)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        'නව වෙන්කිරීම් සහ පණිවුඩ නිවේදන ලබාගන්න',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      value: _notificationsEnabled,
                      activeThumbColor: const Color(0xFFD97706),
                      onChanged: _toggleNotifications,
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF1F5F9),
                    ),
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.dark_mode_rounded,
                          color: Color(0xFF7C3AED),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Dark Mode (අඳුරු තේමාව)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        'ඇප් එකේ තේමාව වෙනස් කරන්න',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      value: _darkModeEnabled,
                      activeThumbColor: const Color(0xFF7C3AED),
                      onChanged: _toggleDarkMode,
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF1F5F9),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'භාෂාව (Language)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        _selectedLanguage,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showLanguageDialog,
                    ),
                  ]),

                  const SizedBox(height: 22),

                  // Section 2: Account & Security
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'ගිණුම සහ ආරක්ෂාව (Account & Security)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  _buildSettingsContainer([
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'මුරපදය වෙනස් කරන්න',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        'Change Account Password',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF1F5F9),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_outlined,
                          color: Color(0xFF059669),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'රහස්‍යතා ප්‍රතිපත්තිය',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        'Privacy Policy & Terms',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showPrivacyPolicyDialog,
                    ),
                  ]),

                  const SizedBox(height: 22),

                  // Section 3: Support & About
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'සහාය සහ විස්තර (Support & About)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  _buildSettingsContainer([
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: Color(0xFFE11D48),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'උදවු සහ පාරිභෝගික සහාය',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        'Help & Customer Support',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showHelpSupportDialog,
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF1F5F9),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_rounded,
                          color: Color(0xFF4F46E5),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'අපේ බාස් ඇප් එක ගැන',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: const Text(
                        'App Version v1.0.0',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showAboutDialog,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
