import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'provider_home_screen.dart';

// Top-level constant for 50 service categories with Sinhala and English labels
const List<Map<String, String>> onboardingServiceCategories = [
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

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicController = TextEditingController();
  final _experienceController = TextEditingController();
  final _radiusController = TextEditingController();

  final Set<String> _selectedCategories = {'Masonry'};
  String _selectedDistrict = 'පොළොන්නරුව (Polonnaruwa)';
  late String _selectedCity;
  bool _isLoading = false;

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
    _selectedCity = _districtCities[_selectedDistrict]!.first;
  }

  @override
  void dispose() {
    _nicController.dispose();
    _experienceController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _showMultiCategoryPicker() {
    String filterText = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredList = onboardingServiceCategories.where((c) {
            final search = filterText.toLowerCase();
            return (c['value']?.toLowerCase().contains(search) ?? false) ||
                (c['label']?.toLowerCase().contains(search) ?? false);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.navyDark,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'සේවා කාණ්ඩ තෝරන්න (Select Services)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (val) => setModalState(() => filterText = val),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'සේවා වර්ගයක් සොයන්න (Search)...',
                          hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xFFEEF2F6)),
                    itemBuilder: (c, index) {
                      final item = filteredList[index];
                      final val = item['value']!;
                      final isSelected = _selectedCategories.contains(val);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(
                          item['label'] ?? val,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.navyDark : AppColors.textDark,
                            fontSize: 13.5,
                          ),
                        ),
                        activeColor: AppColors.deepNavy,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedCategories.add(val);
                            } else {
                              if (_selectedCategories.length > 1) {
                                _selectedCategories.remove(val);
                              }
                            }
                          });
                          setModalState(() {});
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'තෝරාගත් සේවාවන් ${_selectedCategories.length} තහවුරු කරන්න',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('කරුණාකර අවම වශයෙන් එක් සේවා කාණ්ඩයක්වත් තෝරන්න.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID හමු නොවීය. නැවත Log in වන්න.')),
        );
      }
      return;
    }

    final combinedAddress = '$_selectedCity, $_selectedDistrict';
    final categoriesString = _selectedCategories.join(', ');

    final res = await ApiService.submitProviderDetails(
      userId: userId,
      category: categoriesString,
      nic: _nicController.text.trim(),
      experience: int.tryParse(_experienceController.text.trim()) ?? 0,
      radius: double.tryParse(_radiusController.text.trim()) ?? 10.0,
      district: _selectedDistrict,
      city: _selectedCity,
      address: combinedAddress,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success']) {
      await prefs.setString('service_category', categoriesString);
      await prefs.setString('address', combinedAddress);
      await prefs.setBool('is_provider_onboarded', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']), backgroundColor: AppColors.successGreen),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCities = _districtCities[_selectedDistrict] ?? [];
    final safeCity = availableCities.contains(_selectedCity) ? _selectedCity : availableCities.first;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: Column(
        children: [
          // Top Bar Header
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                14,
                MediaQuery.of(context).padding.top + 12,
                16,
                16,
              ),
              decoration: const BoxDecoration(
                color: AppColors.navyDark,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x2200192C),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 8),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'ආපසු (Back)',
                  ),
                  const SizedBox(width: 4),
                  // Title and Subtitle Column
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'වෘත්තීය ලියාපදිංචිය',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'සේවා සපයන්නෙකු ලෙස අමතර විස්තර ඇතුළත් කරන්න',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                    ),
                    child: const Text(
                      'Provider',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Form Content Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro Welcome Banner Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.deepNavy.withValues(alpha: 0.04),
                            AppColors.navySubtle.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepNavy.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.badge_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'වෘත්තීය විස්තර තහවුරු කිරීම',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navyDark,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'අනුමැතිය සහ පාරිභෝගිකයින්ට ඔබව සොයාගැනීමට මෙම විස්තර අවශ්‍ය වේ.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Label 1: සේවා කාණ්ඩ (Services You Provide)
                    const Text(
                      'ඔබ ලබාදෙන සේවාවන් (Services You Provide)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Multi-category Select Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 14,
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
                                child: Text(
                                  '${_selectedCategories.length} ක් තෝරාගෙන ඇත',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, color: AppColors.navyDark, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _showMultiCategoryPicker,
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.deepNavy),
                                label: const Text(
                                  'තෝරන්න (+ Select)',
                                  style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  side: const BorderSide(color: AppColors.deepNavy, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedCategories.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedCategories.map((val) {
                                final catItem = onboardingServiceCategories.firstWhere(
                                  (c) => c['value'] == val,
                                  orElse: () => {'value': val, 'label': val},
                                );
                                return InputChip(
                                  label: Text(
                                    catItem['label'] ?? val,
                                    style: const TextStyle(color: AppColors.deepNavy, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: AppColors.navySubtle,
                                  deleteIcon: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.deepNavy),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide.none,
                                  ),
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
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Label 2: දිස්ත්‍රික්කය (District)
                    const Text(
                      'ඔබ සිටින දිස්ත්‍රික්කය (District)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // District Dropdown Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDistrict,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.navySubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: AppColors.deepNavy,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        items: _districtCities.keys.map((dist) {
                          return DropdownMenuItem(
                            value: dist,
                            child: Text(dist, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.navyDark)),
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
                    ),

                    const SizedBox(height: 20),

                    // Label 3: ප්‍රධාන නගරය (Main City)
                    const Text(
                      'ප්‍රධාන නගරය / ආසන්නතම නගරය (Main City)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // City Dropdown Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: safeCity,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.navySubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_city_rounded,
                                color: AppColors.deepNavy,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        items: availableCities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.navyDark)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCity = val);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Label 4: ජාතික හැඳුනුම්පත් අංකය (NIC)
                    const Text(
                      'ජාතික හැඳුනුම්පත් අංකය (NIC)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // NIC Input Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nicController,
                        style: const TextStyle(fontSize: 15, color: AppColors.navyDark, fontWeight: FontWeight.w500),
                        validator: (val) => val == null || val.trim().isEmpty ? 'ජාතික හැඳුනුම්පත් අංකය ඇතුළත් කරන්න' : null,
                        decoration: InputDecoration(
                          hintText: 'උදා: 199512345678 V',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.navySubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.credit_card_rounded,
                                color: AppColors.deepNavy,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Label 5: පළපුරුද්ද - වසර (Experience Years)
                    const Text(
                      'පළපුරුද්ද - වසර (Years of Experience)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Experience Input Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 15, color: AppColors.navyDark, fontWeight: FontWeight.w500),
                        validator: (val) => val == null || val.trim().isEmpty ? 'පළපුරුද්ද ඇතුළත් කරන්න' : null,
                        decoration: InputDecoration(
                          hintText: 'උදා: 5',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.navySubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.deepNavy,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Label 6: සේවා සපයන දුර ප්‍රමාණය (Radius in KM)
                    const Text(
                      'සේවා සපයන දුර ප්‍රමාණය - කි.මී. (Radius in KM)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Radius Input Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _radiusController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 15, color: AppColors.navyDark, fontWeight: FontWeight.w500),
                        validator: (val) => val == null || val.trim().isEmpty ? 'සේවා සීමාව ඇතුළත් කරන්න' : null,
                        decoration: InputDecoration(
                          hintText: 'උදා: 15',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.navySubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.near_me_rounded,
                                color: AppColors.deepNavy,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepNavy,
                          elevation: 4,
                          shadowColor: AppColors.deepNavy.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'තොරතුරු යවන්න (Submit Details)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}