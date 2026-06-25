import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_locale.dart';
import 'theme/app_theme.dart';
import 'screens/cv_generator_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/job_news_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SiratiApp());
}

class SiratiApp extends StatelessWidget {
  const SiratiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final previewScreen = Uri.base.queryParameters['screen'];

    return ValueListenableBuilder<String>(
      valueListenable: AppLocale.languageCode,
      builder: (context, language, _) {
        return MaterialApp(
          title: language == 'en' ? 'Sirati' : 'سيرتي',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: AppLocale.locale,
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width =
                    constraints.maxWidth > 480 ? 430.0 : constraints.maxWidth;

                return ColoredBox(
                  color: AppColors.background,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: width,
                      height: constraints.maxHeight,
                      child: Directionality(
                        textDirection: AppLocale.direction(context),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          home: switch (previewScreen) {
            'register' => const RegisterScreen(),
            'create-cv' => const CvGeneratorScreen(),
            'mycvs' => const HomeScreen(initialIndex: 1),
            'education' => const HomeScreen(initialIndex: 2),
            'history' => const HistoryScreen(),
            'job-news' => const JobNewsScreen(),
            'privacy' => const PrivacyPolicyScreen(),
            'home' => const HomeScreen(),
            _ => const SplashScreen(),
          },
        );
      },
    );
  }
}
