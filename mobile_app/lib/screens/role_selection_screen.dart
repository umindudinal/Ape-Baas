import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // 'customer' හෝ 'provider'
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: Column(
        children: [
          // Header Section
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
                MediaQuery.of(context).padding.top + 18,
                18,
                28,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF001730),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(44),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33001730),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
              children: [
                const Text(
                  'Welcome !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your account type to proceed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C4362).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: const Text(
                    'ඔබගේ භාවිත අරමුණ තෝරන්න',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

          // Main Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // Customer Role Card
                  _buildRoleCard(
                    roleValue: 'customer',
                    imagePath: 'assets/images/customer.png',
                    title: 'මට සේවාවක් අවශ්‍යයි',
                    tag: 'Customer / පාරිභෝගිකයා',
                    subtitle: 'නිවසේ සියලුම අලුත්වැඩියා සඳහා විශ්වාසවන්ත පළපුරුදු බාස් කෙනෙක් සොයාගන්න',
                  ),

                  const SizedBox(height: 16),

                  // Provider Role Card
                  _buildRoleCard(
                    roleValue: 'provider',
                    imagePath: 'assets/images/provider.png',
                    title: 'මම සේවාවක් සපයනවා',
                    tag: 'Provider / සේවා සපයන්නා',
                    subtitle: 'ඔබගේ ප්‍රදේශයෙන් අලුත් සේවා ඉල්ලීම් ලබාගෙන සාර්ථකව මුදල් උපයන්න',
                  ),

                  const SizedBox(height: 28),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedRole == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('කරුණාකර ඉදිරියට යාමට ගිණුම් වර්ගයක් තෝරන්න'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFF001730),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(role: selectedRole!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001730),
                        elevation: selectedRole == null ? 2 : 5,
                        shadowColor: const Color(0xFF001730).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleValue,
    required String imagePath,
    required String title,
    required String tag,
    required String subtitle,
  }) {
    final isSelected = selectedRole == roleValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF001730) : Colors.transparent,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF001730).withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 16 : 12,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Character 3D Image
            SizedBox(
              width: 105,
              height: 105,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  roleValue == 'customer' ? Icons.person_rounded : Icons.engineering_rounded,
                  size: 54,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Card Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001730),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8ECEF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C6B7B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7D8D9D),
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}