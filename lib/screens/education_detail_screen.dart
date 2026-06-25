import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/mobile_content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class EducationDetailScreen extends StatelessWidget {
  final int? id;
  final Map<String, dynamic> fallback;

  const EducationDetailScreen({super.key, this.id, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(english ? 'Learning Detail' : 'تفاصيل المحتوى'),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageToggle(),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: id == null
            ? Future.value(fallback)
            : MobileContentService().educationContent(id!, english),
        builder: (context, snapshot) {
          final data = snapshot.data ?? fallback;
          final title = _text(data['title']);
          final body = _text(data['body']);
          final duration = _text(data['duration']);
          final role = _text(data['target_role']);
          final badge = _text(data['badge']);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: english ? WrapAlignment.start : WrapAlignment.end,
                children: [
                  if (badge.isNotEmpty) _Chip(label: badge),
                  if (role.isNotEmpty) _Chip(label: role),
                  if (duration.isNotEmpty) _Chip(label: duration),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: english ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  body,
                  textAlign: english ? TextAlign.left : TextAlign.right,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.75,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryMid.withValues(alpha: .25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

String _text(dynamic value) => value?.toString() ?? '';
