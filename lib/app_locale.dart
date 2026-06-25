import 'package:flutter/material.dart';

class AppLocale {
  static final ValueNotifier<String> languageCode = ValueNotifier<String>(
    Uri.base.queryParameters['lang'] == 'en' ? 'en' : 'ar',
  );

  static Locale get locale {
    return languageCode.value == 'en'
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');
  }

  static bool isEnglish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'en';
  }

  static TextDirection direction(BuildContext context) {
    return isEnglish(context) ? TextDirection.ltr : TextDirection.rtl;
  }

  static void setLanguage(String code) {
    languageCode.value = code == 'en' ? 'en' : 'ar';
  }

  static void toggle(BuildContext context) {
    setLanguage(isEnglish(context) ? 'ar' : 'en');
  }
}
