import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_locale.dart';
import '../models/cv_template.dart';
import '../models/generated_cv.dart';
import '../services/cv_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import '../widgets/motion.dart';
import 'cv_generator_screen.dart';

class GeneratedCvScreen extends StatelessWidget {
  final GeneratedCv generatedCv;

  const GeneratedCvScreen({super.key, required this.generatedCv});

  Future<void> _downloadPdf(BuildContext context) async {
    final english = AppLocale.isEnglish(context);
    final service = CvApiService();
    final selection = (generatedCv.templatePdfUrl?.isNotEmpty ?? false)
      ? await _chooseTemplate(context, service, english)
      : const _TemplateSelection.useDefault();
    if (!context.mounted || !selection.shouldDownload) return;

    final pdfUrl = service.pdfUrlForTemplate(generatedCv, selection.template?.slug);
    if (pdfUrl.isEmpty) {
      _showMessage(
          context,
          english
              ? 'PDF link is not available yet.'
              : 'رابط PDF غير متاح حالياً.');
      return;
    }

    final launched = await launchUrl(Uri.parse(pdfUrl),
        mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showMessage(context,
          english ? 'Could not open the PDF link.' : 'تعذر فتح رابط PDF.');
    }
  }

  Future<_TemplateSelection> _chooseTemplate(
    BuildContext context,
    CvApiService service,
    bool english,
  ) async {
    try {
      final templates = await service.listCvTemplates(english: english);
      if (!context.mounted) return const _TemplateSelection.cancelled();
      if (templates.isEmpty) return const _TemplateSelection.useDefault();

      final selectedTemplate = await showModalBottomSheet<CvTemplate>(
        context: context,
        showDragHandle: true,
        builder: (context) => _CvTemplatePicker(
          templates: templates,
          english: english,
        ),
      );

      if (selectedTemplate == null) return const _TemplateSelection.cancelled();
      return _TemplateSelection(template: selectedTemplate);
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          english
              ? 'Could not load CV designs. Default design will be used.'
              : 'تعذر تحميل التصاميم. سيتم استخدام التصميم الافتراضي.',
        );
      }
          return const _TemplateSelection.useDefault();
    }
  }

  void _shareCv() {
    Share.share(
        '${generatedCv.fullName}\n${generatedCv.targetJobTitle}\n\n${generatedCv.generatedMarkdown}');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contact = [generatedCv.email, generatedCv.phone]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' · ');
    final english = AppLocale.isEnglish(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(english ? 'Generated CV' : 'السيرة الذاتية'),
        actions: [
          const LanguageToggle(),
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CvGeneratorScreen(initialCv: generatedCv)))),
        ],
      ),
      body: Column(
        children: [
          if (generatedCv.aiStatus == 'completed' ||
              generatedCv.aiStatus == 'not_configured')
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.teal, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      english
                          ? 'CV generated · ATS score: '
                          : 'تم إنشاء السيرة · درجة ATS: ',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.tealDark,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text('${generatedCv.scoreTotal}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.tealDark,
                          fontWeight: FontWeight.w700)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: .4)),
                    ),
                    child: Text(generatedCv.grade,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tealDark)),
                  ),
                ],
              ),
            ),
          if (generatedCv.aiStatus == 'failed' && generatedCv.aiError != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      english
                          ? 'A local version was created because AI generation did not complete: ${generatedCv.aiError}'
                          : 'تم إنشاء نسخة محلية لأن الذكاء الاصطناعي لم يكتمل: ${generatedCv.aiError}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.amber, height: 1.4),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: MotionReveal(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView(
                  children: [
                    Text(generatedCv.fullName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark)),
                    const SizedBox(height: 4),
                    Text(generatedCv.targetJobTitle,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    if (contact.isNotEmpty)
                      Text(contact,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    const Divider(height: 24, color: AppColors.border),
                    if (generatedCv.generatedMarkdown.trim().isEmpty)
                      Text(
                          english
                              ? 'No CV content is available yet.'
                              : 'لا يوجد محتوى للسيرة حالياً.',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary))
                    else
                      ..._buildMarkdownSections(generatedCv.generatedMarkdown),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: PressScale(
                    child: OutlinedButton.icon(
                      onPressed: _shareCv,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: Text(english ? 'Share' : 'مشاركة'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PressScale(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadPdf(context),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text(english ? 'Download PDF' : 'تنزيل PDF'),
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

  List<Widget> _buildMarkdownSections(String markdown) {
    final widgets = <Widget>[];
    for (final line in markdown.trim().split('\n')) {
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            line.replaceFirst('## ', ''),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3),
          ),
        ));
        widgets.add(const Divider(height: 1, color: AppColors.border));
        widgets.add(const SizedBox(height: 6));
      } else if (line.startsWith('**') && line.contains('|')) {
        final cleaned = line.replaceAll('**', '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(cleaned,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ',
                  style: TextStyle(fontSize: 12, color: AppColors.primary)),
              Expanded(
                  child: Text(line.replaceFirst('- ', ''),
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.5))),
            ],
          ),
        ));
      } else if (line.trim().isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary, height: 1.6)),
        ));
      }
    }
    return widgets;
  }
}

class _TemplateSelection {
  final CvTemplate? template;
  final bool shouldDownload;

  const _TemplateSelection({this.template}) : shouldDownload = true;
  const _TemplateSelection.useDefault()
      : template = null,
        shouldDownload = true;
  const _TemplateSelection.cancelled()
      : template = null,
        shouldDownload = false;
}

class _CvTemplatePicker extends StatelessWidget {
  final List<CvTemplate> templates;
  final bool english;

  const _CvTemplatePicker({required this.templates, required this.english});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
        shrinkWrap: true,
        children: [
          Text(
            english ? 'Choose CV design' : 'اختر تصميم السيرة',
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in templates.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MotionReveal(
                order: entry.key,
                child: PressScale(
                  child: ListTile(
                    onTap: () => Navigator.pop(context, entry.value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    leading: _TemplatePreview(template: entry.value),
                    title: Text(
                      entry.value.name,
                      textAlign: english ? TextAlign.left : TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      entry.value.isDefault
                          ? (english ? 'Default template' : 'القالب الافتراضي')
                          : entry.value.slug,
                      textAlign: english ? TextAlign.left : TextAlign.right,
                    ),
                    trailing: const Icon(Icons.download_rounded),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  final CvTemplate template;

  const _TemplatePreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final url = template.previewImageUrl;
    if (url == null) {
      return Container(
        width: 44,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.description_outlined, color: AppColors.primary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 44,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.description_outlined),
      ),
    );
  }
}
