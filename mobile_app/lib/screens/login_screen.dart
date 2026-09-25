import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'customer_home_screen.dart';
import 'provider_home_screen.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'customer' හෝ 'provider'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.role == 'customer';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'සාදරයෙන් පිළිගනිමු!',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCustomer
                              ? 'පාරිභෝගික ගිණුමට පිවිසෙන්න'
                              : 'සේවා සපයන්නාගේ ගිණුමට පිවිසෙන්න',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.8),
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
                    child: Text(
                      isCustomer ? 'Customer' : 'Provider',
                      style: const TextStyle(
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

          // Scrollable Body Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Welcome Card
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
                          child: Icon(
                            isCustomer ? Icons.person_rounded : Icons.engineering_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCustomer
                                    ? 'ගෘහාශ්‍රිත සේවාවන් පහසුවෙන් ලබාගන්න'
                                    : 'ඔබේ සේවාවන් පාරිභෝගිකයන්ට ලබාදෙන්න',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyDark,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'ගිණුම භාවිත කිරීමට ඊමේල් සහ මුරපදය ඇතුළත් කරන්න',
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

                  // Label 1: Email Address
                  const Text(
                    'ඊමේල් ලිපිනය (Email Address)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email Input Container
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
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 15, color: AppColors.navyDark, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
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
                              Icons.mail_outline_rounded,
                              color: AppColors.deepNavy,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Label 2: Password
                  const Text(
                    'මුරපදය (Password)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Password Input Container
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
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontSize: 15, color: AppColors.navyDark, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: '••••••••',
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
                              Icons.lock_outline_rounded,
                              color: AppColors.deepNavy,
                              size: 20,
                            ),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(
                              role: widget.role,
                              initialEmail: _emailController.text.trim(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'මුරපදය අමතක වුණා ද?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyAccent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('කරුණාකර ඊමේල් ලිපිනය සහ මුරපදය ඇතුළත් කරන්න'),
                                    backgroundColor: AppColors.navyDark,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              final result = await ApiService.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                role: widget.role,
                              );

                              if (!context.mounted) return;
                              setState(() {
                                _isLoading = false;
                              });

                              if (result['success']) {
                                // Sync FCM Token asynchronously for push notifications
                                try {
                                  if (result['user'] != null && result['user']['id'] != null) {
                                    NotificationService().syncFcmToken(userId: result['user']['id']).catchError((e) {
                                      debugPrint("⚠️ FCM sync error: $e");
                                    });
                                  }
                                } catch (_) {}

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: AppColors.successGreen,
                                  ),
                                );

                                if (widget.role == 'provider') {
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: AppColors.errorRed,
                                  ),
                                );
                              }
                            },
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
                                    'ලොග් වෙන්න (Login)',
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

                  // Google Sign-In Section
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.cardBorder.withValues(alpha: 0.8),
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'හෝ (OR)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.cardBorder.withValues(alpha: 0.8),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Google Sign-In Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
                        child: Center(
                          child: _isGoogleLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepNavy),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      width: 22,
                                      height: 22,
                                      errorBuilder: (context, error, stackTrace) => const GoogleGLogo(size: 22),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Google සමඟ ඉදිරියට යන්න',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register Account Option Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ගිණුමක් තවම නැද්ද? ',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(role: widget.role),
                                  ),
                                );
                              },
                              child: const Text(
                                'ලියාපදිංචි වන්න',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  // Google Sign-In Execution
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading || _isLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );

      // Sign out first to ensure account picker dialog always shows up
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        // User cancelled account picker
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });
        }
        return;
      }

      final String email = account.email;
      final String fullName = account.displayName ?? '';
      final String? photoUrl = account.photoUrl;
      final String googleId = account.id;

      final result = await ApiService.googleLogin(
        email: email,
        fullName: fullName,
        googleId: googleId,
        profileImageUrl: photoUrl,
        role: widget.role,
      );

      if (!mounted) return;

      setState(() {
        _isGoogleLoading = false;
      });

      if (result['success'] == true) {
        // Sync FCM token
        try {
          if (result['user'] != null && result['user']['id'] != null) {
            NotificationService().syncFcmToken(userId: result['user']['id']).catchError((e) {
              debugPrint("⚠️ FCM sync error: $e");
            });
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Google මගින් සාර්ථකව පිවිසුණි!'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        if (widget.role == 'provider') {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Google මගින් පිවිසීමට නොහැකි විය.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Google Sign-In Error: $e");
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google පිවිසීමේ දෝෂයක්: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}

// Custom Google G Logo Painter Widget
class GoogleGLogo extends StatelessWidget {
  final double size;
  const GoogleGLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(center, center), radius: radius);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Red sector (top)
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(center, center)
      ..arcTo(rect, -2.356, 1.571, false)
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow sector (bottom left)
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(center, center)
      ..arcTo(rect, -0.785, 1.571, false)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green sector (bottom right)
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(center, center)
      ..arcTo(rect, 0.785, 1.571, false)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Blue sector & bar (right)
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(center, center)
      ..arcTo(rect, 2.356, 1.571, false)
      ..close();
    canvas.drawPath(bluePath, paint);

    // White cutout inner circle
    final Paint whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, center), radius * 0.55, whitePaint);

    // Blue bar
    final Rect barRect = Rect.fromLTRB(
      center - radius * 0.05,
      center - radius * 0.22,
      center + radius,
      center + radius * 0.22,
    );
    canvas.drawRect(barRect, paint);

    // White wedge on right top
    final Path whiteWedge = Path()
      ..moveTo(center, center)
      ..lineTo(center + radius, center)
      ..lineTo(center + radius, center - radius * 0.55)
      ..close();
    canvas.drawPath(whiteWedge, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
