import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import 'customer_home_screen.dart';
import 'provider_home_screen.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // තප්පර 5ක ප්‍රමාදයක් (Splash screen එක තප්පර 5ක් ප්‍රදර්ශනය වීමට)
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userRole = prefs.getString('user_role');

      if (userId != null && userId.trim().isNotEmpty) {
        // දැනටමත් Log වී සිටී නම්
        if (userRole == 'provider') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Log වී නැත නම් Role Selection Screen එකට යවමු
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    } catch (e) {
      debugPrint("❌ Splash Screen Navigation Error: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF021024),
        body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            // Scale logo size dynamically based on available height (between 140 and 210)
            final logoSize = (screenHeight * 0.28).clamp(140.0, 210.0);
            final spacingLarge = (screenHeight * 0.035).clamp(16.0, 32.0);
            final spacingSmall = (screenHeight * 0.015).clamp(8.0, 16.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Yellow Circular Logo Badge
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                              blurRadius: 35,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFFFB800),
                              child: Icon(
                                Icons.home_repair_service_rounded,
                                size: logoSize * 0.45,
                                color: const Color(0xFF021024),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacingLarge),

                      // Title in Sinhala ("අපේ" in White, "බාස්" in Yellow)
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.notoSansSinhala(
                            fontSize: (screenHeight * 0.05).clamp(28.0, 38.0),
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                          children: const [
                            TextSpan(
                              text: 'අපේ ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'බාස්',
                              style: TextStyle(color: Color(0xFFFFB800)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Title in English ("Ape" in White, "Baas" in Yellow)
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: (screenHeight * 0.035).clamp(18.0, 24.0),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Ape ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Baas',
                              style: TextStyle(color: Color(0xFFFFB800)),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacingLarge),

                      // Subtitle Banner Box (Pill Container)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF061830),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ඔබට අවශ්‍ය හොඳම බාස් මෙතනින්',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansSinhala(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Trusted Local Home Services',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF90A4AE),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Purple Loading Spinner
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: const CircularProgressIndicator(
                          color: Color(0xFFA78BFA),
                          strokeWidth: 3.5,
                        ),
                      ),

                      SizedBox(height: spacingSmall),

                      // Version text
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF90A4AE),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: spacingSmall + 4),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  }
}

