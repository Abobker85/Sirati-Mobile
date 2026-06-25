import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_locale.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import '../services/mobile_content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'cv_generator_screen.dart';

class MyCvsScreen extends StatefulWidget {
  const MyCvsScreen({super.key});

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  final _contentService = MobileContentService();
  final _cvService = CvApiService();
  late Future<Map<String, dynamic>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _contentService.myCvs(AppLocale.isEnglish(context));
  }

  void _refresh() {
    setState(
        () => _future = _contentService.myCvs(AppLocale.isEnglish(context)));
  }

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data ?? _fallback(english);
          final items = _list(data['items']);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 156),
            children: [
              _MyCvsHeader(
                english: english,
                title:
                    _text(data['title'], english ? 'My CVs' : 'سيرتي الذاتية'),
              ),
              const SizedBox(height: 30),
              Text(
                _text(
                    data['summary'],
                    english
                        ? 'You have 3 draft and completed files'
                        : 'لديك 3 ملفات مسودة ومكتملة'),
                textAlign: english ? TextAlign.left : TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment:
                    english ? Alignment.centerLeft : Alignment.centerRight,
                child: const _MyCvsAddButton(),
              ),
              const SizedBox(height: 18),
              for (final item in items) ...[
                _CvDocumentCard(
                  id: _int(item['id']),
                  title: _text(item['title'], ''),
                  updatedAt: _text(item['updated_label'], ''),
                  badge: _text(item['badge'], ''),
                  isDraft: _bool(item['is_draft']),
                  canDownload: _bool(item['can_download'], fallback: true),
                  pdfUrl: _text(item['pdf_url'], ''),
                  onEdit: () => _editCv(_int(item['id'])),
                  onDelete: () => _deleteCv(_int(item['id'])),
                  onDownload: () => _download(_text(item['pdf_url'], '')),
                ),
                const SizedBox(height: 18),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _editCv(int? id) async {
    if (id == null) return;
    try {
      final cv = await _cvService.getGeneratedCv(id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CvGeneratorScreen(initialCv: cv)),
      );
      _refresh();
    } on ApiException catch (exception) {
      _message(exception.displayMessage);
    }
  }

  Future<void> _deleteCv(int? id) async {
    if (id == null) return;
    final english = AppLocale.isEnglish(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(english ? 'Delete CV?' : 'حذف السيرة؟'),
        content: Text(english
            ? 'This action cannot be undone.'
            : 'لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(english ? 'Cancel' : 'إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(english ? 'Delete' : 'حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _cvService.deleteGeneratedCv(id);
      _refresh();
    } on ApiException catch (exception) {
      _message(exception.displayMessage);
    }
  }

  Future<void> _download(String url) async {
    if (url.isEmpty) return;
    final launched =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!launched) {
      _message(AppLocale.isEnglish(context)
          ? 'Could not open PDF.'
          : 'تعذر فتح ملف PDF.');
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

Map<String, dynamic> _fallback(bool english) => {
      'title': english ? 'My CVs' : 'سيرتي الذاتية',
      'summary': english
          ? 'You have 3 draft and completed files'
          : 'لديك 3 ملفات مسودة ومكتملة',
      'items': [
        {
          'title': english ? 'Marketing Manager CV' : 'سيرة مدير تسويق',
          'updated_label': english
              ? 'Last updated: Oct 12, 2023'
              : 'آخر تعديل: 12 أكتوبر 2023',
          'badge': 'ATS 85%',
          'can_download': true,
        },
        {
          'title': english ? 'Data Analyst - English' : 'محلل بيانات - إنجليزي',
          'updated_label': english
              ? 'Last updated: Sep 05, 2023'
              : 'آخر تعديل: 05 سبتمبر 2023',
          'badge': 'ATS 92%',
          'can_download': true,
        },
        {
          'title': english ? 'CV Draft' : 'مسودة سيرة ذاتية',
          'updated_label':
              english ? 'Last updated: 2 days ago' : 'آخر تعديل: منذ يومين',
          'badge': english ? '40% Draft' : '40% مسودة',
          'is_draft': true,
          'can_download': false,
        },
      ],
    };

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};
List<Map<String, dynamic>> _list(dynamic value) =>
    value is List ? value.map(_map).toList() : const [];
String _text(dynamic value, String fallback) =>
    (value?.toString().isNotEmpty ?? false) ? value.toString() : fallback;
bool _bool(dynamic value, {bool fallback = false}) =>
    value is bool ? value : fallback;
int? _int(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

class _MyCvsHeader extends StatelessWidget {
  final bool english;
  final String title;

  const _MyCvsHeader({required this.english, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.primary, size: 30),
          const SizedBox(width: 10),
          const LanguageToggle(),
          const Spacer(),
          Directionality(
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryMid, width: 3),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 34),
          ),
        ],
      ),
    );
  }
}

class _CvDocumentCard extends StatelessWidget {
  final int? id;
  final String title;
  final String updatedAt;
  final String badge;
  final bool isDraft;
  final bool canDownload;
  final String pdfUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  const _CvDocumentCard({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.badge,
    required this.isDraft,
    required this.canDownload,
    required this.pdfUrl,
    required this.onEdit,
    required this.onDelete,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDraft ? AppColors.textHint : AppColors.primary;
    final english = AppLocale.isEnglish(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 156),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.borderStrong.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _DocumentIcon(color: color),
              const Spacer(),
              _StatusBadge(label: badge, isDraft: isDraft),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            updatedAt,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                _CircleActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: AppLocale.isEnglish(context) ? 'Delete' : 'حذف',
                  iconColor: AppColors.red,
                  borderColor: AppColors.borderStrong,
                  onTap: id == null ? null : onDelete,
                ),
                const SizedBox(width: 10),
                _CircleActionButton(
                  icon: Icons.download_rounded,
                  label: AppLocale.isEnglish(context) ? 'Download' : 'تنزيل',
                  iconColor: canDownload
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: .3),
                  borderColor: canDownload
                      ? AppColors.borderStrong
                      : AppColors.border.withValues(alpha: .35),
                  onTap: canDownload ? onDownload : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label:
                          Text(AppLocale.isEnglish(context) ? 'Edit' : 'تعديل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentIcon extends StatelessWidget {
  final Color color;

  const _DocumentIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.description_outlined, color: color, size: 30),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isDraft;

  const _StatusBadge({required this.label, required this.isDraft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isDraft ? AppColors.surfaceHigh : AppColors.primaryMid)
            .withValues(alpha: .82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isDraft ? AppColors.textSecondary : AppColors.primary,
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const _CircleActionButton(
      {required this.icon,
      required this.label,
      required this.iconColor,
      required this.borderColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        enabled: onTap != null,
        child: Material(
          color: AppColors.surface,
          shape: CircleBorder(side: BorderSide(color: borderColor, width: 2)),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: iconColor, size: 21),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyCvsAddButton extends StatelessWidget {
  const _MyCvsAddButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amber,
      shape: const CircleBorder(),
      elevation: 10,
      shadowColor: AppColors.amber.withValues(alpha: .28),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CvGeneratorScreen()),
        ),
        child: const SizedBox(
          width: 64,
          height: 64,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 38),
        ),
      ),
    );
  }
}
