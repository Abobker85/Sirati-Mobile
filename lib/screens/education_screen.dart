import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/mobile_content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'education_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedType = 'study';

  void _selectType(String type) {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
  }

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: MobileContentService().education(english, type: _selectedType),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _fallback(english);
          final profile = _map(data['profile']);
          final tabs = _list(data['tabs']);
          final cards = _list(data['study_cards']);
          final featured = _map(data['featured_course']);

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 104),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EducationHeader(
                  english: english,
                  name: _text(profile['name'], english ? 'Ahmed' : 'أحمد'),
                ),
              ),
              const SizedBox(height: 38),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EducationHero(
                  english: english,
                  title: _text(data['title'],
                      english ? 'Learning & Development' : 'التعلم والتطوير'),
                  subtitle: _text(
                      data['subtitle'],
                      english
                          ? 'Content tailored to your target job'
                          : 'محتوى مخصص حسب وظيفتك المستهدفة'),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _EducationTabs(
                  tabs: tabs,
                  selectedType: _text(data['selected_type'], _selectedType),
                  onSelect: _selectType,
                  english: english,
                ),
              ),
              const SizedBox(height: 28),
              _TargetRow(
                targetLabel: _text(
                    data['target_label'],
                    english
                        ? 'Based on your target job'
                        : 'حسب وظيفتك المستهدفة'),
                targetRole: _text(data['target_role'],
                    english ? 'Data Analyst' : 'محلل بيانات'),
              ),
              const SizedBox(height: 26),
              for (var index = 0; index < cards.length; index++) ...[
                _StudyCard(
                  id: _int(cards[index]['id']),
                  icon: index == 0
                      ? Icons.menu_book_outlined
                      : Icons.psychology_alt_outlined,
                  iconColor: index == 0 ? AppColors.primary : AppColors.amber,
                  title: _text(cards[index]['title'], ''),
                  body: _text(cards[index]['body'], ''),
                  duration: _text(cards[index]['duration'], ''),
                  haloTopRight: index == 0,
                  english: english,
                  onTap: () => _openDetail(context, cards[index]),
                ),
                const SizedBox(height: 20),
              ],
              _FeaturedSqlCourse(
                id: _int(featured['id']),
                english: english,
                badge: _text(
                    featured['badge'], english ? 'Recommended' : 'موصى به لك'),
                title: _text(
                    featured['title'],
                    english
                        ? 'SQL Mastery for Beginners'
                        : 'رحلة احتراف SQL للمبتدئين'),
                body: _text(
                    featured['body'],
                    english
                        ? 'A complete learning path from zero to advanced queries.'
                        : 'مسار تعليمي متكامل يأخذك من الصفر حتى بناء استعلامات معقدة.'),
                buttonLabel: _text(featured['button_label'],
                    english ? 'Start Learning' : 'ابدأ التعلم الآن'),
                onTap: () => _openDetail(context, featured),
              ),
            ],
          );
        },
      ),
    );
  }
}

Map<String, dynamic> _fallback(bool english) => {
      'profile': {'name': english ? 'Ahmed' : 'أحمد'},
      'title': english ? 'Learning & Development' : 'التعلم والتطوير',
      'subtitle': english
          ? 'Content tailored to your target job'
          : 'محتوى مخصص حسب وظيفتك المستهدفة',
      'target_label':
          english ? 'Based on your target job' : 'حسب وظيفتك المستهدفة',
      'target_role': english ? 'Data Analyst' : 'محلل بيانات',
      'tabs': [
        {'label': english ? 'News' : 'أخبار'},
        {'label': english ? 'Certificates' : 'شهادات'},
        {'label': english ? 'Study' : 'دراسة'},
      ],
      'study_cards': [
        {
          'title': english
              ? 'Big Data Analysis Basics'
              : 'أساسيات تحليل البيانات الضخمة',
          'body': english
              ? 'Learn the essential tools and methods for working with large datasets.'
              : 'تعرف على الأدوات والمنهجيات الأساسية للتعامل مع مجموعات البيانات الكبيرة.',
          'duration':
              english ? 'Reading time: 15 min' : 'مدة القراءة: ١٥ دقيقة',
        },
        {
          'title': english
              ? 'Analytical Thinking at Work'
              : 'التفكير التحليلي في بيئة العمل',
          'body': english
              ? 'Turn raw data into effective strategic decisions.'
              : 'كيفية تحويل البيانات الخام إلى قرارات استراتيجية فعالة ومدروسة.',
          'duration':
              english ? 'Reading time: 10 min' : 'مدة القراءة: ١٠ دقائق',
        },
      ],
      'featured_course': {
        'badge': english ? 'Recommended' : 'موصى به لك',
        'title':
            english ? 'SQL Mastery for Beginners' : 'رحلة احتراف SQL للمبتدئين',
        'body': english
            ? 'A complete learning path from zero to advanced queries.'
            : 'مسار تعليمي متكامل يأخذك من الصفر حتى بناء استعلامات معقدة.',
        'button_label': english ? 'Start Learning' : 'ابدأ التعلم الآن',
      },
    };

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};

List<Map<String, dynamic>> _list(dynamic value) =>
    value is List ? value.map(_map).toList() : const [];

String _text(dynamic value, String fallback) =>
    (value?.toString().isNotEmpty ?? false) ? value.toString() : fallback;

int? _int(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

void _openDetail(BuildContext context, Map<String, dynamic> data) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => EducationDetailScreen(
        id: _int(data['id']),
        fallback: data,
      ),
    ),
  );
}

class _EducationHeader extends StatelessWidget {
  final bool english;
  final String name;

  const _EducationHeader({required this.english, required this.name});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          const LanguageToggle(),
          const Spacer(),
          Directionality(
            textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            child: Text(
              english ? 'Hello, $name' : 'أهلاً، $name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 31),
          ),
        ],
      ),
    );
  }
}

class _EducationHero extends StatelessWidget {
  final bool english;
  final String title;
  final String subtitle;

  const _EducationHero({
    required this.english,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          textAlign: english ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            fontSize: 22,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: english ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EducationTabs extends StatelessWidget {
  final List<Map<String, dynamic>> tabs;
  final String selectedType;
  final ValueChanged<String> onSelect;
  final bool english;

  const _EducationTabs({
    required this.tabs,
    required this.selectedType,
    required this.onSelect,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = [
      {'key': 'news', 'label': english ? 'News' : 'أخبار'},
      {'key': 'certificates', 'label': english ? 'Certificates' : 'شهادات'},
      {'key': 'study', 'label': english ? 'Study' : 'دراسة'},
    ];
    final source = tabs.isNotEmpty ? tabs : fallback;

    return Container(
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final tab in source)
            Expanded(
              child: _TabPill(
                label: _text(tab['label'], ''),
                selected: _text(tab['key'], '') == selectedType,
                onTap: () => onSelect(_text(tab['key'], 'study')),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String targetLabel;
  final String targetRole;

  const _TargetRow({required this.targetLabel, required this.targetRole});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0, end: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryMid.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              targetRole,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            targetLabel,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  final int? id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String duration;
  final bool haloTopRight;
  final bool english;
  final VoidCallback onTap;

  const _StudyCard({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.duration,
    required this.haloTopRight,
    required this.english,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.borderStrong.withValues(alpha: .42)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: haloTopRight ? -58 : null,
              right: haloTopRight ? -58 : null,
              bottom: haloTopRight ? null : -62,
              left: haloTopRight ? null : -62,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment:
                  english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Icon(icon, color: iconColor, size: 40),
                const SizedBox(height: 32),
                Text(
                  title,
                  textAlign: english ? TextAlign.left : TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  body,
                  textAlign: english ? TextAlign.left : TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.65,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment:
                      english ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.schedule_rounded,
                        color: AppColors.primary, size: 17),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSqlCourse extends StatelessWidget {
  final int? id;
  final bool english;
  final String badge;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onTap;

  const _FeaturedSqlCourse({
    required this.id,
    required this.english,
    required this.badge,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF102E2E),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _MonitorBackdrop(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .05),
                    Colors.black.withValues(alpha: .62),
                  ],
                ),
              ),
            ),
            Positioned(
              top: english ? 48 : 64,
              right: english ? null : 36,
              left: english ? 28 : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMid.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              left: 30,
              bottom: english ? 26 : 30,
              child: Column(
                crossAxisAlignment:
                    english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  if (english) const SizedBox(height: 28),
                  Text(
                    title,
                    textAlign: english ? TextAlign.left : TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: english ? TextAlign.left : TextAlign.right,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment:
                        english ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitorBackdrop extends StatelessWidget {
  const _MonitorBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MonitorBackdropPainter());
  }
}

class _MonitorBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF143434);
    canvas.drawRect(Offset.zero & size, background);

    final screenPaint = Paint()..color = const Color(0xFF1C5551);
    final linePaint = Paint()
      ..color = AppColors.primaryMid.withValues(alpha: .55)
      ..strokeWidth = 2;
    final glowPaint = Paint()..color = Colors.black.withValues(alpha: .22);

    for (final rect in [
      Rect.fromLTWH(size.width * .08, 54, 120, 92),
      Rect.fromLTWH(size.width * .38, 38, 136, 102),
      Rect.fromLTWH(size.width * .68, 56, 120, 90),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.shift(const Offset(0, 6)), const Radius.circular(6)),
        glowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        screenPaint,
      );

      for (var index = 0; index < 5; index++) {
        final y = rect.top + 18 + index * 13;
        canvas.drawLine(
          Offset(rect.left + 14, y),
          Offset(rect.right - 18 - index * 7, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
