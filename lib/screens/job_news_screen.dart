import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_locale.dart';
import '../services/mobile_content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class JobNewsScreen extends StatelessWidget {
  const JobNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: MobileContentService().jobNews(english),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _fallback(english);
          final items = _list(data['items']);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
            children: [
              Row(
                children: [
                  const LanguageToggle(),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: english
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        _text(data['title'],
                            english ? 'Job News' : 'أخبار الوظائف'),
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 250,
                        child: Text(
                          _text(
                            data['subtitle'],
                            english
                                ? 'Fresh opportunities and hiring updates.'
                                : 'فرص وتحديثات توظيف جديدة.',
                          ),
                          textAlign: english ? TextAlign.left : TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (items.isEmpty)
                _EmptyNews(english: english)
              else
                for (final item in items) ...[
                  _JobNewsCard(
                    item: item,
                    english: english,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobNewsDetailScreen(item: item),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          );
        },
      ),
    );
  }
}

class JobNewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const JobNewsDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);
    final url = _text(item['url'], '');

    return Scaffold(
      appBar: AppBar(title: Text(english ? 'Job Details' : 'تفاصيل الخبر')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            _text(item['title'], ''),
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 25,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: english ? WrapAlignment.start : WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_text(item['company'], '').isNotEmpty)
                _MetaChip(text: _text(item['company'], '')),
              if (_text(item['location'], '').isNotEmpty)
                _MetaChip(text: _text(item['location'], '')),
              if (_text(item['published_label'], '').isNotEmpty)
                _MetaChip(text: _text(item['published_label'], '')),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            _text(item['body'], ''),
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              height: 1.75,
              color: AppColors.textPrimary,
            ),
          ),
          if (url.isNotEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(english ? 'Open Opportunity' : 'فتح الفرصة'),
            ),
          ],
        ],
      ),
    );
  }
}

class _JobNewsCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool english;
  final VoidCallback onTap;

  const _JobNewsCard({
    required this.item,
    required this.english,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: .7)),
          ),
          child: Column(
            crossAxisAlignment:
                english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              const Icon(Icons.business_center_outlined,
                  color: AppColors.primary, size: 28),
              const SizedBox(height: 12),
              Text(
                _text(item['title'], ''),
                textAlign: english ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [_text(item['company'], ''), _text(item['location'], '')]
                    .where((value) => value.isNotEmpty)
                    .join(' · '),
                textAlign: english ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;

  const _MetaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}

class _EmptyNews extends StatelessWidget {
  final bool english;

  const _EmptyNews({required this.english});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        english
            ? 'No job news is published yet.'
            : 'لا توجد أخبار وظائف منشورة حالياً.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
      ),
    );
  }
}

Map<String, dynamic> _fallback(bool english) => {
      'title': english ? 'Job News' : 'أخبار الوظائف',
      'subtitle': english
          ? 'Fresh opportunities and hiring updates.'
          : 'فرص وتحديثات توظيف جديدة.',
      'items': const [],
    };

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};
List<Map<String, dynamic>> _list(dynamic value) =>
    value is List ? value.map(_map).toList() : const [];
String _text(dynamic value, String fallback) =>
    (value?.toString().isNotEmpty ?? false) ? value.toString() : fallback;
