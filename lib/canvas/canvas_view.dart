import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../../core/state.dart';
import '../../core/metamodel.dart';
import 'edges_painter.dart';
import 'nodes/structural_node.dart';
import 'nodes/entity_node.dart';
import 'nodes/security_boundary.dart';

class GridPainter extends CustomPainter {
  final Color gridColor;
  final bool showGrid;

  GridPainter({this.gridColor = const Color(0xFFE2E8F0), this.showGrid = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid) return;
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const double step = 20.0; // Spec: 20px grid cell size
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor || oldDelegate.showGrid != showGrid;
}

/// CanvasView menggunakan InteractiveViewer + TransformationController untuk zoom/pan.
/// Untuk hit-testing node saat drag, koordinat pointer dari screen space
/// ditransformasi ke canvas space menggunakan invers matrix InteractiveViewer.
class CanvasView extends ConsumerStatefulWidget {
  const CanvasView({super.key});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView> {
  static const double _canvasWidth = 4000.0;
  static const double _canvasHeight = 4000.0;

  final TransformationController _transformationController =
      TransformationController();

  // Node/boundary being dragged (ID)
  String? _draggingNodeId;
  String? _draggingBoundaryId;
  Offset? _lastPointerPosition;

  // Whether we are currently dragging a node (controls InteractiveViewer panEnabled)
  bool _isDraggingNode = false;

  @override
  void initState() {
    super.initState();
    // Center the viewport on the canvas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Translate to center: start at canvas center
      final m = Matrix4.translationValues(
        -(_canvasWidth / 2 - 400), -(_canvasHeight / 2 - 300), 0.0);
      _transformationController.value = m;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Converts a screen-space position to canvas-space coordinates
  /// by applying the inverse of the current transformation matrix.
  Offset _screenToCanvas(Offset screenPos) {
    final Matrix4 transform = _transformationController.value;
    final Matrix4 inverse = Matrix4.inverted(transform);
    final Vector3 vec =
        inverse.transform3(Vector3(screenPos.dx, screenPos.dy, 0.0));
    return Offset(vec.x, vec.y);
  }

  /// Returns approximate hit rect for a node in canvas space
  Rect _nodeRect(FDMNode node) {
    final double w = node.type == NodeType.structural ? 200 : 220;
    // Approximate height — nodes grow with properties, use a generous bound
    final double h = node.type == NodeType.structural
        ? 80
        : 60.0 + (node.properties.length * 38.0).clamp(38.0, 600.0);
    return Rect.fromLTWH(node.position.dx, node.position.dy, w, h);
  }

  String? _hitTestNode(Offset canvasPos) {
    final nodes = ref.read(diagramProvider).nodes;
    // Iterate in reverse so topmost (last drawn) node is hit first
    for (int i = nodes.length - 1; i >= 0; i--) {
      if (_nodeRect(nodes[i]).contains(canvasPos)) {
        return nodes[i].id;
      }
    }
    return null;
  }

  String? _hitTestBoundary(Offset canvasPos) {
    final boundaries = ref.read(diagramProvider).boundaries;
    for (int i = boundaries.length - 1; i >= 0; i--) {
      final b = boundaries[i];
      // Only hit the label/drag strip at the top of the boundary
      final labelRect =
          Rect.fromLTWH(b.rect.left + 10, b.rect.top - 12, 100, 28);
      if (labelRect.contains(canvasPos)) return b.id;
    }
    return null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final canvasPos = _screenToCanvas(event.localPosition);
    _lastPointerPosition = event.localPosition;

    final nodeId = _hitTestNode(canvasPos);
    if (nodeId != null) {
      final isConnecting = ref.read(diagramProvider).isConnecting;
      if (isConnecting) {
        ref.read(diagramProvider.notifier).completeConnection(nodeId);
      } else {
        ref.read(diagramProvider.notifier).selectNode(nodeId);
        _draggingNodeId = nodeId;
        // Disable InteractiveViewer pan while we drag a node
        setState(() => _isDraggingNode = true);
      }
      return;
    }

    final boundaryId = _hitTestBoundary(canvasPos);
    if (boundaryId != null) {
      _draggingBoundaryId = boundaryId;
      ref.read(diagramProvider.notifier).selectBoundary(boundaryId);
      setState(() => _isDraggingNode = true); // block IV panning for boundaries too
      return;
    }

    // Empty space — let InteractiveViewer pan
    ref.read(diagramProvider.notifier).selectNode(null);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_lastPointerPosition == null) return;

    if (_draggingNodeId != null) {
      // Convert delta to canvas space by computing the scale factor
      final scale = _transformationController.value.getMaxScaleOnAxis();
      final delta = event.localPosition - _lastPointerPosition!;
      final scaledDelta = delta / scale;

      final node = ref
          .read(diagramProvider)
          .nodes
          .firstWhere((n) => n.id == _draggingNodeId);
      ref.read(diagramProvider.notifier).updateNodePosition(
            _draggingNodeId!,
            node.position + scaledDelta,
          );
    } else if (_draggingBoundaryId != null) {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      final delta = event.localPosition - _lastPointerPosition!;
      final scaledDelta = delta / scale;

      final boundary = ref
          .read(diagramProvider)
          .boundaries
          .firstWhere((b) => b.id == _draggingBoundaryId);
      ref.read(diagramProvider.notifier).updateBoundaryRect(
            _draggingBoundaryId!,
            boundary.rect.shift(scaledDelta),
          );
    }

    _lastPointerPosition = event.localPosition;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_draggingNodeId != null || _draggingBoundaryId != null) {
      ref.read(diagramProvider.notifier).finishDragging();
    }
    _draggingNodeId = null;
    _draggingBoundaryId = null;
    _lastPointerPosition = null;
    // Re-enable InteractiveViewer pan/scale
    if (_isDraggingNode) {
      setState(() => _isDraggingNode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagramProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final gridColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final modeColor = state.isFirestoreMode
        ? const Color(0xFF2E75B6)
        : const Color(0xFF00897B);
    final modeLabel =
        state.isFirestoreMode ? 'Firestore Mode' : 'RTDB Mode';

    return Container(
      color: bgColor,
      // Listener wraps InteractiveViewer to receive raw pointer events
      // for hit-testing nodes before InteractiveViewer consumes them.
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        behavior: HitTestBehavior.translucent,
        child: InteractiveViewer(
          transformationController: _transformationController,
          // Disable panning when we're actively dragging a node to prevent
          // the InteractiveViewer from capturing our drag gesture
          panEnabled: !_isDraggingNode,
          scaleEnabled: !_isDraggingNode,
          boundaryMargin: const EdgeInsets.all(500),
          minScale: 0.1,
          maxScale: 4.0,
          child: RepaintBoundary(
            key: ref.watch(canvasKeyProvider),
            child: SizedBox(
              width: _canvasWidth,
              height: _canvasHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Layer 1: Background color
                  Positioned.fill(
                    child: Container(color: bgColor),
                  ),

                  // Layer 2: Grid
                  CustomPaint(
                    size: const Size(_canvasWidth, _canvasHeight),
                    painter: GridPainter(gridColor: gridColor),
                  ),

                  // Layer 3: Security Boundaries (below edges and nodes)
                  for (final boundary in state.boundaries)
                    SecurityBoundaryWidget(
                      key: ValueKey(boundary.id),
                      boundary: boundary,
                    ),

                  // Layer 4: Edges (below nodes)
                  CustomPaint(
                    size: const Size(_canvasWidth, _canvasHeight),
                    painter: EdgesPainter(
                      nodes: state.nodes,
                      edges: state.edges,
                      selectedEdgeId: state.selectedEdgeId,
                    ),
                  ),

                  // Layer 5: Nodes
                  for (final node in state.nodes)
                    Positioned(
                      key: ValueKey(node.id),
                      left: node.position.dx,
                      top: node.position.dy,
                      child: node.type == NodeType.structural
                          ? StructuralNodeWidget(node: node)
                          : EntityNodeWidget(node: node),
                    ),

                  // Mode tag — top-left corner (Layer 8 conceptually)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: modeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: modeColor, width: 1),
                      ),
                      child: Text(
                        modeLabel,
                        style: TextStyle(
                          color: modeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
