import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/generated_cv.dart';
import '../theme/app_theme.dart';

class GeneratedCvScreen extends StatelessWidget {
  final GeneratedCv generatedCv;

  const GeneratedCvScreen({super.key, required this.generatedCv});

  Future<void> _downloadPdf(BuildContext context) async {
    final pdfUrl = generatedCv.pdfUrl;
    if (pdfUrl == null || pdfUrl.isEmpty) {
      _showMessage(context, 'رابط PDF غير متاح حالياً.');
      return;
    }

    final launched = await launchUrl(Uri.parse(pdfUrl),
        mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showMessage(context, 'تعذر فتح رابط PDF.');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('السيرة الذاتية'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.pop(context)),
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
                  const Expanded(
                    child: Text(
                      'تم إنشاء السيرة · درجة ATS: ',
                      style: TextStyle(
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
                      border:
                          Border.all(color: AppColors.teal.withOpacity(0.4)),
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
                      'تم إنشاء نسخة محلية لأن الذكاء الاصطناعي لم يكتمل: ${generatedCv.aiError}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.amber, height: 1.4),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
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
                    const Text('لا يوجد محتوى للسيرة حالياً.',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary))
                  else
                    ..._buildMarkdownSections(generatedCv.generatedMarkdown),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareCv,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('مشاركة'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadPdf(context),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('تنزيل PDF'),
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
