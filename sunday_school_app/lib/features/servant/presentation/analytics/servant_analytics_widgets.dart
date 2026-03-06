import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'servant_analytics_calculations.dart';

class AnalyticsSectionCard extends StatelessWidget {
  const AnalyticsSectionCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14374151),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

class AnalyticsHeaderTabs extends StatelessWidget {
  const AnalyticsHeaderTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AnalyticsView selected;
  final ValueChanged<AnalyticsView> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget tab(String label, AnalyticsView value) {
      final isSelected = selected == value;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelected(value),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? cs.primary : Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('Overview', AnalyticsView.overview),
        const SizedBox(width: 8),
        tab('By Subject', AnalyticsView.subjects),
        const SizedBox(width: 8),
        tab('Students', AnalyticsView.students),
      ],
    );
  }
}

enum AnalyticsView { overview, subjects, students }

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subLabel,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subLabel;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F334155),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class TooltipController {
  OverlayEntry? _entry;

  void show(
    BuildContext context, {
    required Offset globalPosition,
    required String title,
    required String value,
  }) {
    hide();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        const width = 200.0;
        const height = 64.0;

        final left = (globalPosition.dx - width / 2).clamp(
          12.0,
          media.size.width - width - 12.0,
        );
        final top = (globalPosition.dy - height - 14).clamp(
          12.0,
          media.size.height - height - 12.0,
        );

        return Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F0F172A),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Color(0xFF0F172A)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);

    Future<void>.delayed(const Duration(seconds: 2)).then((_) => hide());
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class GradeDistributionBarChart extends StatefulWidget {
  const GradeDistributionBarChart({
    super.key,
    required this.data,
    required this.tooltipController,
  });

  final List<GradeRangeData> data;
  final TooltipController tooltipController;

  @override
  State<GradeDistributionBarChart> createState() =>
      _GradeDistributionBarChartState();
}

class _GradeDistributionBarChartState extends State<GradeDistributionBarChart> {
  @override
  Widget build(BuildContext context) {
    final maxCount = widget.data.map((e) => e.count).fold<int>(0, math.max);

    Color barColorFor(String range) {
      switch (range) {
        case '90-100':
          return Colors.green.shade500;
        case '80-89':
          return Colors.lightBlue.shade500;
        case '70-79':
          return Colors.amber.shade600;
        case '60-69':
          return Colors.orange.shade600;
        case '0-59':
          return Colors.red.shade500;
        case 'Incomplete':
        default:
          return Colors.blueGrey.shade300;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final barAreaHeight = 180.0;
        final labelHeight = 26.0;
        final chartHeight = barAreaHeight + labelHeight;

        final barWidth = (width / widget.data.length) * 0.62;
        final gap = (width / widget.data.length) * 0.38;

        final barRects = <Rect>[];

        for (var i = 0; i < widget.data.length; i++) {
          final d = widget.data[i];
          final x = i * (barWidth + gap) + gap / 2;
          final barHeight = maxCount <= 0
              ? 0.0
              : (d.count / maxCount) * (barAreaHeight - 10);
          final rect = Rect.fromLTWH(
            x,
            barAreaHeight - barHeight,
            barWidth,
            barHeight,
          );
          barRects.add(rect);
        }

        return GestureDetector(
          onTapDown: (details) {
            final local = details.localPosition;
            if (local.dy > barAreaHeight) return;

            for (var i = 0; i < barRects.length; i++) {
              if (barRects[i].contains(local)) {
                final d = widget.data[i];
                widget.tooltipController.show(
                  context,
                  globalPosition: details.globalPosition,
                  title: d.range,
                  value: 'Students: ${d.count}',
                );
                break;
              }
            }
          },
          child: SizedBox(
            height: chartHeight,
            child: CustomPaint(
              painter: _GradeDistributionPainter(
                data: widget.data,
                maxCount: maxCount,
                barColorFor: barColorFor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradeDistributionPainter extends CustomPainter {
  const _GradeDistributionPainter({
    required this.data,
    required this.maxCount,
    required this.barColorFor,
  });

  final List<GradeRangeData> data;
  final int maxCount;
  final Color Function(String range) barColorFor;

  @override
  void paint(Canvas canvas, Size size) {
    const barAreaHeight = 180.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = (barAreaHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = (size.width / data.length) * 0.62;
    final gap = (size.width / data.length) * 0.38;

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final x = i * (barWidth + gap) + gap / 2;
      final barHeight = maxCount <= 0
          ? 0.0
          : (d.count / maxCount) * (barAreaHeight - 10);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, barAreaHeight - barHeight, barWidth, barHeight),
        const Radius.circular(8),
      );

      final paint = Paint()..color = barColorFor(d.range);
      canvas.drawRRect(rect, paint);

      final labelPainter = TextPainter(
        text: TextSpan(
          text: d.range,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: barWidth + gap);

      labelPainter.paint(canvas, Offset(x - (gap / 2), barAreaHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _GradeDistributionPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.maxCount != maxCount;
  }
}

class SimpleLineChart extends StatefulWidget {
  const SimpleLineChart({
    super.key,
    required this.data,
    required this.tooltipController,
  });

  final List<AssessmentTypePerformanceData> data;
  final TooltipController tooltipController;

  @override
  State<SimpleLineChart> createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<SimpleLineChart> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final points = _linePoints(constraints.biggest, widget.data);
        return GestureDetector(
          onTapDown: (details) {
            final local = details.localPosition;
            const hitRadius = 14.0;
            for (var i = 0; i < points.length; i++) {
              if ((points[i] - local).distance <= hitRadius) {
                final d = widget.data[i];
                widget.tooltipController.show(
                  context,
                  globalPosition: details.globalPosition,
                  title: d.type,
                  value: 'Average: ${d.average}%',
                );
                break;
              }
            }
          },
          child: SizedBox(
            height: 230,
            child: CustomPaint(painter: _LineChartPainter(data: widget.data)),
          ),
        );
      },
    );
  }
}

List<Offset> _linePoints(Size size, List<AssessmentTypePerformanceData> data) {
  const padding = EdgeInsets.fromLTRB(16, 16, 16, 40);
  final w = size.width - padding.left - padding.right;
  final h = 230 - padding.top - padding.bottom;

  if (data.isEmpty) return const [];

  final dx = data.length == 1 ? 0 : w / (data.length - 1);

  Offset pointFor(int index) {
    final v = data[index].average.clamp(0, 100).toDouble();
    final x = padding.left + dx * index;
    final y = padding.top + (h - (v / 100.0) * h);
    return Offset(x, y);
  }

  return List.generate(data.length, pointFor, growable: false);
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.data});

  final List<AssessmentTypePerformanceData> data;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = EdgeInsets.fromLTRB(16, 16, 16, 40);
    final w = size.width - padding.left - padding.right;
    final h = 230 - padding.top - padding.bottom;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = padding.top + (h / 4) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
    }

    if (data.isEmpty) return;

    final points = _linePoints(size, data);

    final linePaint = Paint()
      ..color = Colors.amber.shade600
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = Colors.amber.shade600;
    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
    }

    final labelStyle = const TextStyle(fontSize: 11, color: Color(0xFF64748B));
    final xStep = data.length == 1 ? 0 : w / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = padding.left + xStep * i;
      final tp = TextPainter(
        text: TextSpan(text: data[i].type, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 70);

      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 22));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

class SimplePieChart extends StatefulWidget {
  const SimplePieChart({
    super.key,
    required this.data,
    required this.tooltipController,
  });

  final List<GradeRangeData> data;
  final TooltipController tooltipController;

  @override
  State<SimplePieChart> createState() => _SimplePieChartState();
}

class _SimplePieChartState extends State<SimplePieChart> {
  @override
  Widget build(BuildContext context) {
    final total = widget.data.fold<int>(0, (sum, d) => sum + d.count);

    Color colorForIndex(int index) {
      final colors = [
        Colors.green.shade500,
        Colors.lightBlue.shade500,
        Colors.amber.shade600,
        Colors.orange.shade600,
        Colors.red.shade500,
        Colors.blueGrey.shade300,
      ];
      return colors[index % colors.length];
    }

    return SizedBox(
      height: 240,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final radius = math.min(constraints.maxWidth, 200) / 2;
          final center = Offset(constraints.maxWidth / 2, 100);

          final segments = <_PieSegment>[];
          var start = -math.pi / 2;

          for (var i = 0; i < widget.data.length; i++) {
            final d = widget.data[i];
            final sweep = total <= 0 ? 0.0 : (d.count / total) * (math.pi * 2);
            segments.add(
              _PieSegment(
                range: d.range,
                count: d.count,
                startAngle: start,
                sweepAngle: sweep,
                color: colorForIndex(i),
              ),
            );
            start += sweep;
          }

          return GestureDetector(
            onTapDown: (details) {
              final local = details.localPosition;
              final dx = local.dx - center.dx;
              final dy = local.dy - center.dy;
              final dist = math.sqrt(dx * dx + dy * dy);
              if (dist > radius || dist < radius * 0.2) return;

              var angle = math.atan2(dy, dx);
              angle = angle < -math.pi / 2 ? angle + math.pi * 2 : angle;

              for (final s in segments) {
                final end = s.startAngle + s.sweepAngle;
                if (angle >= s.startAngle && angle <= end) {
                  widget.tooltipController.show(
                    context,
                    globalPosition: details.globalPosition,
                    title: s.range,
                    value: 'Students: ${s.count}',
                  );
                  break;
                }
              }
            },
            child: CustomPaint(
              painter: _PiePainter(
                segments: segments,
                center: center,
                radius: radius,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 170),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final s in segments)
                        _LegendItem(
                          color: s.color,
                          label: '${s.range} (${s.count})',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

class _PieSegment {
  const _PieSegment({
    required this.range,
    required this.count,
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });

  final String range;
  final int count;
  final double startAngle;
  final double sweepAngle;
  final Color color;
}

class _PiePainter extends CustomPainter {
  const _PiePainter({
    required this.segments,
    required this.center,
    required this.radius,
  });

  final List<_PieSegment> segments;
  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final s in segments) {
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        s.startAngle,
        s.sweepAngle,
        true,
        paint,
      );
    }

    canvas.drawCircle(center, radius * 0.26, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.center != center ||
        oldDelegate.radius != radius;
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: Stack(
          children: [
            Container(color: const Color(0xFFF1F5F9)),
            FractionallySizedBox(
              widthFactor: (value.clamp(0, 100) / 100),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
