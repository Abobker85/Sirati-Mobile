import 'package:flutter/material.dart';
import '../models/cv_analysis.dart';
import '../models/generated_cv.dart';
import '../services/api_exception.dart';
import '../services/cv_api_service.dart';
import '../theme/app_theme.dart';
import 'cv_analysis_screen.dart';
import 'cv_generator_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    _HomeTab(onNavigate: (i) => setState(() => _currentIndex = i)),
    const CvAnalysisScreen(),
    const CvGeneratorScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Icon(Icons.manage_search_outlined),
                activeIcon: Icon(Icons.manage_search_rounded),
                label: 'تحليل'),
            BottomNavigationBarItem(
                icon: Icon(Icons.post_add_outlined),
                activeIcon: Icon(Icons.post_add_rounded),
                label: 'إنشاء'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                activeIcon: Icon(Icons.history_rounded),
                label: 'السجل'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final void Function(int) onNavigate;

  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _apiService = CvApiService();
  late Future<_HomeSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<_HomeSummary> _loadSummary() async {
    final analyses = await _apiService.listAnalyses();
    final generatedCvs = await _apiService.listGeneratedCvs();
    return _HomeSummary.from(analyses, generatedCvs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('سيرتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white24,
              child: const Text('أ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // ── Greeting ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('أهلاً، أبوبكر 👋',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text('ماذا تريد اليوم؟',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 22),

          // ── Action cards ──
          Row(
            children: [
              Expanded(
                  child: _ActionCard(
                icon: Icons.manage_search_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'تحليل السيرة',
                subtitle: 'احصل على درجة ATS',
                onTap: () => widget.onNavigate(1),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionCard(
                icon: Icons.auto_awesome,
                iconBg: AppColors.tealLight,
                iconColor: AppColors.tealDark,
                title: 'إنشاء بالذكاء',
                subtitle: 'سيرة احترافية',
                onTap: () => widget.onNavigate(2),
              )),
            ],
          ),
          const SizedBox(height: 26),

          FutureBuilder<_HomeSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                final message = snapshot.error is ApiException
                    ? (snapshot.error as ApiException).displayMessage
                    : 'تعذر تحميل النشاطات.';

                return _HomeErrorState(
                  message: message,
                  onRetry: () =>
                      setState(() => _summaryFuture = _loadSummary()),
                );
              }

              final summary = snapshot.data ?? const _HomeSummary.empty();
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              value: '${summary.analysesCount}',
                              label: 'تحليلات',
                              color: AppColors.primaryLight,
                              textColor: AppColors.primary)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard(
                              value: '${summary.generatedCount}',
                              label: 'سير منشأة',
                              color: AppColors.tealLight,
                              textColor: AppColors.tealDark)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard(
                              value: '${summary.highestScore}',
                              label: 'أعلى درجة',
                              color: AppColors.amberLight,
                              textColor: AppColors.amber)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () => widget.onNavigate(3),
                          child: const Text('عرض الكل',
                              style: TextStyle(fontSize: 13))),
                      const Expanded(child: SizedBox()),
                      const Text('النشاطات الأخيرة',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (summary.activities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('لا توجد نشاطات بعد',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...summary.activities.map((activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ActivityTile(
                            icon: activity.isAnalysis
                                ? Icons.manage_search_rounded
                                : Icons.auto_awesome,
                            iconColor: activity.isAnalysis
                                ? AppColors.primary
                                : AppColors.tealDark,
                            iconBg: activity.isAnalysis
                                ? AppColors.primaryLight
                                : AppColors.tealLight,
                            title: activity.title,
                            subtitle: activity.subtitle,
                            badge: activity.badge,
                            badgeBg: activity.isAnalysis
                                ? AppColors.tealLight
                                : AppColors.primaryLight,
                            badgeFg: activity.isAnalysis
                                ? AppColors.tealDark
                                : AppColors.primaryDark,
                          ),
                        )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeSummary {
  final int analysesCount;
  final int generatedCount;
  final int highestScore;
  final List<_ActivityItem> activities;

  const _HomeSummary({
    required this.analysesCount,
    required this.generatedCount,
    required this.highestScore,
    required this.activities,
  });

  const _HomeSummary.empty()
      : analysesCount = 0,
        generatedCount = 0,
        highestScore = 0,
        activities = const [];

  factory _HomeSummary.from(
      List<CvAnalysis> analyses, List<GeneratedCv> generatedCvs) {
    final scores = [
      ...analyses.map((item) => item.scoreTotal),
      ...generatedCvs.map((item) => item.scoreTotal),
    ];

    final activities = <_ActivityItem>[
      ...analyses.map((analysis) => _ActivityItem(
            title: analysis.targetJobTitle,
            subtitle: 'تحليل · ${_dateLabel(analysis.createdAt)}',
            badge: '${analysis.scoreTotal}',
            createdAt: analysis.createdAt,
            isAnalysis: true,
          )),
      ...generatedCvs.map((cv) => _ActivityItem(
            title: cv.targetJobTitle,
            subtitle: 'توليد CV · ${_dateLabel(cv.createdAt)}',
            badge: 'CV',
            createdAt: cv.createdAt,
            isAnalysis: false,
          )),
    ]..sort((a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

    return _HomeSummary(
      analysesCount: analyses.length,
      generatedCount: generatedCvs.length,
      highestScore: scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b),
      activities: activities.take(3).toList(),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String badge;
  final DateTime? createdAt;
  final bool isAnalysis;

  const _ActivityItem(
      {required this.title,
      required this.subtitle,
      required this.badge,
      required this.createdAt,
      required this.isAnalysis});
}

class _HomeErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime? date) {
  if (date == null) return 'غير محدد';
  return '${date.day}/${date.month}/${date.year}';
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.icon,
      required this.iconBg,
      required this.iconColor,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.right),
          const SizedBox(height: 3),
          Text(subtitle,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color, textColor;

  const _StatCard(
      {required this.value,
      required this.label,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(.7),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle, badge;
  final Color badgeBg, badgeFg;

  const _ActivityTile(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.title,
      required this.subtitle,
      required this.badge,
      required this.badgeBg,
      required this.badgeFg});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          StatusChip(label: badge, bg: badgeBg, fg: badgeFg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    textAlign: TextAlign.right),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}
