import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

// Top-level constant for 50 service categories
const List<Map<String, String>> editProfileCategoriesList = [
  {'value': 'Masonry', 'label': 'මේසන් වැඩ - Masonry'},
  {'value': 'Carpentry', 'label': 'වඩු වැඩ - Carpentry'},
  {'value': 'Plumbing', 'label': 'ජලනල වැඩ - Plumbing'},
  {'value': 'Electrical Work', 'label': 'විදුලි වැඩ - Electrical Work'},
  {'value': 'Painting', 'label': 'තීන්ත ගෑමේ වැඩ - Painting'},
  {'value': 'Tiling', 'label': 'ටයිල් ඇල්ලීමේ වැඩ - Tiling'},
  {'value': 'Welding', 'label': 'පෑස්සුම් වැඩ - Welding'},
  {'value': 'Aluminum Fabrication', 'label': 'ඇලුමිනියම් වැඩ - Aluminum Fabrication'},
  {'value': 'Roofing', 'label': 'වහල සෙවිලි කිරීමේ වැඩ - Roofing'},
  {'value': 'A/C Repair', 'label': 'වායු සමීකරණ අලුත්වැඩියාව - A/C Repair'},
  {'value': 'Landscaping', 'label': 'ගෙවතු අලංකරණය - Landscaping'},
  {'value': 'Ceiling Installation', 'label': 'සිවිලිම් ගැසීමේ වැඩ - Ceiling Installation'},
  {'value': 'Cleaning Services', 'label': 'පවිත්ර කිරීමේ සේවා - Cleaning Services'},
  {'value': 'Appliance Repair', 'label': 'ගෘහ උපකරණ අලුත්වැඩියාව - Appliance Repair'},
  {'value': 'Metalworking', 'label': 'යකඩ සහ ලෝහ වැඩ - Metalworking'},
  {'value': 'CCTV & Security Systems', 'label': 'CCTV සහ ආරක්ෂක පද්ධති - CCTV & Security'},
  {'value': 'Pest Control', 'label': 'පළිබෝධ මර්දනය - Pest Control'},
  {'value': 'Glasswork', 'label': 'වීදුරු වැඩ - Glasswork'},
  {'value': 'Waterproofing', 'label': 'ජල කාන්දු වැළැක්වීම - Waterproofing'},
  {'value': 'Interlock Paving', 'label': 'ඉන්ටර්ලොක් ගල් ඇල්ලීම - Interlock Paving'},
  {'value': 'Curtains & Blinds', 'label': 'තිර රෙදි සවි කිරීම - Curtains & Blinds'},
  {'value': 'Wood Polishing', 'label': 'ලී භාණ්ඩ පොලිෂ් කිරීම - Wood Polishing'},
  {'value': 'Solar Panel Installation', 'label': 'සූර්ය පැනල සවි කිරීම - Solar Panel Installation'},
  {'value': 'Moving Services', 'label': 'භාණ්ඩ ප්රවාහනය - Moving Services'},
  {'value': 'Gypsum Work', 'label': 'ජිප්සම් වැඩ - Gypsum Work'},
  {'value': 'Tree Cutting', 'label': 'ගස් කැපීම - Tree Cutting'},
  {'value': 'IT & Network Setup', 'label': 'පරිගණක සහ ජාලකරණ සේවා - IT & Network Setup'},
  {'value': 'Wallpaper Installation', 'label': 'වෝල්පේපර් ඇලවීම - Wallpaper Installation'},
  {'value': 'Gully Bowser Services', 'label': 'ගලි බවුසර් සේවා - Gully Bowser Services'},
  {'value': 'Water Tank Cleaning', 'label': 'ජල ටැංකි පිරිසිදු කිරීම - Water Tank Cleaning'},
  {'value': 'Well Digging & Cleaning', 'label': 'ළිං කැපීම සහ පිරිසිදු කිරීම - Well Digging & Cleaning'},
  {'value': 'Pool Maintenance', 'label': 'පිහිනුම් තටාක නඩත්තුව - Pool Maintenance'},
  {'value': 'Deep Cleaning', 'label': 'කාපට් සහ සෝෆා පිරිසිදු කිරීම - Deep Cleaning'},
  {'value': 'Concrete & Slab Work', 'label': 'කොන්ක්රීට් සහ ස්ලැබ් වැඩ - Concrete & Slab Work'},
  {'value': 'Gutter Installation', 'label': 'වැහි පීලි සවි කිරීම - Gutter Installation'},
  {'value': 'Fencing', 'label': 'වැටවල් ඉදි කිරීම - Fencing'},
  {'value': 'Demolition Services', 'label': 'ගොඩනැගිලි කඩා ඉවත් කිරීම - Demolition Services'},
  {'value': 'Upholstery', 'label': 'කුෂන් වැඩ - Upholstery'},
  {'value': 'Carpet Installation', 'label': 'කාපට් එළීම - Carpet Installation'},
  {'value': 'Water Pump Repair', 'label': 'වතුර මෝටර් අලුත්වැඩියාව - Water Pump Repair'},
  {'value': 'Generator Repair', 'label': 'ජෙනරේටර් අලුත්වැඩියාව - Generator Repair'},
  {'value': 'Gas Stove Repair', 'label': 'ගෑස් උදුන් අලුත්වැඩියාව - Gas Stove Repair'},
  {'value': 'Interior Designing', 'label': 'අභ්යන්තර අලංකරණය - Interior Designing'},
  {'value': 'Locksmith Services', 'label': 'යතුරු සෑදීම සහ අගුලු අලුත්වැඩියාව - Locksmith Services'},
  {'value': 'Garbage & Debris Removal', 'label': 'කසළ සහ සුන්බුන් ඉවත් කිරීම - Garbage Removal'},
  {'value': 'TV Antenna & Dish Installation', 'label': 'රූපවාහිනී ඩිෂ් සවි කිරීම - TV Dish & Antenna'},
  {'value': 'Smart Home Setup', 'label': 'ස්මාර්ට් නිවාස පද්ධති - Smart Home Setup'},
  {'value': 'Awnings & Canopies', 'label': 'කැනපි සහ ආවරණ සවි කිරීම - Awnings & Canopies'},
  {'value': 'Ventilation & Exhaust Setup', 'label': 'වාතාශ්රය සහ එක්සෝස්ට් සවි කිරීම - Ventilation Setup'},
  {'value': 'Fire Safety Systems', 'label': 'ගිනි ආරක්ෂක පද්ධති - Fire Safety Systems'},
];

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;
  final bool isProvider;

  const EditProfileScreen({
    super.key,
    required this.currentProfile,
    this.isProvider = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _experienceController;
  late TextEditingController _radiusController;

  Set<String> _selectedCategories = {'Masonry'};
  String _selectedDistrict = 'පොළොන්නරුව (Polonnaruwa)';
  late String _selectedCity;
  bool _isLoading = false;
  List<String> _portfolioImages = [];
  final ImagePicker _picker = ImagePicker();

  final Map<String, List<String>> _districtCities = {
    'කොළඹ (Colombo)': ['කොළඹ නගරය', 'නුවර පාර', 'නුගේගොඩ', 'මහරගම', 'දෙහිවල', 'මොරටුව', 'කඩුවෙල', 'හෝමාගම', 'කෝට්ටේ', 'බොරුල්ල', 'බත්තරමුල්ල'],
    'ගම්පහ (Gampaha)': ['ගම්පහ නගරය', 'මීගමුව', 'කිරිබත්ගොඩ', 'කැලණිය', 'වත්තල', 'ජාඇල', 'නිට්ටඹුව', 'මිණුවන්ගොඩ', 'කඩවත'],
    'කළුතර (Kalutara)': ['කළුතර නගරය', 'පානදුර', 'බණ්ඩාරගම', 'හොරණ', 'මතුගම', 'බෙරුවල', 'අලුත්ගම'],
    'මහනුවර (Kandy)': ['මහනුවර නගරය', 'පේරාදෙණිය', 'කටුගස්තොට', 'ගම්පොළ', 'නාවලපිටිය', 'දිගන', 'කුණ්ඩසාලේ'],
    'මාතලේ (Matale)': ['මාතලේ නගරය', 'දඹුල්ල', 'සිගිරිය', 'ගාලේවෙල', 'උකුවෙල', 'රත්තොට'],
    'නුවරඑළිය (Nuwara Eliya)': ['නුවරඑළිය නගරය', 'හැටන්', 'ගිනිගත්හේන', 'වලපනේ', 'කොත්මලේ', 'රාගල'],
    'ගාල්ල (Galle)': ['ගාල්ල නගරය', 'අම්බලන්ගොඩ', 'හික්කඩුව', 'ඇල්පිටිය', 'කරාපිටිය', 'බද්දේගම'],
    'මාතර (Matara)': ['මාතර නගරය', 'වැලිගම', 'අකුරැස්සා', 'හක්මන', 'දෙනියාය', 'දෙකන්ද'],
    'හම්බන්තොට (Hambantota)': ['හම්බන්තොට නගරය', 'තංගල්ල', 'අම්බලන්තොට', 'තිස්සමහාරාමය', 'බෙලිඅත්ත'],
    'යාපනය (Jaffna)': ['යාපනය නගරය', 'නල්ලූර්', 'චාවකච්චේරිය', 'පේදුරුතුඩුව', 'කයිට්ස්'],
    'කිලිනොච්චිය (Kilinochchi)': ['කිලිනොච්චිය නගරය', 'පරන්තන්', 'පූනරීන්', 'පලෙයි'],
    'මන්නාරම (Mannar)': ['මන්නාරම නගරය', 'මඩු', 'තලෙයිමන්නාරම', 'මුසලි'],
    'වවුනියාව (Vavuniya)': ['වවුනියාව නගරය', 'චෙට්ටිකුලම්', 'නෙඩුන්කේණි'],
    'මුලතිව් (Mullaitivu)': ['මුලතිව් නගරය', 'පුදුකුඩියිරිප්පු', 'තුනුක්කායි', 'වෙලියෝයා'],
    'මඩකලපුව (Batticaloa)': ['මඩකලපුව නගරය', 'කාත්තන්කුඩි', 'එරාවූර්', 'වාකරේ'],
    'අම්පාර (Ampara)': ['අම්පාර නගරය', 'කල්මුණේ', 'සමන්තුරේ', 'අක්කරෙයිපත්තුව', 'පොතුවිල්'],
    'ත්‍රිකුණාමලය (Trincomalee)': ['ත්‍රිකුණාමලය නගරය', 'කින්නියා', 'කන්තලේ', 'මුතූර්'],
    'කුරුණෑගල (Kurunegala)': ['කුරුණෑගල නගරය', 'කුලියාපිටිය', 'පන්නල', 'නාරම්මල', 'ගිරිඋල්ල', 'මාවතගම', 'වාරියපොළ'],
    'පුත්තලම (Puttalam)': ['පුත්තලම නගරය', 'හලාවත', 'මාදම්පේ', 'වෙන්නප්පුව', 'ආණමඩුව', 'කල්පිටිය'],
    'අනුරාධපුරය (Anuradhapura)': ['අනුරාධපුර නගරය', 'කැකිරාව', 'මැදවච්චිය', 'තඹුත්තේගම', 'එපාවල', 'මිහින්තලේ', 'නොච්චියාගම'],
    'පොළොන්නරුව (Polonnaruwa)': ['පොළොන්නරුව නගරය', 'මැදිරිගිරිය', 'හිඟුරක්ගොඩ', 'මින්නෙරිය', 'කඳුරුවෙල', 'වැලිකන්ද'],
    'බදුල්ල (Badulla)': ['බදුල්ල නගරය', 'බණ්ඩාරවෙල', 'ඇල්ල', 'දියතලාව', 'වැලිමඩ', 'මහියංගණය'],
    'මොණරාගල (Monaragala)': ['මොණරාගල නගරය', 'වැල්ලවාය', 'බිබිල', 'කතරගම', 'තණමල්විල'],
    'රත්නපුරය (Ratnapura)': ['රත්නපුර නගරය', 'ඇඹිලිපිටිය', 'බලන්ගොඩ', 'ඇහැලියගොඩ', 'පැල්මඩුල්ල', 'කළවාන'],
    'කෑගල්ල (Kegalle)': ['කෑගල්ල නගරය', 'මාවනැල්ල', 'වරකාපොළ', 'රඹුක්කන', 'දෙහිඕවිට', 'යේරියගම'],
  };

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;

    _fullNameController = TextEditingController(text: p['full_name'] ?? p['name'] ?? '');
    _phoneController = TextEditingController(text: p['phone'] ?? '');
    _addressController = TextEditingController(text: p['address'] ?? '');
    _experienceController = TextEditingController(text: (p['experience_years'] ?? 0).toString());
    _radiusController = TextEditingController(text: (p['working_radius_km'] ?? 0).toString());

    if (p['service_category'] != null && p['service_category'].toString().isNotEmpty) {
      final parts = p['service_category']
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        _selectedCategories = Set<String>.from(parts);
      }
    }

    if (p['district'] != null && _districtCities.containsKey(p['district'])) {
      _selectedDistrict = p['district'];
    }
    _selectedCity = _districtCities[_selectedDistrict]!.first;
    if (p['city'] != null && _districtCities[_selectedDistrict]!.contains(p['city'])) {
      _selectedCity = p['city'];
    }

    if (p['portfolio_images'] is List) {
      _portfolioImages = List<String>.from(p['portfolio_images']);
    }
  }

  Future<void> _pickPortfolioImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 65, maxWidth: 800);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _portfolioImages.add(base64Image);
        });
      }
    } catch (e) {
      debugPrint("❌ Error picking portfolio image: $e");
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _showMultiCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String search = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = editProfileCategoriesList.where((c) {
              final label = (c['label'] ?? '').toLowerCase();
              final val = (c['value'] ?? '').toLowerCase();
              final q = search.toLowerCase();
              return q.isEmpty || label.contains(q) || val.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'සේවාවන් තෝරන්න (Select Services)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) {
                      setModalState(() => search = val);
                    },
                    decoration: InputDecoration(
                      hintText: 'සේවාවන් සොයන්න...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final val = item['value']!;
                        final isSelected = _selectedCategories.contains(val);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.deepNavy,
                          title: Text(
                            item['label'] ?? val,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedCategories.add(val);
                              } else {
                                _selectedCategories.remove(val);
                              }
                            });
                            setModalState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'තහවුරු කරන්න (${_selectedCategories.length} ක් තෝරාගෙන ඇත)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isProvider && _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('කරුණාකර අවම වශයෙන් එක් සේවාවක්වත් තෝරන්න.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? widget.currentProfile['id'] ?? '';

    final res = await ApiService.updateUserProfile(
      userId: userId,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      district: _selectedDistrict,
      city: _selectedCity,
      serviceCategory: widget.isProvider ? _selectedCategories.join(', ') : null,
      experienceYears: widget.isProvider ? int.tryParse(_experienceController.text.trim()) : null,
      workingRadiusKm: widget.isProvider ? int.tryParse(_radiusController.text.trim()) : null,
    );

    if (widget.isProvider) {
      await ApiService.updateProviderPortfolio(
        providerId: userId,
        portfolioImages: _portfolioImages,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (res['success'] == true) {
      await prefs.setString('full_name', _fullNameController.text.trim());
      await prefs.setString('phone', _phoneController.text.trim());
      await prefs.setString('address', _addressController.text.trim());
      await prefs.setString('district', _selectedDistrict);
      await prefs.setString('city', _selectedCity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'සාර්ථකව යාවත්කාලීන කරන ලදී!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'ගැටළුවක් සිදු විය.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.deepNavy;

    final availableCities = _districtCities[_selectedDistrict] ?? ['නගරය'];
    final safeCity = availableCities.contains(_selectedCity) ? _selectedCity : availableCities.first;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: Text(
          widget.isProvider ? 'බාස් ගිණුම සංස්කරණය' : 'පාරිභෝගික ගිණුම සංස්කරණය',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.navySubtle,
                      child: const Icon(Icons.edit_note_rounded, size: 30, color: AppColors.deepNavy),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isProvider ? 'බාස් ගිණුම් විස්තර සංස්කරණය' : 'පාරිභෝගික ගිණුම් විස්තර සංස්කරණය',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'ඔබගේ නවතම තොරතුරු ඇතුළත් කර Save කරන්න.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Card
              Container(
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
                    // Full Name Input
                    _buildInputField(
                      controller: _fullNameController,
                      label: 'සම්පූර්ණ නම (Full Name)',
                      icon: Icons.person_outline_rounded,
                      validator: (val) => val == null || val.isEmpty ? 'නම ඇතුළත් කරන්න' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone Input
                    _buildInputField(
                      controller: _phoneController,
                      label: 'දුරකථන අංකය (Phone Number)',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'දුරකථන අංකය ඇතුළත් කරන්න' : null,
                    ),
                    const SizedBox(height: 16),

                    // District Dropdown
                    const Text(
                      'දිස්ත්‍රික්කය (District)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map_rounded, color: AppColors.deepNavy),
                        filled: true,
                        fillColor: AppColors.surfaceBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      ),
                      items: _districtCities.keys.map((dist) {
                        return DropdownMenuItem(
                          value: dist,
                          child: Text(dist, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDistrict = val;
                            _selectedCity = _districtCities[val]!.first;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Main City Dropdown
                    const Text(
                      'ප්‍රධාන නගරය (City)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: safeCity,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.deepNavy),
                        filled: true,
                        fillColor: AppColors.surfaceBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      ),
                      items: availableCities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCity = val);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Address Input
                    _buildInputField(
                      controller: _addressController,
                      label: 'ලිපිනය (Address Details)',
                      icon: Icons.location_on_rounded,
                      validator: (val) => val == null || val.isEmpty ? 'ලිපිනය ඇතුළත් කරන්න' : null,
                    ),

                    // Provider Specific Fields
                    if (widget.isProvider) ...[
                      const SizedBox(height: 16),
                      // Service Category Selector (Multi-Select)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'ඔබ ලබාදෙන සේවාවන් (Services You Provide)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedCategories.length} ක් තෝරාගෙන ඇත',
                            style: TextStyle(fontSize: 11, color: themeColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_selectedCategories.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedCategories.map((val) {
                            final catItem = editProfileCategoriesList.firstWhere(
                              (c) => c['value'] == val,
                              orElse: () => {'value': val, 'label': val},
                            );
                            return InputChip(
                              label: Text(
                                catItem['label'] ?? val,
                                style: TextStyle(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.navySubtle,
                              deleteIcon: Icon(Icons.cancel_rounded, size: 16, color: themeColor),
                              onDeleted: () {
                                if (_selectedCategories.length > 1) {
                                  setState(() {
                                    _selectedCategories.remove(val);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('අඩුම තරමින් එක් සේවාවක්වත් තිබිය යුතුය.')),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showMultiCategoryPicker,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                          label: const Text(
                            'සේවාවන් එකතු / සංස්කරණය කරන්න (+ Add/Edit Services)',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: Colors.orange.shade800),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _experienceController,
                        label: 'පළපුරුද්ද - වසර (Years of Experience)',
                        icon: Icons.workspace_premium_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _radiusController,
                        label: 'සේවා සපයන දුර - කි.මී. (Radius in KM)',
                        icon: Icons.near_me_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    _isLoading ? 'තොරතුරු Save වෙමින් පවතී...' : 'තොරතුරු Save කරන්න (Save Changes)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.navyDark),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.navyDark, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
