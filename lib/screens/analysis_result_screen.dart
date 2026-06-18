import 'package:flutter/material.dart';
import '../models/cv_analysis.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import '../theme/app_theme.dart';
import 'generated_cv_screen.dart';

class AnalysisResultScreen extends StatefulWidget {
  final CvAnalysis analysis;

  const AnalysisResultScreen({super.key, required this.analysis});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final _apiService = CvApiService();
  bool _isGenerating = false;

  Future<void> _generateImprovedCv() async {
    setState(() => _isGenerating = true);

    try {
      final generatedCv = await _apiService.generateCvFromAnalysis(
        analysisId: widget.analysis.id,
        overrides: const {},
      );

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
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          behavior: SnackBarBehavior.floating),
    );
  }

  Color _scoreColor(int s) {
    if (s >= 80) return AppColors.tealDark;
    if (s >= 65) return AppColors.primary;
    if (s >= 50) return AppColors.amber;
    return AppColors.red;
  }

  Color _scoreTrack(int s) {
    if (s >= 80) return AppColors.tealLight;
    if (s >= 65) return AppColors.primaryLight;
    if (s >= 50) return AppColors.amberLight;
    return AppColors.redLight;
  }

  String _gradeDesc(int s) {
    if (s >= 80) return 'ممتاز — سيرتك قوية ومؤهلة';
    if (s >= 65) return 'جيد جداً — مع بعض التحسينات';
    if (s >= 50) return 'مقبول — يحتاج مراجعة';
    return 'ضعيف — يحتاج إعادة هيكلة';
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('نتائج التحليل'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'الدرجة والمعايير'),
                Tab(text: 'التوصيات'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ScoreTab(
                score: analysis.scoreTotal,
                grade: analysis.grade,
                jobMatch: analysis.jobMatch,
                jobTitle: analysis.targetJobTitle,
                criteria: analysis.criteria,
                keywordsFound: analysis.keywordsFound,
                keywordsMissing: analysis.keywordsMissing,
                scoreColor: _scoreColor(analysis.scoreTotal),
                scoreTrack: _scoreTrack(analysis.scoreTotal),
                gradeDesc: _gradeDesc(analysis.scoreTotal),
              ),
              _RecommendationsTab(
                strengths: analysis.strengths,
                quickWins: analysis.quickWins,
                isGenerating: _isGenerating,
                onGenerateCv: _generateImprovedCv,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score Tab ─────────────────────────────────────────────────────────────────

class _ScoreTab extends StatelessWidget {
  final int score;
  final String grade;
  final int jobMatch;
  final String jobTitle;
  final List<ScoreCriterion> criteria;
  final List<String> keywordsFound;
  final List<String> keywordsMissing;
  final Color scoreColor;
  final Color scoreTrack;
  final String gradeDesc;

  const _ScoreTab({
    required this.score,
    required this.grade,
    required this.jobMatch,
    required this.jobTitle,
    required this.criteria,
    required this.keywordsFound,
    required this.keywordsMissing,
    required this.scoreColor,
    required this.scoreTrack,
    required this.gradeDesc,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        // ── Score Hero ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Ring
              SizedBox(
                width: 116,
                height: 116,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: scoreColor,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Grade badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scoreTrack,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'تقدير  $grade',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                gradeDesc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),
              // Job match row
              Row(
                children: [
                  const Icon(
                    Icons.work_outline_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      jobTitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$jobMatch%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: jobMatch / 100,
                  minHeight: 7,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'نسبة التطابق مع الوظيفة',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Criteria ────────────────────────────────────────────────────────
        const SectionTitle('تفاصيل المعايير'),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: List.generate(criteria.length, (i) {
              final c = criteria[i];
              final s = c.score.toDouble();
              final m = c.max.toDouble();
              final pct = s / m;
              final Color barColor = pct >= 0.8
                  ? AppColors.teal
                  : pct >= 0.6
                      ? AppColors.primary
                      : AppColors.amber;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${c.score} / ${c.max}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: barColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${(pct * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: barColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(barColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < criteria.length - 1) const Divider(height: 1),
                ],
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        // ── Keywords ────────────────────────────────────────────────────────
        const SectionTitle('الكلمات المفتاحية'),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Found
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'موجودة  (${keywordsFound.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: keywordsFound
                    .map((k) => _KeywordChip(label: k, found: true))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),
              // Missing
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ناقصة  (${keywordsMissing.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: keywordsMissing
                    .map((k) => _KeywordChip(label: k, found: false))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Recommendations Tab ───────────────────────────────────────────────────────

class _RecommendationsTab extends StatelessWidget {
  final List<String> strengths;
  final List<String> quickWins;
  final bool isGenerating;
  final VoidCallback onGenerateCv;

  const _RecommendationsTab({
    required this.strengths,
    required this.quickWins,
    required this.isGenerating,
    required this.onGenerateCv,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        // ── Strengths ────────────────────────────────────────────────────────
        const _SectionHeader(
          icon: Icons.thumb_up_alt_rounded,
          iconColor: AppColors.tealDark,
          iconBg: AppColors.tealLight,
          label: 'نقاط القوة',
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: strengths.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('لا توجد نقاط قوة متاحة حالياً',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                )
              : Column(
                  children: List.generate(strengths.length, (i) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.tealLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: AppColors.tealDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  strengths[i],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.55,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < strengths.length - 1) const Divider(height: 1),
                      ],
                    );
                  }),
                ),
        ),

        const SizedBox(height: 24),

        // ── Quick Wins ────────────────────────────────────────────────────────
        const _SectionHeader(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.amber,
          iconBg: AppColors.amberLight,
          label: 'تحسينات سريعة',
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: quickWins.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('لا توجد تحسينات سريعة متاحة حالياً',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                )
              : Column(
                  children: List.generate(quickWins.length, (i) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 1),
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.amberLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  quickWins[i],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.55,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < quickWins.length - 1) const Divider(height: 1),
                      ],
                    );
                  }),
                ),
        ),

        const SizedBox(height: 28),

        // ── CTA ──────────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryMid),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جاهز لترقية سيرتك؟',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'سنولّد لك سيرة ذاتية محسّنة تلقائياً بناءً على نتائج هذا التحليل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isGenerating ? null : onGenerateCv,
          icon: isGenerating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4))
              : const Icon(Icons.auto_awesome_rounded, size: 18),
          label: Text(isGenerating ? 'جارٍ التوليد...' : 'توليد سيرة محسّنة'),
        ),
      ],
    );
  }
}

// ── Shared Private Widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final bool found;

  const _KeywordChip({required this.label, required this.found});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: found ? AppColors.tealLight : AppColors.redLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: found
              ? AppColors.tealDark.withOpacity(0.18)
              : AppColors.red.withOpacity(0.18),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: found ? AppColors.tealDark : AppColors.red,
        ),
      ),
    );
  }
}
