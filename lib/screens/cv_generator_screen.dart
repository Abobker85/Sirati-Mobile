import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import '../app_locale.dart';
import '../models/generated_cv.dart';
import '../widgets/language_toggle.dart';
import 'generated_cv_screen.dart';

class CvGeneratorScreen extends StatefulWidget {
  final GeneratedCv? initialCv;

  const CvGeneratorScreen({super.key, this.initialCv});

  @override
  State<CvGeneratorScreen> createState() => _CvGeneratorScreenState();
}

class _CvGeneratorScreenState extends State<CvGeneratorScreen> {
  int _step = 0;
  bool _isLoading = false;
  bool _isEnhancingJobDescription = false;
  String _language = 'ar';
  final _apiService = CvApiService();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _jobDescriptionCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _certsCtrl = TextEditingController();

  static const _steps = ['الشخصية', 'المهارات', 'الخبرات', 'التعليم'];

  bool get _isEditMode => widget.initialCv != null;

  @override
  void initState() {
    super.initState();
    final cv = widget.initialCv;
    if (cv == null) return;

    _nameCtrl.text = cv.fullName;
    _emailCtrl.text = cv.email ?? '';
    _phoneCtrl.text = cv.phone ?? '';
    _linkedinCtrl.text = cv.linkedin ?? '';
    _locationCtrl.text = cv.location ?? '';
    _jobTitleCtrl.text = cv.targetJobTitle;
    _jobDescriptionCtrl.text = cv.jobDescriptionInput ?? '';
    _language = cv.language;
    _summaryCtrl.text = cv.summaryInput ?? '';
    _skillsCtrl.text = cv.skillsInput;
    _experienceCtrl.text = cv.experienceInput;
    _educationCtrl.text = cv.educationInput;
    _certsCtrl.text = cv.certificationsInput ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _linkedinCtrl,
      _locationCtrl,
      _jobTitleCtrl,
      _jobDescriptionCtrl,
      _summaryCtrl,
      _skillsCtrl,
      _experienceCtrl,
      _educationCtrl,
      _certsCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final payload = {
        'full_name': _nameCtrl.text.trim(),
        'email': _nullable(_emailCtrl.text),
        'phone': _nullable(_phoneCtrl.text),
        'linkedin': _nullable(_linkedinCtrl.text),
        'location': _nullable(_locationCtrl.text),
        'target_job_title': _jobTitleCtrl.text.trim(),
        'job_description_input': _nullable(_jobDescriptionCtrl.text),
        'language': _language,
        'summary_input': _nullable(_summaryCtrl.text),
        'skills_input': _skillsCtrl.text.trim(),
        'experience_input': _experienceCtrl.text.trim(),
        'education_input': _educationCtrl.text.trim(),
        'certifications_input': _nullable(_certsCtrl.text),
      };

      final generatedCv = _isEditMode
          ? await _apiService.updateGeneratedCv(widget.initialCv!.id, payload)
          : await _apiService.generateCv(payload);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => GeneratedCvScreen(generatedCv: generatedCv)),
      );
    } on ApiException catch (exception) {
      if (mounted) _showError(exception.displayMessage);
    } catch (_) {
      if (mounted) _showError('حدث خطأ غير متوقع أثناء توليد السيرة.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _enhanceJobDescription() async {
    final english = AppLocale.isEnglish(context);
    final targetJobTitle = _jobTitleCtrl.text.trim();

    if (targetJobTitle.isEmpty) {
      _showError(english
          ? 'Enter the target job title first.'
          : 'أدخل المسمى الوظيفي المستهدف أولاً.');
      return;
    }

    setState(() => _isEnhancingJobDescription = true);

    try {
      final data = await _apiService.enhanceJobDescription(
        targetJobTitle: targetJobTitle,
        jobDescription: _jobDescriptionCtrl.text.trim(),
        language: _language,
      );
      final enhanced = data['enhanced_description']?.toString() ?? '';
      if (enhanced.isEmpty) return;
      _jobDescriptionCtrl.text = enhanced;
      _showError(
          english ? 'Job description enhanced.' : 'تم تحسين الوصف الوظيفي.');
    } on ApiException catch (exception) {
      if (mounted) _showError(exception.displayMessage);
    } finally {
      if (mounted) setState(() => _isEnhancingJobDescription = false);
    }
  }

  bool _validateCurrentStep() {
    final english = AppLocale.languageCode.value == 'en';
    final message = switch (_step) {
      0 when _nameCtrl.text.trim().isEmpty =>
        english ? 'Full name is required.' : 'الاسم الكامل مطلوب.',
      0 when _jobTitleCtrl.text.trim().isEmpty => english
          ? 'Target job title is required.'
          : 'المسمى الوظيفي المستهدف مطلوب.',
      1 when _skillsCtrl.text.trim().isEmpty =>
        english ? 'Core skills are required.' : 'المهارات الأساسية مطلوبة.',
      2 when _experienceCtrl.text.trim().length < 80 => english
          ? 'Write at least 80 characters about your experience.'
          : 'اكتب الخبرات العملية بتفاصيل لا تقل عن 80 حرفاً.',
      3 when _educationCtrl.text.trim().isEmpty =>
        english ? 'Education is required.' : 'التعليم مطلوب.',
      _ => null,
    };

    if (message == null) return true;
    _showError(message);
    return false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_isEditMode
            ? (english ? 'Edit CV' : 'تعديل السيرة')
            : (english ? 'Create CV' : 'إنشاء سيرة ذاتية')),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageToggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            final steps = english
                ? const ['Personal', 'Skills', 'Experience', 'Education']
                : _steps;

            return Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        english
                            ? 'Step ${_step + 1} of ${steps.length}'
                            : 'خطوة ${_step + 1} من ${steps.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        steps[_step],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(steps.length * 2 - 1, (i) {
                      if (i.isOdd) {
                        final done = i ~/ 2 < _step;
                        return Expanded(
                            child: Container(
                                height: 2,
                                color: done
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceHigh));
                      }
                      final idx = i ~/ 2;
                      final done = idx < _step;
                      final active = idx == _step;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: done
                              ? AppColors.primaryContainer
                              : active
                                  ? AppColors.amberAccent
                                  : AppColors.surfaceHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                              : Text('${idx + 1}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? AppColors.primaryDark
                                          : AppColors.textHint)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: steps
                        .asMap()
                        .entries
                        .map((e) => Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: e.key <= _step
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
          /* old progress header removed */
          /*
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'خطوة ${_step + 1} من ${_steps.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _steps[_step],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(_steps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final done = i ~/ 2 < _step;
                      return Expanded(
                          child: Container(
                              height: 2,
                              color: done
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceHigh));
                    }
                    final idx = i ~/ 2;
                    final done = idx < _step;
                    final active = idx == _step;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.primaryContainer
                            : active
                                ? AppColors.amberAccent
                                : AppColors.surfaceHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white)
                            : Text('${idx + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? AppColors.primaryDark
                                        : AppColors.textHint)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _steps
                      .asMap()
                      .entries
                      .map((e) => Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: e.key <= _step
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          */

          // ── Step content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                if (_step == 0) _buildStep0(english),
                if (_step == 1) _buildStep1(english),
                if (_step == 2) _buildStep2(english),
                if (_step == 3) _buildStep3(english),
                const SizedBox(height: 28),
                Row(
                  children: [
                    if (_step > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step--),
                          child: Text(english ? 'Back' : 'السابق'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (!_validateCurrentStep()) return;

                                if (_step < _steps.length - 1) {
                                  setState(() => _step++);
                                } else {
                                  _submit();
                                }
                              },
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Icon(
                                _step == _steps.length - 1
                                    ? Icons.auto_awesome
                                    : Icons.arrow_forward_ios_rounded,
                                size: 18),
                        label: Text(_isLoading
                            ? (english ? 'Generating...' : 'جارٍ التوليد...')
                            : _step == _steps.length - 1
                                ? (_isEditMode
                                    ? (english ? 'Update CV' : 'تحديث السيرة')
                                    : (english
                                        ? 'Generate CV'
                                        : 'توليد السيرة'))
                                : (english ? 'Next' : 'التالي')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldGroup(String label, Widget field, bool english) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label,
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildStep0(bool english) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(english ? 'Personal Information' : 'المعلومات الشخصية',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 18),
        _fieldGroup(
            english ? 'Full Name *' : 'الاسم الكامل *',
            TextFormField(
              controller: _nameCtrl,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              textAlign: english ? TextAlign.left : TextAlign.right,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  hintText: english ? 'Salem Sayer' : 'سالم سيار'),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english ? 'Email' : 'البريد الإلكتروني',
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'salem@example.com'),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english ? 'Phone' : 'رقم الهاتف',
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+966 5X XXX XXXX'),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english ? 'LinkedIn URL' : 'رابط LinkedIn',
            TextFormField(
              controller: _linkedinCtrl,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.link_rounded),
                  hintText: 'linkedin.com/in/username'),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english ? 'Target Job Title *' : 'المسمى الوظيفي المستهدف *',
            TextFormField(
              controller: _jobTitleCtrl,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              textAlign: english ? TextAlign.left : TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work_outline_rounded),
                  hintText: 'Laravel Backend Developer'),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english ? 'Job Description (optional)' : 'الوصف الوظيفي (اختياري)',
            Column(
              crossAxisAlignment:
                  english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                TextFormField(
                  controller: _jobDescriptionCtrl,
                  textDirection:
                      english ? TextDirection.ltr : TextDirection.rtl,
                  textAlign: english ? TextAlign.left : TextAlign.right,
                  maxLines: 5,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.assignment_outlined),
                    hintText: english
                        ? 'Paste the job description or let Sirati complete it from the role...'
                        : 'الصق الوصف الوظيفي أو دع سيرتي يكمله من المسمى...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isEnhancingJobDescription
                      ? null
                      : _enhanceJobDescription,
                  icon: _isEnhancingJobDescription
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: Text(english ? 'Enhance' : 'تحسين'),
                ),
              ],
            ),
            english),
        const SizedBox(height: 18),
        Text(english ? 'CV Language' : 'لغة السيرة الذاتية',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _LangOption(
                      label: 'English',
                      value: 'en',
                      selected: _language == 'en',
                      onTap: () => setState(() => _language = 'en'))),
              Expanded(
                  child: _LangOption(
                      label: 'العربية',
                      value: 'ar',
                      selected: _language == 'ar',
                      onTap: () => setState(() => _language = 'ar'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(bool english) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(english ? 'Skills & Summary' : 'المهارات والملخص',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 6),
        Text(
            english
                ? 'Enter skills separated by commas'
                : 'أدخل مهاراتك مفصولة بفاصلة',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        _fieldGroup(
            english ? 'Core Skills *' : 'المهارات الأساسية *',
            TextFormField(
              controller: _skillsCtrl,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              textAlign: english ? TextAlign.left : TextAlign.right,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'PHP, Laravel, API, SQL, Git, Agile, Docker',
                alignLabelWithHint: true,
              ),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english
                ? 'Professional Summary (optional)'
                : 'الملخص المهني (اختياري، سيُولَّد تلقائياً)',
            TextFormField(
              controller: _summaryCtrl,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              textAlign: english ? TextAlign.left : TextAlign.right,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: english
                    ? 'Briefly describe your experience and achievements...'
                    : 'نبذة مختصرة عن خبرتك وإنجازاتك...',
                alignLabelWithHint: true,
              ),
            ),
            english),
      ],
    );
  }

  Widget _buildStep2(bool english) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(english ? 'Work Experience' : 'الخبرات العملية',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 6),
        Text(
            english
                ? 'Include title, company, dates, and measurable achievements'
                : 'اذكر المسمى، الشركة، التاريخ، والإنجازات بأرقام',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                      english
                          ? 'Numbers like 35% or 20 users improve your ATS score.'
                          : 'كلما ذكرت أرقاماً (35%، 20 مستخدم)، زادت درجة ATS',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primaryDark),
                      textAlign: TextAlign.right)),
              const SizedBox(width: 8),
              const Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.primary, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _experienceCtrl,
          textDirection: english ? TextDirection.ltr : TextDirection.rtl,
          textAlign: english ? TextAlign.left : TextAlign.right,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText:
                'مطور Backend، شركة X، 2021–2025\n- طورت APIs تستخدمها 25 فرقة داخلية\n- حسّنت أداء SQL بنسبة 35%\n- بنيت تكاملات API خفّضت الإدخال 20%',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(bool english) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(english ? 'Education & Certifications' : 'التعليم والشهادات',
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            textAlign: english ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 18),
        _fieldGroup(
            english ? 'Education *' : 'التعليم *',
            TextFormField(
              controller: _educationCtrl,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              textAlign: english ? TextAlign.left : TextAlign.right,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'بكالوريوس علوم الحاسب، جامعة الملك عبدالعزيز، 2020',
                alignLabelWithHint: true,
              ),
            ),
            english),
        const SizedBox(height: 14),
        _fieldGroup(
            english
                ? 'Certifications & Courses (optional)'
                : 'الشهادات والدورات (اختياري)',
            TextFormField(
              controller: _certsCtrl,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              textAlign: english ? TextAlign.left : TextAlign.right,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'AWS Certified Cloud Practitioner، 2023\nGoogle Cloud Associate، 2022',
                alignLabelWithHint: true,
              ),
            ),
            english),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
