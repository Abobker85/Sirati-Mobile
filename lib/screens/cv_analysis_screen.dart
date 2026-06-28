import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import 'analysis_result_screen.dart';

class CvAnalysisScreen extends StatefulWidget {
  const CvAnalysisScreen({super.key});

  @override
  State<CvAnalysisScreen> createState() => _CvAnalysisScreenState();
}

class _CvAnalysisScreenState extends State<CvAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _resumeTextController = TextEditingController();
  final _apiService = CvApiService();
  PlatformFile? _uploadedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _resumeTextController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _uploadedFile = result.files.single);
  }

  void _clearFile() => setState(() => _uploadedFile = null);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uploadedFile == null && _resumeTextController.text.trim().isEmpty) {
      _showError('الصق نص السيرة أو ارفع ملف PDF/TXT للبدء.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final analysis = await _apiService.submitAnalysis(
        targetJobTitle: _jobTitleController.text.trim(),
        resumeText: _resumeTextController.text,
        resumeFile: await _multipartFile(),
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => AnalysisResultScreen(analysis: analysis)),
      );
    } on ApiException catch (exception) {
      if (mounted) _showError(exception.displayMessage);
    } catch (_) {
      if (mounted) _showError('حدث خطأ غير متوقع أثناء تحليل السيرة.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<http.MultipartFile?> _multipartFile() async {
    final file = _uploadedFile;
    if (file == null) return null;

    if (file.bytes != null) {
      return http.MultipartFile.fromBytes(
        'resume_file',
        file.bytes!,
        filename: file.name,
      );
    }

    if (file.path != null) {
      return http.MultipartFile.fromPath(
        'resume_file',
        file.path!,
        filename: file.name,
      );
    }

    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg, textAlign: TextAlign.right),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('تحليل السيرة الذاتية'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            // ── Job title ──
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('المسمى الوظيفي المستهدف',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _jobTitleController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'مثال: Laravel Backend Developer',
                      prefixIcon: Icon(Icons.work_outline_rounded),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'هذا الحقل مطلوب'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Upload area ──
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('رفع ملف السيرة الذاتية',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  if (_uploadedFile == null)
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primaryMid,
                              width: 1.5,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.primaryLight.withValues(alpha: .5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.cloud_upload_outlined,
                                  size: 28, color: AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            const Text('اضغط لرفع ملف PDF أو TXT',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            const SizedBox(height: 4),
                            const Text('الحد الأقصى 5 ميجابايت',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.teal.withValues(alpha: .4)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.red),
                            onPressed: _clearFile,
                            visualDensity: VisualDensity.compact,
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(_uploadedFile!.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tealDark)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.insert_drive_file_outlined,
                              color: AppColors.tealDark, size: 20),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── OR divider ──
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border)),
                    child: const Text('أو',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 12),

            // ── Paste area ──
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('لصق نص السيرة الذاتية',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _resumeTextController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'الصق نص السيرة الذاتية كاملاً هنا...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Icon(Icons.analytics_outlined, size: 20),
              label:
                  Text(_isLoading ? 'جارٍ التحليل...' : 'تحليل السيرة الذاتية'),
            ),
          ],
        ),
      ),
    );
  }
}
