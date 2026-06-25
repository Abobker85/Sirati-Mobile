import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/mobile_content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'cv_analysis_screen.dart';
import 'cv_generator_screen.dart';
import 'education_screen.dart';
import 'history_screen.dart';
import 'job_news_screen.dart';
import 'my_cvs_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex = widget.initialIndex;

  late final List<Widget> _tabs = [
    _DashboardTab(onNavigate: (index) => setState(() => _currentIndex = index)),
    const MyCvsScreen(),
    const EducationScreen(),
    const JobNewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _DashboardNavigationBar(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _DashboardTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: MobileContentService().dashboard(english),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _dashboardFallback(english);
          final profile = _map(data['profile']);
          final stats = _map(data['stats']);
          final primary = _map(data['primary_action']);
          final analysis = _map(data['analysis_action']);
          final news = _map(data['latest_news']);

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 104),
                children: [
                  _DashboardHeader(
                    english: english,
                    name: _string(profile['name'],
                        fallback: english ? 'Mohammed' : 'محمد'),
                    status: _string(profile['status'],
                        fallback: english ? 'Pending Account' : 'حساب معلق'),
                    unreadNotifications: _int(stats['unread_notifications']),
                    onNotifications: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Expanded(
                          child: _DashboardStatCard(
                            label: english ? 'Analyses' : 'التحليلات',
                            value: _countLabel(stats['analyses']),
                            icon: Icons.analytics_outlined,
                            english: english,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DashboardStatCard(
                            label: english ? 'My CVs' : 'السير الذاتية',
                            value: _countLabel(stats['generated_cvs']),
                            icon: Icons.description_outlined,
                            english: english,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DashboardActionCard(
                    title: _string(primary['title']),
                    subtitle: _string(primary['subtitle']),
                    buttonLabel: _string(primary['button_label']),
                    backgroundColor: AppColors.primary,
                    buttonColor: AppColors.surface,
                    buttonTextColor: AppColors.primary,
                    icon: Icons.edit_document,
                    watermark: Icons.description_outlined,
                    onTap: () => _openCreateCv(context),
                    english: english,
                  ),
                  const SizedBox(height: 14),
                  _DashboardActionCard(
                    title: _string(analysis['title']),
                    subtitle: _string(analysis['subtitle']),
                    buttonLabel: _string(analysis['button_label']),
                    backgroundColor: AppColors.amber,
                    buttonColor: AppColors.amberLight,
                    buttonTextColor: AppColors.textPrimary,
                    icon: Icons.manage_search_outlined,
                    watermark: Icons.search_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CvAnalysisScreen()),
                    ),
                    english: english,
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment:
                        english ? Alignment.centerLeft : Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: Text(english ? 'History' : 'السجل'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => onNavigate(1),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          english ? 'View All' : 'عرض الكل',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        english ? 'Latest News' : 'آخر الأخبار',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _NewsCard(
                    title: _string(news['title']),
                    subtitle: _string(news['subtitle']),
                    english: english,
                  ),
                ],
              ),
              PositionedDirectional(
                start: 24,
                bottom: 18,
                child: _AddButton(onTap: () => _openCreateCv(context)),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _openCreateCv(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CvGeneratorScreen()),
  );
}

Map<String, dynamic> _dashboardFallback(bool english) {
  return {
    'profile': {
      'name': english ? 'Mohammed' : 'محمد',
      'status': english ? 'Pending Account' : 'حساب معلق',
    },
    'stats': {'generated_cvs': 145, 'analyses': 2},
    'primary_action': {
      'title': english ? 'Create ATS-Optimized CV' : 'أنشئ سيرة ذاتية وفق ATS',
      'subtitle': english
          ? 'Build your CV step by step and get a professional design that passes screening systems.'
          : 'ابن سيرتك خطوة بخطوة واحصل على تصميم احترافي يتجاوز أنظمة الفرز.',
      'button_label': english ? 'Start Now' : 'ابدأ الآن',
    },
    'analysis_action': {
      'title':
          english ? 'Analyze Your CV with ATS' : 'حلّل سيرتك الذاتية بـ ATS',
      'subtitle': english
          ? 'Upload your CV and discover its strengths and match with target jobs.'
          : 'ارفع سيرتك واعرف نقاط قوتها ومدى توافقها مع الوظائف المستهدفة.',
      'button_label': english ? 'Analyze Now' : 'تحليل الآن',
    },
    'latest_news': {
      'title': english
          ? 'New opportunities in tech'
          : 'فرص عمل جديدة في مجال التقنية',
      'subtitle': english ? '2 hours ago · Riyadh' : 'منذ ساعتين · الرياض',
    },
  };
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};

String _string(dynamic value, {String fallback = ''}) {
  final text = value?.toString() ?? fallback;
  return text.isEmpty ? fallback : text;
}

String _countLabel(dynamic value) {
  final number =
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
  return number.toString().padLeft(2, '0');
}

int _int(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

class _DashboardHeader extends StatelessWidget {
  final bool english;
  final String name;
  final String status;
  final int unreadNotifications;
  final VoidCallback onNotifications;

  const _DashboardHeader({
    required this.english,
    required this.name,
    required this.status,
    required this.unreadNotifications,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          _NotificationButton(
            unreadCount: unreadNotifications,
            onTap: onNotifications,
          ),
          const SizedBox(width: 10),
          const LanguageToggle(),
          const Spacer(),
          Directionality(
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            child: Column(
              crossAxisAlignment:
                  english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  english ? 'Hello, $name' : 'أهلاً، $name',
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 5,
                      backgroundColor: AppColors.amberAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _ProfileAvatar(),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLow,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.textPrimary, size: 26),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CircleIconButton(
          icon: Icons.notifications_outlined,
          onTap: onTap,
        ),
        if (unreadCount > 0)
          PositionedDirectional(
            top: -2,
            end: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 32, color: AppColors.primary),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool english;

  const _DashboardStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: english ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.borderStrong.withValues(alpha: .45)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -34,
              right: english ? null : -16,
              left: english ? -16 : null,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer.withValues(alpha: .8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: english ? Alignment.topLeft : Alignment.topRight,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Align(
              alignment: english ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Icon(
                icon,
                size: 25,
                color: AppColors.primary.withValues(alpha: .35),
              ),
            ),
            Align(
              alignment: english ? Alignment.bottomLeft : Alignment.bottomRight,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color backgroundColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final IconData icon;
  final IconData watermark;
  final VoidCallback onTap;
  final bool english;

  const _DashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.backgroundColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.icon,
    required this.watermark,
    required this.onTap,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 280,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              Positioned(
                left: english ? null : -52,
                right: english ? -52 : null,
                bottom: -54,
                child: Icon(
                  watermark,
                  size: 148,
                  color: Colors.white.withValues(alpha: .12),
                ),
              ),
              Positioned(
                top: 0,
                right: english ? null : 0,
                left: english ? 0 : null,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Column(
                    crossAxisAlignment: english
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        textAlign: english ? TextAlign.left : TextAlign.right,
                        style: const TextStyle(
                          fontSize: 27,
                          height: 1.18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        subtitle,
                        textAlign: english ? TextAlign.left : TextAlign.right,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.42,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: .92),
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: english
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  buttonLabel,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: buttonTextColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  english
                                      ? Icons.arrow_forward_rounded
                                      : Icons.arrow_back_rounded,
                                  size: 18,
                                  color: buttonTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool english;

  const _NewsCard({
    required this.title,
    required this.subtitle,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.borderStrong.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_left_rounded,
              color: AppColors.textHint, size: 30),
          const Spacer(),
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment:
                  english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: english ? TextAlign.left : TextAlign.right,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business_center_outlined,
                color: AppColors.primary, size: 27),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amberAccent,
      borderRadius: BorderRadius.circular(14),
      elevation: 10,
      shadowColor: AppColors.amberAccent.withValues(alpha: .35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 58,
          height: 58,
          child:
              Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 38),
        ),
      ),
    );
  }
}

class _DashboardNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _DashboardNavigationBar({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);
    const items = [
      _NavItemData(
          index: 3,
          icon: Icons.work_outline_rounded,
          labelAr: 'الوظائف',
          labelEn: 'Job News'),
      _NavItemData(
          index: 2,
          icon: Icons.school_outlined,
          labelAr: 'التعليم',
          labelEn: 'Education'),
      _NavItemData(
          index: 1,
          icon: Icons.description_outlined,
          labelAr: 'سيراتي',
          labelEn: 'My CVs'),
      _NavItemData(
          index: 0,
          icon: Icons.home_outlined,
          labelAr: 'الرئيسية',
          labelEn: 'Home'),
    ];

    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border:
            Border.all(color: AppColors.borderStrong.withValues(alpha: .35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final item in items)
              _NavigationItem(
                data: item,
                english: english,
                selected: currentIndex == item.index,
                onTap: () => onChanged(item.index),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final int index;
  final IconData icon;
  final String labelAr;
  final String labelEn;

  const _NavItemData({
    required this.index,
    required this.icon,
    required this.labelAr,
    required this.labelEn,
  });
}

class _NavigationItem extends StatelessWidget {
  final _NavItemData data;
  final bool english;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.data,
    required this.english,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textHint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 4,
          vertical: selected ? 7 : 4,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryMid.withValues(alpha: .75)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, color: color, size: 25),
            const SizedBox(height: 3),
            Text(
              english ? data.labelEn : data.labelAr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
