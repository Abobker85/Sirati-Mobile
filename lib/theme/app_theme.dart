import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF006A60);
  static const primaryDark = Color(0xFF00352F);
  static const primaryLight = Color(0xFF79F7E5);
  static const primaryMid = Color(0xFF59DAC9);
  static const primaryContainer = Color(0xFF00A898);
  static const onPrimary = Color(0xFFFFFFFF);

  static const teal = Color(0xFF00A898);
  static const tealLight = Color(0xFFE0F7F3);
  static const tealDark = Color(0xFF005048);

  static const amber = Color(0xFF795900);
  static const amberLight = Color(0xFFFFDF9F);
  static const amberAccent = Color(0xFFFBBC04);

  static const red = Color(0xFFBA1A1A);
  static const redLight = Color(0xFFFFDAD6);

  static const tertiary = Color(0xFF9A4528);
  static const tertiaryLight = Color(0xFFFFDBD0);

  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFFBF9F8);
  static const surfaceLow = Color(0xFFF5F3F3);
  static const surfaceContainer = Color(0xFFF0EDED);
  static const surfaceHigh = Color(0xFFEAE8E7);
  static const border = Color(0xFFBBC9C6);
  static const borderStrong = Color(0xFF6C7A77);

  static const textPrimary = Color(0xFF1B1C1C);
  static const textSecondary = Color(0xFF3C4947);
  static const textHint = Color(0xFF6C7A77);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.amber,
          tertiary: AppColors.tertiary,
          error: AppColors.red,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'IBM Plex Sans Arabic',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: AppColors.textSecondary, size: 22),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.red),
          ),
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide.none,
          ),
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primaryLight,
          labelStyle: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(fontSize: 14),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.border,
        ),
      );
}

// ── Reusable Widget Helpers ──────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SiratiMark extends StatelessWidget {
  final double size;
  final bool elevated;

  const SiratiMark({super.key, this.size = 56, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(size * .24),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x1F006A60),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                )
              ]
            : null,
      ),
      child: CustomPaint(painter: _SiratiMarkPainter()),
    );
  }
}

class _SiratiMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 512;
    final scaleY = size.height / 512;
    canvas.scale(scaleX, scaleY);

    final paper = Paint()..color = Colors.white;
    final fold = Paint()..color = const Color(0xFFE0E0E0);
    final line = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: .2);

    final document = Path()
      ..moveTo(160, 120)
      ..cubicTo(146.742, 120, 134.027, 125.268, 124.65, 134.645)
      ..cubicTo(115.273, 144.021, 110, 156.736, 110, 170)
      ..lineTo(110, 342)
      ..cubicTo(110, 355.264, 115.273, 367.979, 124.65, 377.355)
      ..cubicTo(134.027, 386.732, 146.742, 392, 160, 392)
      ..lineTo(352, 392)
      ..cubicTo(365.258, 392, 377.973, 386.732, 387.35, 377.355)
      ..cubicTo(396.727, 367.979, 402, 355.264, 402, 342)
      ..lineTo(402, 195)
      ..lineTo(327, 120)
      ..close();

    final corner = Path()
      ..moveTo(402, 195)
      ..lineTo(327, 195)
      ..lineTo(327, 120)
      ..close();

    canvas.drawPath(document, paper);
    canvas.drawPath(corner, fold);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(160, 240, 192, 24),
        const Radius.circular(4),
      ),
      line,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(160, 288, 128, 24),
        const Radius.circular(4),
      ),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const StatusChip(
      {super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
