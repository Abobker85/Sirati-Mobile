import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class MotionDurations {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 320);
}

class MotionCurves {
  static const enter = Cubic(0.22, 1, 0.36, 1);
  static const state = Cubic(0.25, 1, 0.5, 1);
  static const exit = Curves.easeInCubic;
}

class MotionSettings {
  static bool reduce(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations ?? false;
  }
}

class SiratiPageTransitionsBuilder extends PageTransitionsBuilder {
  const SiratiPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MotionSettings.reduce(context) || route.isFirst) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: MotionCurves.enter,
      reverseCurve: MotionCurves.exit,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.045, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class MotionTabStack extends StatelessWidget {
  final int currentIndex;
  final List<Widget> children;

  const MotionTabStack({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduce(context)) {
      return IndexedStack(index: currentIndex, children: children);
    }

    final textDirection = Directionality.of(context);
    final offsetDirection = textDirection == TextDirection.rtl ? -1.0 : 1.0;

    return Stack(
      children: [
        for (var index = 0; index < children.length; index++)
          _AnimatedTabPane(
            key: ValueKey('tab-$index'),
            selected: index == currentIndex,
            offsetDirection: offsetDirection,
            child: children[index],
          ),
      ],
    );
  }
}

class _AnimatedTabPane extends StatelessWidget {
  final bool selected;
  final double offsetDirection;
  final Widget child;

  const _AnimatedTabPane({
    super.key,
    required this.selected,
    required this.offsetDirection,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !selected,
      child: ExcludeSemantics(
        excluding: !selected,
        child: TickerMode(
          enabled: selected,
          child: AnimatedOpacity(
            opacity: selected ? 1 : 0,
            duration: MotionDurations.medium,
            curve: MotionCurves.state,
            child: AnimatedSlide(
              offset: selected ? Offset.zero : Offset(0.025 * offsetDirection, 0),
              duration: MotionDurations.medium,
              curve: MotionCurves.state,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class MotionReveal extends StatefulWidget {
  final Widget child;
  final int order;
  final Offset offset;
  final Duration duration;

  const MotionReveal({
    super.key,
    required this.child,
    this.order = 0,
    this.offset = const Offset(0, .035),
    this.duration = MotionDurations.medium,
  });

  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: MotionCurves.enter);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MotionSettings.reduce(context)) {
      _controller.value = 1;
      return;
    }

    if (_controller.status == AnimationStatus.dismissed && _timer == null) {
      final delay = Duration(milliseconds: math.min(widget.order * 35, 180));
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduce(context)) return widget.child;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class PressScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double pressedScale;

  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = .975,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !widget.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (MotionSettings.reduce(context) || !widget.enabled) return widget.child;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: MotionDurations.fast,
        curve: MotionCurves.state,
        child: widget.child,
      ),
    );
  }
}