import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'chat_screen.dart';

class ProviderJobsScreen extends StatefulWidget {
  const ProviderJobsScreen({super.key});

  @override
  State<ProviderJobsScreen> createState() => ProviderJobsScreenState();
}

class ProviderJobsScreenState extends State<ProviderJobsScreen> {
  Future<List<dynamic>>? _myJobsFuture;
  int _filterIndex = 0; // 0: සියල්ල, 1: ක්‍රියාත්මකයි, 2: අවසන්

  @override
  void initState() {
    super.initState();
    _loadMyJobs();
  }

  void reloadJobs() {
    _loadMyJobs();
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

  void _loadMyJobs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? providerId = prefs.getString('user_id');

    if (providerId != null) {
      setState(() {
        _myJobsFuture = ApiService.getMyJobs(providerId);
      });
    }
  }

  Future<void> _handleRefresh() async {
    _loadMyJobs();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  List<dynamic> _filterJobs(List<dynamic> jobs) {
    if (_filterIndex == 1) {
      return jobs.where((j) => j['status'] != 'completed').toList();
    } else if (_filterIndex == 2) {
      return jobs.where((j) => j['status'] == 'completed').toList();
    }
    return jobs;
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

  void _showJobDetailsModal(BuildContext context, Map<String, dynamic> job) {
    final isCompleted = job['status'] == 'completed';
    final customerName = job['customer_name'] ?? 'පාරිභෝගිකයා';
    final customerPhone = job['customer_phone'] ?? 'නොමැත';
    final customerImage = job['customer_image_url'] ?? '';
    final review = job['review'];

    final customerAvatar = _getImageProvider(customerImage);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'සේවා විස්තර සහ සමාලෝචනය',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.navySubtle : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCompleted ? AppColors.navyLight.withValues(alpha: 0.3) : AppColors.successGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'අවසන් කළා' : 'ක්‍රියාත්මකයි',
                      style: TextStyle(
                        color: isCompleted ? AppColors.deepNavy : AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFEEF2F6)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.navySubtle,
                      backgroundImage: customerAvatar,
                      child: customerAvatar == null
                          ? Text(
                              customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                          ),
                          if (customerPhone.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              customerPhone,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  receiverId: job['customer_id'] ?? '',
                                  receiverName: customerName,
                                  receiverPhone: customerPhone,
                                  receiverImage: customerImage,
                                  bookingId: job['id']?.toString(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.deepNavy, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.navySubtle,
                          ),
                          tooltip: 'පණිවිඩ යවන්න (Chat)',
                        ),
                        if (customerPhone.isNotEmpty && customerPhone != 'නොමැත') ...[
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () => _makePhoneCall(customerPhone),
                            icon: const Icon(Icons.phone_rounded, color: AppColors.successGreen, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFECFDF5),
                            ),
                            tooltip: 'ඇමතුමක් ගන්න',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('සේවා ගැටළුව:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                job['issue'] ?? 'ගැටළුව සඳහන් කර නැත',
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.navyLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job['address'] ?? 'ලිපිනය නොමැත',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.navyAccent),
                  const SizedBox(width: 6),
                  Text(
                    'දිනය: ${job['service_date'] ?? 'සඳහන් කර නැත'}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, color: Color(0xFFEEF2F6)),
              ),
              const Text(
                'පාරිභෝගික සමාලෝචනය (Review & Rating)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),
              const SizedBox(height: 12),
              if (review != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (starIdx) => Icon(
                                starIdx < (review['rating'] ?? 5) ? Icons.star_rounded : Icons.star_border_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            review['created_at'] != null ? review['created_at'].toString().split('T')[0] : '',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (review['comment'] != null && review['comment'].toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '"${review['comment']}"',
                          style: const TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic, color: Color(0xFF78350F), height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else if (isCompleted) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'පාරිභෝගිකයා තවමත් මෙම සේවාව සඳහා සමාලෝචනයක් (Review) ඇතුළත් කර නැත.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.navySubtle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.pending_actions_rounded, color: AppColors.deepNavy, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'මෙම සේවාව ක්‍රියාත්මක වෙමින් පවතී. සේවාව අවසන් වූ පසු පාරිභෝගිකයාට Review ඇතුළත් කළ හැක.',
                          style: TextStyle(color: AppColors.deepNavy, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: Column(
        children: [
          // Custom Top Header Bar (Matching Settings Screen exact height & padding)
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
              child: SizedBox(
                height: 48,
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
                        'මගේ වැඩ (My Jobs)',
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
          ),
          // Filter Chips Bar (Separated from top bar)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            color: AppColors.surfaceBg,
            child: Row(
              children: [
                _buildFilterChip('සියල්ල', 0),
                const SizedBox(width: 8),
                _buildFilterChip('ක්‍රියාත්මකයි', 1),
                const SizedBox(width: 8),
                _buildFilterChip('අවසන් කළ ඒවා', 2),
              ],
            ),
          ),

          // Main Jobs List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.deepNavy,
              child: FutureBuilder<List<dynamic>>(
                future: _myJobsFuture,
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
                          const Text('දත්ත ලබා ගැනීමේ දෝෂයක්!', style: TextStyle(color: AppColors.errorRed, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadMyJobs,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepNavy),
                            child: const Text('නැවත උත්සාහ කරන්න', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: AppColors.navySubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assignment_outlined, size: 56, color: AppColors.deepNavy),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'ඔබ මෙතෙක් කිසිදු සේවාවක් භාරගෙන නොමැත.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'නව සේවා ඉල්ලීම් ඩෑෂ්බෝඩ් එකෙන් භාරගත් පසු මෙහි පෙන්වනු ඇත.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredJobs = _filterJobs(snapshot.data!);

                  if (filteredJobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.filter_alt_off_rounded, size: 56, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'මෙම වර්ගීකරණය යටතේ සේවාවන් නොමැත.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      final isCompleted = job['status'] == 'completed';
                      final review = job['review'];

                      return GestureDetector(
                        onTap: () => _showJobDetailsModal(context, job),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepNavy.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isCompleted ? AppColors.cardBorder : AppColors.navyLight.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Badge & Date Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? AppColors.navySubtle : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isCompleted ? AppColors.navyLight.withValues(alpha: 0.3) : AppColors.successGreen.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                          size: 14,
                                          color: isCompleted ? AppColors.deepNavy : AppColors.successGreen,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isCompleted ? 'අවසන් කළා' : 'ක්‍රියාත්මකයි',
                                          style: TextStyle(
                                            color: isCompleted ? AppColors.deepNavy : AppColors.successGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            job['service_date'] ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Job Issue Description
                              Text(
                                job['issue'] ?? 'ගැටළුව සඳහන් කර නැත',
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Address Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 17, color: AppColors.navyLight),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      job['address'] ?? 'ලිපිනය සඳහන් කර නැත',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),

                              // Customer Review Badge on Card if exists
                              if (review != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${review['rating']}.0',
                                        style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      if (review['comment'] != null && review['comment'].toString().trim().isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '"${review['comment']}"',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Color(0xFF78350F), fontSize: 11, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],

                              // Action Button if Job is active
                              if (!isCompleted) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(height: 1, color: Color(0xFFEEF2F6)),
                                ),
                                Row(
                                  children: [
                                    IconButton.filledTonal(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              receiverId: job['customer_id'] ?? '',
                                              receiverName: job['customer_name'] ?? 'පාරිභෝගිකයා',
                                              receiverPhone: job['customer_phone'] ?? '',
                                              receiverImage: job['customer_image_url'] ?? '',
                                              bookingId: job['id']?.toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.deepNavy, size: 20),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.navySubtle,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      tooltip: 'පණිවිඩ යවන්න (Chat)',
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _makePhoneCall(job['customer_phone'] ?? ''),
                                        icon: const Icon(Icons.phone_rounded, color: AppColors.successGreen, size: 18),
                                        label: const Text(
                                          'ඇමතුමක්',
                                          style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12.5),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.successGreen, width: 1.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          bool? confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: const Text('සේවාව අවසන් කිරීම', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                                              content: const Text('ඔබ මෙම සේවාව සාර්ථකව අවසන් කළ බව තහවුරු කරන්න.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('නැත', style: TextStyle(color: AppColors.textMuted)),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.deepNavy,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  child: const Text('ඔව්, අවසන් කළා', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true && context.mounted) {
                                            final result = await ApiService.completeBooking(job['id'].toString());
                                            if (context.mounted) {
                                              if (result['success']) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(result['message']), backgroundColor: AppColors.successGreen),
                                                );
                                                _loadMyJobs();
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(result['message']), backgroundColor: AppColors.errorRed),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 18),
                                        label: const Text(
                                          'අවසන් කළා',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.deepNavy,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _filterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.navyDark : AppColors.cardBorder.withValues(alpha: 0.8),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}