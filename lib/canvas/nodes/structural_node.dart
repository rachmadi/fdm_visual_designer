import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/metamodel.dart';
import '../../core/state.dart';

class FolderPainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;

  FolderPainter({required this.strokeColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 22);
    path.lineTo(0, 0);
    path.lineTo(110, 0);
    path.lineTo(110, 22);
    path.lineTo(size.width, 22);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant FolderPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor || oldDelegate.fillColor != fillColor;
  }
}

class StructuralNodeWidget extends ConsumerWidget {
  final FDMNode node;

  const StructuralNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNodeId = ref.watch(diagramProvider.select((s) => s.selectedNodeId));
    final isSelected = selectedNodeId == node.id;
    
    final validationResults = ref.watch(diagramProvider.select((s) => s.validationResults));
    final nodeErrors = validationResults.where((r) => r.targetNodeId == node.id && r.severity == 'error').toList();
    final nodeWarnings = validationResults.where((r) => r.targetNodeId == node.id && r.severity == 'warning').toList();

    // Spec colors:
    // Fill: #EBF4FF, Border: #2E75B6, Text: #1A3A5C
    final Color borderCol = isSelected ? Colors.amber.shade700 : const Color(0xFF2E75B6);
    const Color fillCol = Color(0xFFEBF4FF);
    const Color textCol = Color(0xFF1A3A5C);

    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: SizedBox(
          width: 200,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: const Size(200, 80),
                painter: FolderPainter(strokeColor: borderCol, fillColor: fillCol),
              ),
              // Tab label (UML package name)
              Positioned(
                top: 2,
                left: 8,
                width: 94,
                height: 18,
                child: Center(
                  child: Text(
                    node.name,
                    style: const TextStyle(
                      color: textCol,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Main body content (Folder Icon + Path)
              Positioned(
                top: 22,
                left: 0,
                width: 200,
                height: 58,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder_open, size: 14, color: textCol),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              node.path,
                              style: TextStyle(
                                color: textCol.withOpacity(0.7),
                                fontFamily: 'monospace',
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // ── 4 Titik Koneksi Dinamis ──
              // Atas: input handle (hierarchy)
              Positioned(
                top: -5,
                left: 97,
                child: GestureDetector(
                  onTap: () {
                    ref.read(diagramProvider.notifier).setConnectionMode(EdgeType.hierarchy);
                    ref.read(diagramProvider.notifier).startConnection(node.id, null);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E75B6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [BoxShadow(color: const Color(0xFF2E75B6).withOpacity(0.5), blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
              ),
              // Bawah: output handle (hierarchy)
              Positioned(
                bottom: -5,
                left: 97,
                child: GestureDetector(
                  onTap: () {
                    ref.read(diagramProvider.notifier).setConnectionMode(EdgeType.hierarchy);
                    ref.read(diagramProvider.notifier).startConnection(node.id, null);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E75B6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [BoxShadow(color: const Color(0xFF2E75B6).withOpacity(0.5), blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
              ),
              // Kiri: side handle
              Positioned(
                left: -5,
                top: 37,
                child: GestureDetector(
                  onTap: () {
                    ref.read(diagramProvider.notifier).setConnectionMode(EdgeType.hierarchy);
                    ref.read(diagramProvider.notifier).startConnection(node.id, null);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2E75B6), width: 2),
                        boxShadow: [BoxShadow(color: const Color(0xFF2E75B6).withOpacity(0.3), blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
              ),
              // Kanan: side handle
              Positioned(
                right: -5,
                top: 37,
                child: GestureDetector(
                  onTap: () {
                    ref.read(diagramProvider.notifier).setConnectionMode(EdgeType.hierarchy);
                    ref.read(diagramProvider.notifier).startConnection(node.id, null);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E75B6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [BoxShadow(color: const Color(0xFF2E75B6).withOpacity(0.5), blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
              ),
              // Error badge in top-right
              if (nodeErrors.isNotEmpty)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Tooltip(
                    message: nodeErrors.map((e) => '[${e.ruleId}] ${e.message}').join('\n'),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                )
              else if (nodeWarnings.isNotEmpty)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Tooltip(
                    message: nodeWarnings.map((e) => '[${e.ruleId}] ${e.message}').join('\n'),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }
}
