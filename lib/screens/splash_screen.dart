import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/auth_token_store.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'privacy_policy_screen.dart';
import 'register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _tokenStore = const AuthTokenStore();

  Future<void> _goToLogin() async {
    final token = await _tokenStore.readToken();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => token == null || token.isEmpty
            ? const LoginScreen()
            : const HomeScreen(),
      ),
    );
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final en = AppLocale.isEnglish(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.15,
            colors: [Color(0xFFE7F4EF), AppColors.background],
          ),
        ),
        child: CustomPaint(
          painter: _DottedBackgroundPainter(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTall = constraints.maxHeight >= 760;
                final topGap = isTall ? 86.0 : 36.0;
                final titleGap = isTall ? 40.0 : 26.0;
                final actionGap = isTall ? 74.0 : 34.0;
                final bottomGap = isTall ? 78.0 : 28.0;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: AlignmentDirectional.topStart,
                            child: LanguageToggle(),
                          ),
                          SizedBox(height: topGap),
                          const Center(child: _SplashLogo()),
                          const SizedBox(height: 18),
                          Text(
                            en ? 'Sirati' : 'سيرتي',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 42,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: titleGap),
                          Text(
                            en
                                ? 'Build Your CV Professionally'
                                : 'اصنع سيرتك الذاتية باحترافية',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            en
                                ? 'Create an ATS-friendly CV, reach employers with confidence, and stand out with polished global templates.'
                                : 'أنشئ سيرة ذاتية تجتاز فلاتر ATS، وتصل لأصحاب العمل بسهولة وبأرقى التصاميم العالمية.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.75,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textHint,
                            ),
                          ),
                          SizedBox(height: actionGap),
                          ElevatedButton.icon(
                            onPressed: _goToRegister,
                            icon: Icon(
                                en
                                    ? Icons.arrow_forward_rounded
                                    : Icons.arrow_back_rounded,
                                size: 28),
                            label:
                                Text(en ? 'Create Account' : 'إنشاء حساب جديد'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(64),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: .25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: _openPrivacyPolicy,
                            child: Text(
                              en ? 'Sign In' : 'تسجيل الدخول',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: bottomGap),
                          TextButton(
                            onPressed: _goToLogin,
                            child: Text(
                              en ? 'Privacy Policy' : 'سياسة الخصوصية',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: .035,
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26006A60),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(
          Icons.description_outlined,
          color: Colors.white,
          size: 58,
        ),
      ),
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: .12);
    const spacing = 32.0;

    for (double y = 18; y < size.height; y += spacing) {
      for (double x = 18; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.25, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
