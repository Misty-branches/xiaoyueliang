import 'package:flutter/material.dart';
import 'theme_colors.dart';

class ThemeColors {
  final AppColors colors;
  ThemeColors(this.colors);

  // Moon icon - a crescent moon
  static Widget moonIcon(BuildContext context, {double size = 48, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoonPainter(color: c, isFilled: false),
      ),
    );
  }

  // Sun icon
  static Widget sunIcon(BuildContext context, {double size = 24, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accentWarm;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunPainter(color: c),
      ),
    );
  }

  // Star icon
  static Widget starIcon(BuildContext context, {double size = 20, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accentWarm;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(color: c),
      ),
    );
  }

  // Chat bubble icon (simple)
  static Widget chatIcon(BuildContext context, {double size = 28, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChatPainter(color: c),
      ),
    );
  }

  // Book icon
  static Widget bookIcon(BuildContext context, {double size = 28, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BookPainter(color: c),
      ),
    );
  }

  // Pencil / diary icon
  static Widget diaryIcon(BuildContext context, {double size = 28, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiaryPainter(color: c),
      ),
    );
  }

  // Checkbox / todo icon
  static Widget todoIcon(BuildContext context, {double size = 28, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TodoPainter(color: c),
      ),
    );
  }

  // Echo / sound wave icon
  static Widget echoIcon(BuildContext context, {double size = 28, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EchoPainter(color: c),
      ),
    );
  }

  // Settings gear icon
  static Widget settingsIcon(BuildContext context, {double size = 24, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.secondaryText;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SettingsPainter(color: c),
      ),
    );
  }

  // Arrow right
  static Widget arrowRightIcon(BuildContext context, {double size = 20, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.secondaryText;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArrowRightPainter(color: c),
      ),
    );
  }

  // Send arrow (upward)
  static Widget sendIcon(BuildContext context, {double size = 18, Color? color}) {
    final c = color ?? Colors.white;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SendPainter(color: c),
      ),
    );
  }

  // Home icon
  static Widget homeIcon(BuildContext context, {double size = 24, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.secondaryText;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HomePainter(color: c),
      ),
    );
  }

  // Plus icon
  static Widget plusIcon(BuildContext context, {double size = 22, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.accent;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlusPainter(color: c),
      ),
    );
  }

  // Back arrow
  static Widget backIcon(BuildContext context, {double size = 22, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.mainText;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BackPainter(color: c),
      ),
    );
  }

  // Trash icon
  static Widget trashIcon(BuildContext context, {double size = 18, Color? color}) {
    final c = color ?? Theme.of(context).extension<AppColors>()!.secondaryText;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrashPainter(color: c),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  _MoonPainter({required this.color, this.isFilled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    canvas.drawCircle(center, radius, paint);
    if (!isFilled) {
      final maskPaint = Paint()
        ..color = const Color(0xFFF2F0EB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(center.dx + radius * 0.35, center.dy - radius * 0.25),
          radius * 0.75,
          maskPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SunPainter extends CustomPainter {
  final Color color;
  _SunPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;
    canvas.drawCircle(center, radius, paint);
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final dx1 = center.dx + (radius + 2) * _cos(angle);
      final dy1 = center.dy + (radius + 2) * _sin(angle);
      final dx2 = center.dx + (radius + 6) * _cos(angle);
      final dy2 = center.dy + (radius + 6) * _sin(angle);
      canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), paint);
    }
  }

  double _cos(double a) => _fsin(a + 1.5708);
  double _sin(double a) => _fsin(a);
  double _fsin(double a) {
    double s = 0;
    double term = a;
    for (int n = 1; n <= 5; n++) {
      s += term;
      term *= -a * a / ((2 * n) * (2 * n + 1));
    }
    return s;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 2;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = -1.5708 + i * 3.14159 / 5;
      final rad = i.isEven ? r : r * 0.4;
      final x = cx + rad * _fsin(angle);
      final y = cy - rad * _fsin(angle + 1.5708);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _fsin(double a) {
    double s = 0, term = a;
    for (int n = 1; n <= 5; n++) {
      s += term;
      term *= -a * a / ((2 * n) * (2 * n + 1));
    }
    return s;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChatPainter extends CustomPainter {
  final Color color;
  _ChatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(2, 2, size.width - 6, size.height * 0.7),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.7);
    path.lineTo(size.width * 0.15, size.height - 2);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookPainter extends CustomPainter {
  final Color color;
  _BookPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    // left page
    canvas.drawRect(
        Rect.fromLTWH(2, 3, size.width / 2 - 3, size.height - 6), paint);
    // right page
    canvas.drawRect(
        Rect.fromLTWH(size.width / 2 + 1, 3, size.width / 2 - 3, size.height - 6),
        paint);
    // spine
    canvas.drawLine(Offset(size.width / 2, 3),
        Offset(size.width / 2, size.height - 3), paint);
    // horizontal lines
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double y = size.height * 0.3; y < size.height - 6; y += 4) {
      canvas.drawLine(Offset(6, y), Offset(size.width / 2 - 4, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiaryPainter extends CustomPainter {
  final Color color;
  _DiaryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final rect = Rect.fromLTWH(3, 2, size.width - 6, size.height - 4);
    canvas.drawRect(rect, paint);
    // pencil line
    canvas.drawLine(
        Offset(8, size.height * 0.35),
        Offset(size.width - 8, size.height * 0.35),
        paint);
    canvas.drawLine(
        Offset(8, size.height * 0.5),
        Offset(size.width - 8, size.height * 0.5),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    canvas.drawLine(
        Offset(8, size.height * 0.65),
        Offset(size.width - 8, size.height * 0.65),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TodoPainter extends CustomPainter {
  final Color color;
  _TodoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final rect = Rect.fromLTWH(2, size.height / 2 - 6, 12, 12);
    canvas.drawRect(rect, paint);
    // check mark
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    path.moveTo(4, size.height / 2);
    path.lineTo(7, size.height / 2 + 4);
    path.lineTo(12, size.height / 2 - 2);
    canvas.drawPath(path, checkPaint);
    // list lines
    for (double y = size.height * 0.25; y <= size.height * 0.7; y += 5) {
      canvas.drawLine(
          Offset(18, y), Offset(size.width - 2, y),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EchoPainter extends CustomPainter {
  final Color color;
  _EchoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    // sound waves
    for (int i = 0; i < 3; i++) {
      final r = 4 + i * 5;
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2), width: r * 2, height: r * 2),
          -0.8,
          1.6,
          false,
          paint);
    }
    // dot at center
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsPainter extends CustomPainter {
  final Color color;
  _SettingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 3, paint);
    // small teeth
    for (int i = 0; i < 12; i++) {
      final angle = i * 3.14159 / 6;
      final outerR = size.width / 3 + 3;
      final innerR = size.width / 3 - 1;
      final x1 = center.dx + outerR * _fsin(angle);
      final y1 = center.dy - outerR * _fsin(angle + 1.5708);
      final x2 = center.dx + innerR * _fsin(angle);
      final y2 = center.dy - innerR * _fsin(angle + 1.5708);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  double _fsin(double a) {
    double s = 0, term = a;
    for (int n = 1; n <= 5; n++) {
      s += term;
      term *= -a * a / ((2 * n) * (2 * n + 1));
    }
    return s;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowRightPainter extends CustomPainter {
  final Color color;
  _ArrowRightPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final cy = size.height / 2;
    canvas.drawLine(Offset(2, cy), Offset(size.width - 4, cy), paint);
    canvas.drawLine(Offset(size.width - 8, cy - 5), Offset(size.width - 2, cy), paint);
    canvas.drawLine(Offset(size.width - 8, cy + 5), Offset(size.width - 2, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SendPainter extends CustomPainter {
  final Color color;
  _SendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // upward arrow
    final path = Path();
    path.moveTo(size.width / 2, 2);
    path.lineTo(size.width - 2, size.height - 2);
    path.lineTo(size.width / 2, size.height * 0.65);
    path.lineTo(2, size.height - 2);
    path.close();
    canvas.drawPath(path, Paint()
      ..color = color
      ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomePainter extends CustomPainter {
  final Color color;
  _HomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    // roof
    final path = Path();
    path.moveTo(2, size.height * 0.5);
    path.lineTo(size.width / 2, 2);
    path.lineTo(size.width - 2, size.height * 0.5);
    canvas.drawPath(path, paint);
    // walls
    canvas.drawRect(
        Rect.fromLTWH(4, size.height * 0.5, size.width - 8, size.height * 0.48),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlusPainter extends CustomPainter {
  final Color color;
  _PlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final cx = size.width / 2, cy = size.height / 2;
    canvas.drawLine(Offset(cx, 3), Offset(cx, size.height - 3), paint);
    canvas.drawLine(Offset(3, cy), Offset(size.width - 3, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackPainter extends CustomPainter {
  final Color color;
  _BackPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final cy = size.height / 2;
    canvas.drawLine(Offset(size.width - 2, cy), Offset(4, cy), paint);
    canvas.drawLine(Offset(8, cy - 5), Offset(2, cy), paint);
    canvas.drawLine(Offset(8, cy + 5), Offset(2, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrashPainter extends CustomPainter {
  final Color color;
  _TrashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    // lid
    canvas.drawLine(Offset(3, 5), Offset(size.width - 3, 5), paint);
    // body
    canvas.drawRect(
        Rect.fromLTWH(4, 8, size.width - 8, size.height - 10), paint);
    // lines inside
    canvas.drawLine(Offset(size.width * 0.35, 11),
        Offset(size.width * 0.35, size.height - 5), paint);
    canvas.drawLine(Offset(size.width / 2, 11),
        Offset(size.width / 2, size.height - 5), paint);
    canvas.drawLine(Offset(size.width * 0.65, 11),
        Offset(size.width * 0.65, size.height - 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
