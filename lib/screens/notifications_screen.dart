import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../services/mobile_content_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = MobileContentService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.notifications();
  }

  void _refresh() {
    setState(() => _future = _service.notifications());
  }

  Future<void> _markAllRead() async {
    await _service.markAllNotificationsRead();
    _refresh();
  }

  Future<void> _markRead(int? id) async {
    if (id == null) return;
    await _service.markNotificationRead(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final english = AppLocale.isEnglish(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(english ? 'Notifications' : 'الإشعارات'),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(english ? 'Read all' : 'قراءة الكل'),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const {};
          final items = _list(data['items']);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  english ? 'No notifications yet.' : 'لا توجد إشعارات حالياً.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _NotificationCard(
                item: item,
                english: english,
                onTap: () => _markRead(_int(item['id'])),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool english;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.item,
    required this.english,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = item['is_read'] == true;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? AppColors.border.withValues(alpha: .65)
                  : AppColors.primary.withValues(alpha: .5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!english) ...[
                Expanded(child: _TextBlock(item: item, english: english)),
                const SizedBox(width: 12),
              ],
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isRead
                      ? AppColors.surfaceHigh
                      : AppColors.primaryMid.withValues(alpha: .3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_outlined,
                  color: isRead ? AppColors.textHint : AppColors.primary,
                  size: 22,
                ),
              ),
              if (english) ...[
                const SizedBox(width: 12),
                Expanded(child: _TextBlock(item: item, english: english)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool english;

  const _TextBlock({required this.item, required this.english});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          english ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          _text(item['title'], ''),
          textAlign: english ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _text(item['body'], ''),
          textAlign: english ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _text(item['created_label'], ''),
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};
List<Map<String, dynamic>> _list(dynamic value) =>
    value is List ? value.map(_map).toList() : const [];
String _text(dynamic value, String fallback) =>
    (value?.toString().isNotEmpty ?? false) ? value.toString() : fallback;
int? _int(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');
