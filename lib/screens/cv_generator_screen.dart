import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import 'generated_cv_screen.dart';

class CvGeneratorScreen extends StatefulWidget {
  const CvGeneratorScreen({super.key});

  @override
  State<CvGeneratorScreen> createState() => _CvGeneratorScreenState();
}

class _CvGeneratorScreenState extends State<CvGeneratorScreen> {
  int _step = 0;
  bool _isLoading = false;
  String _language = 'ar';
  final _apiService = CvApiService();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _certsCtrl = TextEditingController();

  static const _steps = ['الشخصية', 'المهارات', 'الخبرات', 'التعليم'];

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _linkedinCtrl,
      _locationCtrl,
      _jobTitleCtrl,
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
      final generatedCv = await _apiService.generateCv({
        'full_name': _nameCtrl.text.trim(),
        'email': _nullable(_emailCtrl.text),
        'phone': _nullable(_phoneCtrl.text),
        'linkedin': _nullable(_linkedinCtrl.text),
        'location': _nullable(_locationCtrl.text),
        'target_job_title': _jobTitleCtrl.text.trim(),
        'language': _language,
        'summary_input': _nullable(_summaryCtrl.text),
        'skills_input': _skillsCtrl.text.trim(),
        'experience_input': _experienceCtrl.text.trim(),
        'education_input': _educationCtrl.text.trim(),
        'certifications_input': _nullable(_certsCtrl.text),
      });

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

  bool _validateCurrentStep() {
    final message = switch (_step) {
      0 when _nameCtrl.text.trim().isEmpty => 'الاسم الكامل مطلوب.',
      0 when _jobTitleCtrl.text.trim().isEmpty =>
        'المسمى الوظيفي المستهدف مطلوب.',
      1 when _skillsCtrl.text.trim().isEmpty => 'المهارات الأساسية مطلوبة.',
      2 when _experienceCtrl.text.trim().length < 80 =>
        'اكتب الخبرات العملية بتفاصيل لا تقل عن 80 حرفاً.',
      3 when _educationCtrl.text.trim().isEmpty => 'التعليم مطلوب.',
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('إنشاء سيرة ذاتية'),
      ),
      body: Column(
        children: [
          // ── Step indicator ──
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                Row(
                  children: List.generate(_steps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final done = i ~/ 2 < _step;
                      return Expanded(
                          child: Container(
                              height: 2,
                              color: done ? Colors.white : Colors.white30));
                    }
                    final idx = i ~/ 2;
                    final done = idx < _step;
                    final active = idx == _step;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: done || active ? Colors.white : Colors.white24,
                        shape: BoxShape.circle,
                        border: active
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: done
                            ? Icon(Icons.check_rounded,
                                size: 16, color: AppColors.primary)
                            : Text('${idx + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? AppColors.primary
                                        : Colors.white70)),
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
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // ── Step content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              children: [
                if (_step == 0) _buildStep0(),
                if (_step == 1) _buildStep1(),
                if (_step == 2) _buildStep2(),
                if (_step == 3) _buildStep3(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    if (_step > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step--),
                          child: const Text('السابق'),
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
                            ? 'جارٍ التوليد...'
                            : _step == _steps.length - 1
                                ? 'توليد السيرة'
                                : 'التالي'),
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

  Widget _fieldGroup(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('المعلومات الشخصية',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 18),
        _fieldGroup(
            'الاسم الكامل *',
            TextFormField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'سالم سيار'),
            )),
        const SizedBox(height: 14),
        _fieldGroup(
            'البريد الإلكتروني',
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'salem@example.com'),
            )),
        const SizedBox(height: 14),
        _fieldGroup(
            'رقم الهاتف',
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+966 5X XXX XXXX'),
            )),
        const SizedBox(height: 14),
        _fieldGroup(
            'رابط LinkedIn',
            TextFormField(
              controller: _linkedinCtrl,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.link_rounded),
                  hintText: 'linkedin.com/in/username'),
            )),
        const SizedBox(height: 14),
        _fieldGroup(
            'المسمى الوظيفي المستهدف *',
            TextFormField(
              controller: _jobTitleCtrl,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work_outline_rounded),
                  hintText: 'Laravel Backend Developer'),
            )),
        const SizedBox(height: 18),
        const Text('لغة السيرة الذاتية',
            style: TextStyle(
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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('المهارات والملخص',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 6),
        const Text('أدخل مهاراتك مفصولة بفاصلة',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        _fieldGroup(
            'المهارات الأساسية *',
            TextFormField(
              controller: _skillsCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'PHP, Laravel, API, SQL, Git, Agile, Docker',
                alignLabelWithHint: true,
              ),
            )),
        const SizedBox(height: 14),
        _fieldGroup(
            'الملخص المهني (اختياري، سيُولَّد تلقائياً)',
            TextFormField(
              controller: _summaryCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'نبذة مختصرة عن خبرتك وإنجازاتك...',
                alignLabelWithHint: true,
              ),
            )),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('الخبرات العملية',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 6),
        const Text('اذكر المسمى، الشركة، التاريخ، والإنجازات بأرقام',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: const [
              Expanded(
                  child: Text(
                      'كلما ذكرت أرقاماً (35%، 20 مستخدم)، زادت درجة ATS',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.primaryDark),
                      textAlign: TextAlign.right)),
              SizedBox(width: 8),
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.primary, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _experienceCtrl,
          textDirection: TextDirection.rtl,
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

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('التعليم والشهادات',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 18),
        _fieldGroup(
            'التعليم *',
            TextFormField(
              controller: _educationCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'بكالوريوس علوم الحاسب، جامعة الملك عبدالعزيز، 2020',
                alignLabelWithHint: true,
              ),
            )),
        const SizedBox(height: 14),
        _fieldGroup(
            'الشهادات والدورات (اختياري)',
            TextFormField(
              controller: _certsCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'AWS Certified Cloud Practitioner، 2023\nGoogle Cloud Associate، 2022',
                alignLabelWithHint: true,
              ),
            )),
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
