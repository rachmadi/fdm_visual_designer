import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/metamodel.dart';
import '../../core/state.dart';

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedRectPainter({required this.color, this.strokeWidth = 2.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 6;

    void drawDashed(Offset p1, Offset p2) {
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (distance == 0) return;
      final int count = (distance / (dashWidth + dashSpace)).floor();
      final double xStep = dx / distance;
      final double yStep = dy / distance;
      for (int i = 0; i < count; i++) {
        final start = p1 + Offset(xStep * i * (dashWidth + dashSpace), yStep * i * (dashWidth + dashSpace));
        final end = start + Offset(xStep * dashWidth, yStep * dashWidth);
        canvas.drawLine(start, end, paint);
      }
    }

    drawDashed(Offset.zero, Offset(size.width, 0));
    drawDashed(Offset(size.width, 0), Offset(size.width, size.height));
    drawDashed(Offset(size.width, size.height), Offset(0, size.height));
    drawDashed(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class SecurityBoundaryWidget extends ConsumerWidget {
  final SecurityBoundary boundary;

  const SecurityBoundaryWidget({super.key, required this.boundary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(diagramProvider.select((s) => s.selectedBoundaryId));
    final isSelected = selectedId == boundary.id;

    final isPublic = boundary.accessLevel.toLowerCase() == 'public';
    // PUBLIC: green (#22C55E), PRIVATE: red (#EF4444)
    final Color color = isPublic ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final borderColor = isSelected ? Colors.amber.shade700 : color;

    return Positioned(
      left: boundary.rect.left,
      top: boundary.rect.top,
      width: boundary.rect.width,
      height: boundary.rect.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dashed boundary rectangle
          CustomPaint(
            size: Size(boundary.rect.width, boundary.rect.height),
            painter: DashedRectPainter(color: borderColor),
          ),
          
          // Access control tag in top-left
          Positioned(
            top: -12,
            left: 10,
            child: MouseRegion(
              cursor: SystemMouseCursors.move,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPublic ? Icons.lock_open : Icons.lock,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPublic ? 'PUBLIC' : 'PRIVATE/OWNER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Delete button in top-right
          if (isSelected)
            Positioned(
              top: -12,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  ref.read(diagramProvider.notifier).deleteBoundary(boundary.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),

          // Resize handle in bottom-right corner
          Positioned(
            right: -6,
            bottom: -6,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.open_in_full,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
