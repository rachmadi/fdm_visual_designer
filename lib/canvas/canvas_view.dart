import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state.dart';
import '../../core/metamodel.dart';
import 'edges_painter.dart';
import 'nodes/structural_node.dart';
import 'nodes/entity_node.dart';
import 'nodes/security_boundary.dart';

class GridPainter extends CustomPainter {
  final Color gridColor;
  GridPainter({this.gridColor = const Color(0xFFE5E7EB)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => oldDelegate.gridColor != gridColor;
}

class CanvasView extends ConsumerStatefulWidget {
  const CanvasView({super.key});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView> {
  final TransformationController _transformationController = TransformationController();
  final double _canvasWidth = 3000.0;
  final double _canvasHeight = 3000.0;

  @override
  void initState() {
    super.initState();
    // Center the viewport inside the 3000x3000 canvas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final initialX = (_canvasWidth - size.width) / 2;
      final initialY = (_canvasHeight - size.height) / 2;
      _transformationController.value = Matrix4.identity()
        ..translate(-initialX, -initialY);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagramProvider);
    
    // Determine colors based on Theme (supporting both light and dark mode base backgrounds)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final gridColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      color: bgColor,
      child: GestureDetector(
        onTap: () {
          // Deselect everything when clicking on empty canvas
          ref.read(diagramProvider.notifier).selectNode(null);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(1000.0),
                  minScale: 0.1,
                  maxScale: 2.0,
                  child: RepaintBoundary(
                    key: ref.watch(canvasKeyProvider),
                    child: SizedBox(
                      width: _canvasWidth,
                      height: _canvasHeight,
                      child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Grid Background
                    CustomPaint(
                      size: Size(_canvasWidth, _canvasHeight),
                      painter: GridPainter(gridColor: gridColor),
                    ),

                    // Edges (drawn under nodes)
                    CustomPaint(
                      size: Size(_canvasWidth, _canvasHeight),
                      painter: EdgesPainter(
                        nodes: state.nodes,
                        edges: state.edges,
                        selectedEdgeId: state.selectedEdgeId,
                      ),
                    ),

                    // Security Boundaries
                    for (final boundary in state.boundaries)
                      SecurityBoundaryWidget(
                        key: ValueKey(boundary.id),
                        boundary: boundary,
                      ),

                    // Nodes
                    for (final node in state.nodes)
                      Positioned(
                        key: ValueKey(node.id),
                        left: node.position.dx,
                        top: node.position.dy,
                        child: node.type == NodeType.structural
                            ? StructuralNodeWidget(node: node)
                            : EntityNodeWidget(node: node),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        Positioned(
          left: 16,
          top: 16,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'DEBUG COORDINATES',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  for (final n in state.nodes)
                    Text(
                      '${n.name} (${n.id.length > 5 ? n.id.substring(n.id.length - 5) : n.id}): (${n.position.dx.toStringAsFixed(0)}, ${n.position.dy.toStringAsFixed(0)})',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                    ),
                ],
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
