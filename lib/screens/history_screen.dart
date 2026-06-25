import 'package:flutter/material.dart';

import '../models/cv_analysis.dart';
import '../models/generated_cv.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import '../theme/app_theme.dart';
import 'analysis_result_screen.dart';
import 'generated_cv_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = CvApiService();
  late Future<_HistoryData> _historyFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyFuture = _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<_HistoryData> _loadHistory() async {
    final analyses = await _apiService.listAnalyses();
    final generatedCvs = await _apiService.listGeneratedCvs();
    return _HistoryData(analyses: analyses, generatedCvs: generatedCvs);
  }

  Future<void> _refresh() async {
    final nextFuture = _loadHistory();
    setState(() => _historyFuture = nextFuture);
    await nextFuture;
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.tealDark;
    if (score >= 65) return AppColors.primary;
    if (score >= 50) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(() => _historyFuture = _loadHistory())),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'التحليلات'),
            Tab(text: 'السير المنشأة'),
          ],
        ),
      ),
      body: FutureBuilder<_HistoryData>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).displayMessage
                : 'تعذر تحميل السجل.';

            return _ErrorState(
              message: message,
              onRetry: () => setState(() => _historyFuture = _loadHistory()),
            );
          }

          final data = snapshot.data ??
              const _HistoryData(analyses: [], generatedCvs: []);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: TabBarView(
              controller: _tabController,
              children: [
                _AnalysisList(analyses: data.analyses, scoreColor: _scoreColor),
                _GeneratedCvList(
                    cvs: data.generatedCvs, scoreColor: _scoreColor),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryData {
  final List<CvAnalysis> analyses;
  final List<GeneratedCv> generatedCvs;

  const _HistoryData({required this.analyses, required this.generatedCvs});
}

class _AnalysisList extends StatelessWidget {
  final List<CvAnalysis> analyses;
  final Color Function(int) scoreColor;

  const _AnalysisList({required this.analyses, required this.scoreColor});

  @override
  Widget build(BuildContext context) {
    if (analyses.isEmpty) {
      return const _EmptyState(message: 'لا توجد تحليلات بعد');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: analyses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final analysis = analyses[i];
        final color = scoreColor(analysis.scoreTotal);

        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => AnalysisResultScreen(analysis: analysis)),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.manage_search,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        analysis.targetJobTitle,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    Text('${analysis.scoreTotal}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: analysis.scoreTotal / 100,
                    minHeight: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MetaChip(label: analysis.grade, color: color),
                    const SizedBox(width: 6),
                    _MetaChip(
                        label: analysis.inputMethodLabel,
                        color: AppColors.textSecondary),
                    const Spacer(),
                    Text(_dateLabel(analysis.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GeneratedCvList extends StatelessWidget {
  final List<GeneratedCv> cvs;
  final Color Function(int) scoreColor;

  const _GeneratedCvList({required this.cvs, required this.scoreColor});

  @override
  Widget build(BuildContext context) {
    if (cvs.isEmpty) {
      return const _EmptyState(message: 'لا توجد سير ذاتية منشأة بعد');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cvs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final cv = cvs[i];
        final color = scoreColor(cv.scoreTotal);

        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => GeneratedCvScreen(generatedCv: cv)),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      cv.fullName.characters.isEmpty
                          ? 'س'
                          : cv.fullName.characters.first,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cv.fullName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(cv.targetJobTitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _MetaChip(
                              label: cv.language == 'ar' ? 'عربي' : 'English',
                              color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(_dateLabel(cv.createdAt),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('${cv.scoreTotal}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(cv.grade,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * .28),
        Center(
            child: Text(message,
                style: const TextStyle(color: AppColors.textSecondary))),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 38, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(message,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

String _dateLabel(DateTime? date) {
  if (date == null) return 'غير محدد';
  return '${date.day}/${date.month}/${date.year}';
}
