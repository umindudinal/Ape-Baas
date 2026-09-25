import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'edit_profile_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _category = 'සඳහන් කර නැත';
  String _nic = 'සඳහන් කර නැත';
  String _nicFrontUrl = '';
  String _nicBackUrl = '';
  int _experience = 0;
  double _radius = 0.0;
  bool _isVerified = false;
  String _verificationStatus = 'Pending';
  String _rejectionReason = '';
  String _userId = '';
  String _profileImageUrl = '';
  bool _isLoading = true;
  List<String> _portfolioImages = [];

  Map<String, dynamic>? _providerRawData;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    if (mounted) {
      setState(() {
        _fullName = prefs.getString('full_name') ?? 'සේවා සපයන්නා';
        _email = prefs.getString('email') ?? 'නොමැත';
        _phone = prefs.getString('phone') ?? 'නොමැත';
        _address = prefs.getString('address') ?? 'නොමැත';
        _profileImageUrl = prefs.getString('profile_image_url') ?? '';
        _userId = userId;
      });
    }

    if (userId.isNotEmpty) {
      final details = await ApiService.getProviderDetails(userId);
      if (details != null && mounted) {
        setState(() {
          _providerRawData = details;
          if (details['full_name'] != null && details['full_name'].toString().isNotEmpty) {
            _fullName = details['full_name'];
          }
          if (details['email'] != null && details['email'].toString().isNotEmpty) {
            _email = details['email'];
          }
          if (details['phone'] != null && details['phone'].toString().isNotEmpty) {
            _phone = details['phone'];
          }
          if (details['address'] != null && details['address'].toString().isNotEmpty) {
            _address = details['address'];
          }
          if (details['profile_image_url'] != null && details['profile_image_url'].toString().isNotEmpty) {
            _profileImageUrl = details['profile_image_url'];
          }
          _category = details['service_category'] ?? 'සඳහන් කර නැත';
          _nic = details['nic_number'] ?? 'සඳහන් කර නැත';
          _nicFrontUrl = details['nic_front_url'] ?? '';
          _nicBackUrl = details['nic_back_url'] ?? '';
          _experience = details['experience_years'] ?? 0;
          _radius = (details['working_radius_km'] ?? 0.0).toDouble();
          _isVerified = details['is_verified'] ?? false;
          _verificationStatus = details['verification_status'] ?? (details['is_verified'] == true ? 'Approved' : 'Pending');
          _rejectionReason = details['rejection_reason'] ?? '';
          if (details['portfolio_images'] is List) {
            _portfolioImages = List<String>.from(details['portfolio_images']);
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
          currentProfile: _providerRawData ?? {
            'full_name': _fullName,
            'phone': _phone,
            'email': _email,
            'address': _address,
            'service_category': _category,
            'experience_years': _experience,
            'working_radius_km': _radius.toInt(),
            'id': _userId,
          },
          isProvider: true,
        ),
      ),
    );
    if (refreshed == true) {
      _loadProviderData();
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
      setState(() {
        _isLoading = false;
        if (res['success']) {
          _profileImageUrl = newImageUrl;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: res['success'] ? AppColors.successGreen : AppColors.errorRed,
        ),
      );
    }
  }

  void _showProfileImagePickerModal() {
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.navySubtle, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.deepNavy),
                ),
                title: const Text('කැමරාව මඟින් ඡායාරූපයක් ගන්න', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textDark)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final img = await _pickImageSource(ImageSource.camera, isNic: false);
                    if (img != null) {
                      _updateProfilePhoto(img);
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
                  decoration: BoxDecoration(color: AppColors.navySubtle, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.deepNavy),
                ),
                title: const Text('ගැලරියෙන් තෝරන්න', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textDark)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final img = await _pickImageSource(ImageSource.gallery, isNic: false);
                    if (img != null) {
                      _updateProfilePhoto(img);
                    }
                  } catch (e) {
                    debugPrint("❌ Gallery Error: $e");
                  }
                },
              ),
              const Divider(height: 10, color: Color(0xFFEEF2F6)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.navySubtle, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.link_rounded, color: AppColors.deepNavy),
                ),
                title: const Text('URL ලෙස ඇතුළත් කරන්න', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textDark)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showProfileUrlInputDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileUrlInputDialog() {
    final urlController = TextEditingController(text: _profileImageUrl.startsWith('http') ? _profileImageUrl : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Image URL ඇතුළත් කරන්න', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: 'https://example.com/avatar.jpg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('අවලංගුයි', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                _updateProfilePhoto(urlController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepNavy),
            child: const Text('Save කරන්න', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _addPortfolioImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 65,
        maxWidth: 800,
      );

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        setState(() {
          _portfolioImages.add(base64Image);
        });

        final res = await ApiService.updateProviderPortfolio(
          providerId: _userId,
          portfolioImages: _portfolioImages,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'ඡායාරූපය සාර්ථකව එක් කරන ලදී!'),
              backgroundColor: res['success'] ? AppColors.successGreen : AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Add Portfolio Image Error: $e");
    }
  }

  Future<void> _deletePortfolioImage(int index) async {
    setState(() {
      _portfolioImages.removeAt(index);
    });

    final res = await ApiService.updateProviderPortfolio(
      providerId: _userId,
      portfolioImages: _portfolioImages,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['success'] ? 'ඡායාරූපය ඉවත් කරන ලදී!' : 'ඉවත් කිරීමට නොහැකි විය.'),
          backgroundColor: res['success'] ? AppColors.deepNavy : AppColors.errorRed,
        ),
      );
    }
  }

  void _showImagePickerOptions({required bool isFront, required Function(String) onImageSelected}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFront ? 'NIC ඉදිරිපස ඡායාරූපය (Front Image)' : 'NIC පසුපස ඡායාරූපය (Back Image)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'ඡායාරූපය ලබාගත් පසු අවශ්‍ය පරිදි Crop කරගත හැක',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.navySubtle, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.deepNavy),
                ),
                title: const Text('කැමරාව මඟින් Photo ගෙන Crop කරන්න', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final img = await _pickImageSource(ImageSource.camera, isNic: true);
                  if (img != null) {
                    onImageSelected(img);
                  }
                },
              ),
              const Divider(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.navySubtle, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.deepNavy),
                ),
                title: const Text('ගැලරියෙන් තෝරා Crop කරන්න', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final img = await _pickImageSource(ImageSource.gallery, isNic: true);
                  if (img != null) {
                    onImageSelected(img);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickImageSource(ImageSource source, {bool isNic = true}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
      );

      if (pickedFile != null && mounted) {
        final Uint8List bytes;
        if (!kIsWeb) {
          final CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: isNic ? 'NIC ඡායාරූපය කපා සකස් කරන්න (Crop NIC)' : 'ඡායාරූපය කපා සකස් කරන්න (Crop Photo)',
                toolbarColor: AppColors.navyDark,
                toolbarWidgetColor: Colors.white,
                activeControlsWidgetColor: AppColors.navyAccent,
                initAspectRatio: isNic ? CropAspectRatioPreset.ratio16x9 : CropAspectRatioPreset.square,
                lockAspectRatio: false,
                aspectRatioPresets: isNic
                    ? [
                        CropAspectRatioPreset.ratio16x9,
                        CropAspectRatioPreset.ratio4x3,
                        CropAspectRatioPreset.original,
                        CropAspectRatioPreset.square,
                      ]
                    : [
                        CropAspectRatioPreset.square,
                        CropAspectRatioPreset.ratio4x3,
                        CropAspectRatioPreset.original,
                      ],
              ),
              IOSUiSettings(
                title: isNic ? 'NIC ඡායාරූපය කපා සකස් කරන්න (Crop NIC)' : 'ඡායාරූපය කපා සකස් කරන්න (Crop Photo)',
                aspectRatioPresets: isNic
                    ? [
                        CropAspectRatioPreset.ratio16x9,
                        CropAspectRatioPreset.ratio4x3,
                        CropAspectRatioPreset.original,
                        CropAspectRatioPreset.square,
                      ]
                    : [
                        CropAspectRatioPreset.square,
                        CropAspectRatioPreset.ratio4x3,
                        CropAspectRatioPreset.original,
                      ],
              ),
            ],
          );

          if (croppedFile != null) {
            bytes = await croppedFile.readAsBytes();
          } else {
            bytes = await pickedFile.readAsBytes();
          }
        } else {
          // On Web/Chrome read bytes directly
          bytes = await pickedFile.readAsBytes();
        }

        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      }
    } catch (e) {
      debugPrint("❌ Image Pick/Crop Error: $e");
    }
    return null;
  }

  void _showNicUploadDialog() {
    if (_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ඔබගේ ගිණුම දැනටමත් Verify කර ඇත. NIC ඡායාරූප නැවත වෙනස් කිරීමට අවශ්‍ය නැත.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      return;
    }

    String tempFrontUrl = _nicFrontUrl;
    String tempBackUrl = _nicBackUrl;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'හැඳුනුම්පත් (NIC) ඡායාරූප',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Admin Verification සඳහා NIC ඡායාරූප 2ක්',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5),
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
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guidance Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'කැමරාවෙන් පැහැදිලි ඡායාරූපයක් ගන්න නැතහොත් ගැලරියෙන් NIC ඡායාරූප 2 තෝරන්න.',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF), height: 1.35, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NIC Front Card
                  const Text('NIC ඉදිරිපස ඡායාරූපය (Front Image):', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showImagePickerOptions(
                        isFront: true,
                        onImageSelected: (img) {
                          setDialogState(() {
                            tempFrontUrl = img;
                          });
                        },
                      );
                    },
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: tempFrontUrl.isNotEmpty ? AppColors.successGreen : AppColors.cardBorder,
                          width: tempFrontUrl.isNotEmpty ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: tempFrontUrl.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: _buildNicImageWidget(tempFrontUrl),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('වෙනස් කරන්න', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.navySubtle,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_a_photo_rounded, size: 26, color: AppColors.deepNavy),
                                ),
                                const SizedBox(height: 8),
                                const Text('NIC Front ඡායාරූපය තෝරන්න', style: TextStyle(fontSize: 12, color: AppColors.navyDark, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                const Text('කැමරාව / ගැලරිය (Click to Upload)', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // NIC Back Card
                  const Text('NIC පසුපස ඡායාරූපය (Back Image):', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showImagePickerOptions(
                        isFront: false,
                        onImageSelected: (img) {
                          setDialogState(() {
                            tempBackUrl = img;
                          });
                        },
                      );
                    },
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: tempBackUrl.isNotEmpty ? AppColors.successGreen : AppColors.cardBorder,
                          width: tempBackUrl.isNotEmpty ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: tempBackUrl.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: _buildNicImageWidget(tempBackUrl),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('වෙනස් කරන්න', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.navySubtle,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_a_photo_rounded, size: 26, color: AppColors.deepNavy),
                                ),
                                const SizedBox(height: 8),
                                const Text('NIC Back ඡායාරූපය තෝරන්න', style: TextStyle(fontSize: 12, color: AppColors.navyDark, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                const Text('කැමරාව / ගැලරිය (Click to Upload)', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                          child: const Text('අවලංගුයි', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (tempFrontUrl.isEmpty && tempBackUrl.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('කරුණාකර අවම වශයෙන් එක් ඡායාරූපයක් හෝ තෝරන්න')),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSubmitting = true);

                                  final res = await ApiService.updateProviderNicDocuments(
                                    providerId: _userId,
                                    nicFrontUrl: tempFrontUrl,
                                    nicBackUrl: tempBackUrl,
                                  );

                                  setDialogState(() => isSubmitting = false);

                                  if (!context.mounted || !ctx.mounted) return;
                                  if (res['success'] == true) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res['message']), backgroundColor: AppColors.successGreen),
                                    );
                                    _loadProviderData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res['message']), backgroundColor: AppColors.errorRed),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 1,
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Submit කරන්න', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNicImageWidget(String source) {
    if (source.isEmpty) {
      return const Icon(Icons.credit_card_rounded, size: 40, color: AppColors.textMuted);
    }

    if (source.startsWith('data:image') || !source.startsWith('http')) {
      try {
        final base64Str = source.contains(',') ? source.split(',').last : source;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
        );
      } catch (e) {
        return const Icon(Icons.broken_image_rounded, color: AppColors.textMuted);
      }
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 12, 14, 16),
              decoration: const BoxDecoration(
                color: AppColors.navyDark,
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 12),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'ආපසු (Back)',
                    ),
                  ],
                  const Expanded(
                    child: Text(
                      'සේවා සපයන්නාගේ ගිණුම',
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
                ? const Center(child: CircularProgressIndicator(color: AppColors.deepNavy))
                : RefreshIndicator(
                    onRefresh: _loadProviderData,
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
                        children: [
                          GestureDetector(
                            onTap: _showProfileImagePickerModal,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _isVerified
                                        ? AppColors.emeraldGradient
                                        : AppColors.brandCombinedGradient,
                                  ),
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _getImageProvider(_profileImageUrl),
                                    child: _getImageProvider(_profileImageUrl) == null
                                        ? CircleAvatar(
                                            radius: 42,
                                            backgroundColor: AppColors.navySubtle,
                                            child: Text(
                                              _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'P',
                                              style: const TextStyle(
                                                fontSize: 34,
                                                fontWeight: FontWeight.bold,
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
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
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
                                if (_isVerified)
                                  Positioned(
                                    top: 0,
                                    right: 0,
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
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _fullName.isNotEmpty ? _fullName : 'සේවා සපයන්නා',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (_isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 22),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Verification Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _verificationStatus == 'Rejected'
                                  ? const Color(0xFFFFF1F2)
                                  : (_isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _verificationStatus == 'Rejected'
                                    ? AppColors.errorRed.withValues(alpha: 0.3)
                                    : (_isVerified ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.warningAmber.withValues(alpha: 0.3)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _verificationStatus == 'Rejected'
                                      ? Icons.cancel_rounded
                                      : (_isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded),
                                  size: 16,
                                  color: _verificationStatus == 'Rejected'
                                      ? AppColors.errorRed
                                      : (_isVerified ? AppColors.successGreen : AppColors.warningAmber),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _verificationStatus == 'Rejected'
                                        ? 'ගිණුම අනුමත නැත (Rejected)'
                                        : (_isVerified ? 'තහවුරු කළ ගිණුමකි (Verified)' : 'තහවුරු කරමින් පවතී (Pending)'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _verificationStatus == 'Rejected'
                                          ? AppColors.errorRed
                                          : (_isVerified ? AppColors.successGreen : const Color(0xFF92400E)),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🛡️ NIC Document Verification Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: _isVerified
                              ? AppColors.successGreen.withValues(alpha: 0.35)
                              : AppColors.cardBorder.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
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
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.badge_rounded, color: Color(0xFF2563EB), size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'හැඳුනුම්පත් (NIC) තහවුරු කිරීම',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'National Identity Document',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _verificationStatus == 'Rejected'
                                      ? const Color(0xFFFFF1F2)
                                      : (_isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _verificationStatus == 'Rejected'
                                        ? AppColors.errorRed.withValues(alpha: 0.3)
                                        : (_isVerified ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.warningAmber.withValues(alpha: 0.3)),
                                  ),
                                ),
                                child: Text(
                                  _verificationStatus == 'Rejected'
                                      ? 'Rejected'
                                      : (_isVerified ? 'Verified' : 'Pending'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _verificationStatus == 'Rejected'
                                        ? AppColors.errorRed
                                        : (_isVerified ? AppColors.successGreen : const Color(0xFF92400E)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                          ),

                          // 📢 Dynamic Status Guidance Banner (Upload කිරීමට පෙර සහ Pending/Rejected පණිවිඩය - Verified වූ පසු පෙන්නුම් නොකෙරේ)
                          if (!_isVerified) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.5),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _verificationStatus == 'Rejected'
                                    ? const Color(0xFFFFF1F2)
                                    : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                        ? const Color(0xFFEFF6FF)
                                        : const Color(0xFFFFFBEB)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _verificationStatus == 'Rejected'
                                      ? AppColors.errorRed.withValues(alpha: 0.3)
                                      : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                          ? const Color(0xFFBFDBFE)
                                          : AppColors.warningAmber.withValues(alpha: 0.4)),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _verificationStatus == 'Rejected'
                                        ? Icons.gpp_bad_rounded
                                        : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                            ? Icons.hourglass_top_rounded
                                            : Icons.info_outline_rounded),
                                    size: 20,
                                    color: _verificationStatus == 'Rejected'
                                        ? AppColors.errorRed
                                        : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFD97706)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _verificationStatus == 'Rejected'
                                          ? 'ඔබගේ NIC ඡායාරූප Admin විසින් ප්‍රතික්ෂේප කර ඇත.${_rejectionReason.isNotEmpty ? ' (හේතුව: $_rejectionReason)' : ''}. කරුණාකර නැවත නිවැරදි ඡායාරූප ලබාදෙන්න.'
                                          : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                              ? 'ඔබගේ NIC ඡායාරූප 2 Submit කර ඇත. පරිපාලක (Admin) විසින් ගිණුම පරීක්ෂා කර අනුමත (Approve) කරන තෙක් රැඳී සිටින්න.'
                                              : 'ඔබගේ ගිණුම තහවුරු කිරීම (Verification) සඳහා කරුණාකර ජාතික හැඳුනුම්පතෙහි (NIC) ඉදිරිපස සහ පිටුපස ඡායාරූප 2 ලබාදෙන්න.'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: _verificationStatus == 'Rejected'
                                            ? AppColors.errorRed
                                            : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                                ? const Color(0xFF1E40AF)
                                                : const Color(0xFF92400E)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // NIC Front & Back Thumbnails Row
                          Row(
                            children: [
                              // Front Image Thumbnail
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('NIC ඉදිරිපස (Front):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 105,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.navyLight.withValues(alpha: 0.3)),
                                      ),
                                      child: _nicFrontUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: _buildNicImageWidget(_nicFrontUrl),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.credit_card_rounded, size: 30, color: AppColors.textMuted),
                                                SizedBox(height: 4),
                                                Text('ඡායාරූපයක් නැත', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Back Image Thumbnail
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('NIC පසුපස (Back):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 105,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.navyLight.withValues(alpha: 0.3)),
                                      ),
                                      child: _nicBackUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: _buildNicImageWidget(_nicBackUrl),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.credit_card_rounded, size: 30, color: AppColors.textMuted),
                                                SizedBox(height: 4),
                                                Text('ඡායාරූපයක් නැත', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Upload / Re-upload Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _showNicUploadDialog,
                              icon: Icon(
                                _isVerified
                                    ? Icons.verified_user_rounded
                                    : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                        ? Icons.edit_note_rounded
                                        : Icons.add_a_photo_rounded),
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                _isVerified
                                    ? '✓ ගිණුම තහවුරු කර ඇත (Verified Account)'
                                    : ((_nicFrontUrl.isNotEmpty && _nicBackUrl.isNotEmpty)
                                        ? 'NIC ඡායාරූප යාවත්කාලීන කරන්න'
                                        : '+ NIC ඡායාරූප 2 ලබාදෙන්න (Front & Back)'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isVerified ? AppColors.successGreen : AppColors.navyDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Personal & Professional Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                                  'වෘත්තීය සහ පුද්ගලික විස්තර',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                ),
                              ),
                              InkWell(
                                onTap: _navigateToEditProfile,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.navySubtle,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.navyLight.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.edit_outlined, size: 14, color: AppColors.deepNavy),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1, color: Color(0xFFEEF2F6)),
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
                            icon: Icons.category_rounded,
                            iconColor: const Color(0xFF0284C7),
                            bgColor: const Color(0xFFE0F2FE),
                            title: 'සේවා කාණ්ඩය (Category)',
                            value: _category,
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
                            title: 'ලිපිනය / දිස්ත්‍රික්කය',
                            value: _address,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoTile(
                            icon: Icons.near_me_rounded,
                            iconColor: const Color(0xFF4F46E5),
                            bgColor: const Color(0xFFEEF2FF),
                            title: 'සේවා සපයන සීමාව',
                            value: 'කි.මී. ${_radius.toInt()} ක සීමාව',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoTile(
                            icon: Icons.workspace_premium_rounded,
                            iconColor: const Color(0xFFB45309),
                            bgColor: const Color(0xFFFEF3C7),
                            title: 'අත්දැකීම් කාලය',
                            value: 'වසර $_experience ක පළපුරුද්ද',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoTile(
                            icon: Icons.badge_rounded,
                            iconColor: const Color(0xFF0D9488),
                            bgColor: const Color(0xFFCCFBF1),
                            title: 'ජාතික හැඳුනුම්පත් අංකය (NIC)',
                            value: _nic,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Work Portfolio / Past Work Gallery Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                                  'කරන ලද වැඩවල ඡායාරූප (Work Portfolio)',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.navySubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_portfolioImages.length} Photos',
                                  style: const TextStyle(fontSize: 11, color: AppColors.deepNavy, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                          ),

                          if (_portfolioImages.isNotEmpty) ...[
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _portfolioImages.length,
                                itemBuilder: (context, index) {
                                  final imgStr = _portfolioImages[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 110,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            width: 110,
                                            height: 110,
                                            color: AppColors.surfaceBg,
                                            child: imgStr.startsWith('data:image')
                                                ? Image.memory(
                                                    Uri.parse(imgStr).data!.contentAsBytes(),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    imgStr,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () => _deletePortfolioImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.errorRed,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _addPortfolioImage,
                              icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 20),
                              label: const Text(
                                '+ කළ වැඩවල ඡායාරූපයක් එකතු කරන්න',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepNavy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(
                value.isNotEmpty ? value : 'සඳහන් කර නැත',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
