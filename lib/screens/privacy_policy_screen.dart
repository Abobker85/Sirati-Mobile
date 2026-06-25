import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(english ? 'Privacy Policy' : 'سياسة الخصوصية'),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageToggle(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _Section(
            title: english ? 'What We Collect' : 'ما البيانات التي نجمعها؟',
            body: english
                ? 'We collect your account details and the CV content you enter or upload so Sirati can analyze, improve, and save your CVs.'
                : 'نجمع بيانات الحساب الأساسية ومحتوى السيرة الذاتية الذي تدخله أو ترفعه حتى نتمكن من تحليلها وتحسينها وحفظها داخل حسابك.',
          ),
          _Section(
            title: english ? 'How We Use It' : 'كيف نستخدم البيانات؟',
            body: english
                ? 'Your data is used to calculate ATS scores, generate improved CVs, show your history, and personalize the dashboard.'
                : 'نستخدم بياناتك لحساب درجة ATS، إنشاء سير ذاتية محسنة، عرض السجل، وتخصيص لوحة التحكم لك.',
          ),
          _Section(
            title: english ? 'Sharing' : 'مشاركة البيانات',
            body: english
                ? 'We do not sell your data. AI processing only happens when the backend AI provider is configured.'
                : 'لا نبيع بياناتك. تتم معالجة الذكاء الاصطناعي فقط عند تفعيل مزود الذكاء الاصطناعي في الخادم.',
          ),
          _Section(
            title: english ? 'Deleting Data' : 'حذف البيانات',
            body: english
                ? 'You can delete generated CVs from My CVs. For full account deletion, contact the Sirati team.'
                : 'يمكنك حذف السير الذاتية المنشأة من شاشة سيراتي. لحذف الحساب بالكامل، تواصل مع فريق سيرتي.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: .7)),
      ),
      child: Column(
        crossAxisAlignment:
            english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
