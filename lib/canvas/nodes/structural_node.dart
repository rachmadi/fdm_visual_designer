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
    path.moveTo(0, 16);
    path.lineTo(0, 0);
    path.lineTo(70, 0);
    path.lineTo(90, 16);
    path.lineTo(size.width, 16);
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

    return GestureDetector(
      onTap: () {
        final isConnecting = ref.read(diagramProvider).isConnecting;
        if (isConnecting) {
          ref.read(diagramProvider.notifier).completeConnection(node.id);
        } else {
          ref.read(diagramProvider.notifier).selectNode(node.id);
        }
      },
      onPanUpdate: (details) {
        // Dragging the node
        final notifier = ref.read(diagramProvider.notifier);
        notifier.updateNodePosition(node.id, node.position + details.delta);
      },
      onPanEnd: (_) {
        ref.read(diagramProvider.notifier).finishDragging();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        onEnter: (_) => ref.read(nodeHoverProvider.notifier).setHover(true),
        onExit: (_) => ref.read(nodeHoverProvider.notifier).setHover(false),
        child: SizedBox(
          width: 200,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: const Size(200, 80),
                painter: FolderPainter(strokeColor: borderCol, fillColor: fillCol),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder, size: 14, color: textCol),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${node.name} (${node.id.length > 6 ? node.id.substring(node.id.length - 6) : node.id})',
                              style: const TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        node.path,
                        style: TextStyle(
                          color: textCol.withOpacity(0.7),
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Connection input handle (centered at top)
              Positioned(
                top: -4,
                left: 98,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E75B6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Connection output handle (centered at bottom)
              Positioned(
                bottom: -4,
                left: 98,
                child: GestureDetector(
                  onTap: () {
                    ref.read(diagramProvider.notifier).setConnectionMode(EdgeType.hierarchy);
                    ref.read(diagramProvider.notifier).startConnection(node.id, null);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E75B6),
                        shape: BoxShape.circle,
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
      ),
    );
  }
}
