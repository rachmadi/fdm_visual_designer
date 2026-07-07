import 'dart:math' as math;
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
      ..strokeWidth = 1.0;

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
  int? _activePointerId; // Track the pointer ID currently doing the drag

  // Whether we are currently dragging a node (controls InteractiveViewer panEnabled)
  bool _isDraggingNode = false;

  @override
  void initState() {
    super.initState();
    // Center viewport on node spawn area (nodes spawn around 1400,1400)
    // We use addPostFrameCallback to get actual render size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerViewport();
    });
  }

  void _centerViewport() {
    if (!mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    final viewportSize = renderBox?.size ?? const Size(800, 600);
    // Center the viewport at the node spawn area (canvas ~1450,1450)
    const double spawnX = 1450.0;
    const double spawnY = 1450.0;
    final tx = viewportSize.width / 2 - spawnX;
    final ty = viewportSize.height / 2 - spawnY;
    _transformationController.value = Matrix4.translationValues(tx, ty, 0.0);
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
    double h = node.type == NodeType.structural
        ? 80
        : 60.0 + (node.properties.length * 38.0).clamp(38.0, 600.0);
    if (node.type == NodeType.entity &&
        (node.queryVector.filterFields.isNotEmpty || node.queryVector.sortFields.isNotEmpty)) {
      h += 50.0;
    }
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

  FDMNode? _findNode(String id) {
    final nodes = ref.read(diagramProvider).nodes;
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  double _getNodeWidth(FDMNode node) {
    return node.type == NodeType.structural ? 200.0 : 220.0;
  }

  double _getNodeHeight(FDMNode node) {
    if (node.type == NodeType.structural) {
      return 80.0;
    } else {
      if (node.properties.isEmpty) {
        return 36.0 + 18.0 + 1.0 + 12.0 + 35.0;
      }
      return 36.0 + 18.0 + 1.0 + 12.0 + node.properties.length * 28.0;
    }
  }

  Offset _nodeCenter(FDMNode node) {
    return Offset(
      node.position.dx + _getNodeWidth(node) / 2,
      node.position.dy + _getNodeHeight(node) / 2,
    );
  }

  Offset _getDynamicAnchor(FDMNode fromNode, FDMNode toNode, {required bool forSource}) {
    final fromCenter = _nodeCenter(fromNode);
    final toCenter = _nodeCenter(toNode);

    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;

    final node = forSource ? fromNode : toNode;
    final w = _getNodeWidth(node);
    final h = _getNodeHeight(node);
    final cx = node.position.dx + w / 2;
    final cy = node.position.dy + h / 2;

    final absDx = dx.abs();
    final absDy = dy.abs();

    AnchorSide side;
    if (absDx > absDy) {
      if (forSource) {
        side = dx > 0 ? AnchorSide.right : AnchorSide.left;
      } else {
        side = dx > 0 ? AnchorSide.left : AnchorSide.right;
      }
    } else {
      if (forSource) {
        side = dy > 0 ? AnchorSide.bottom : AnchorSide.top;
      } else {
        side = dy > 0 ? AnchorSide.top : AnchorSide.bottom;
      }
    }

    switch (side) {
      case AnchorSide.top:
        return Offset(cx, node.position.dy);
      case AnchorSide.bottom:
        return Offset(cx, node.position.dy + h);
      case AnchorSide.left:
        return Offset(node.position.dx, cy);
      case AnchorSide.right:
        return Offset(node.position.dx + w, cy);
    }
  }

  Offset _getPropertyAnchor(FDMNode node, String? propKey) {
    final w = _getNodeWidth(node);
    if (propKey == null || propKey.isEmpty) {
      return Offset(node.position.dx + w, node.position.dy + _getNodeHeight(node) / 2);
    }
    final index = node.properties.indexWhere((p) => p.key == propKey);
    if (index == -1) {
      return Offset(node.position.dx + w, node.position.dy + _getNodeHeight(node) / 2);
    }
    final y = node.position.dy + 36.0 + 18.0 + 1.0 + 6.0 + index * 28.0 + 14.0;
    return Offset(node.position.dx + w, y);
  }

  Offset _evaluateCubic(Offset p1, Offset cp1, Offset cp2, Offset p2, double t) {
    final omt = 1.0 - t;
    final omt2 = omt * omt;
    final omt3 = omt2 * omt;
    final t2 = t * t;
    final t3 = t2 * t;

    return Offset(
      omt3 * p1.dx + 3.0 * omt2 * t * cp1.dx + 3.0 * omt * t2 * cp2.dx + t3 * p2.dx,
      omt3 * p1.dy + 3.0 * omt2 * t * cp1.dy + 3.0 * omt * t2 * cp2.dy + t3 * p2.dy,
    );
  }

  String? _hitTestEdge(Offset canvasPos) {
    final state = ref.read(diagramProvider);
    for (final edge in state.edges) {
      final source = _findNode(edge.sourceNodeId);
      final target = _findNode(edge.targetNodeId);
      if (source == null || target == null) continue;

      Offset p1, p2;
      AnchorSide exitSide;

      if (edge.type == EdgeType.hierarchy) {
        p1 = _getDynamicAnchor(source, target, forSource: true);
        p2 = _getDynamicAnchor(source, target, forSource: false);
        final srcCenter = _nodeCenter(source);
        final tgtCenter = _nodeCenter(target);
        final dx = tgtCenter.dx - srcCenter.dx;
        final dy = tgtCenter.dy - srcCenter.dy;
        if (dx.abs() > dy.abs()) {
          exitSide = dx > 0 ? AnchorSide.right : AnchorSide.left;
        } else {
          exitSide = dy > 0 ? AnchorSide.bottom : AnchorSide.top;
        }
      } else {
        p1 = _getPropertyAnchor(source, edge.sourcePropertyKey);
        p2 = _getDynamicAnchor(source, target, forSource: false);
        exitSide = AnchorSide.right;
      }

      final dx = (p2.dx - p1.dx).abs();
      final dy = (p2.dy - p1.dy).abs();
      Offset cp1, cp2;

      if (exitSide == AnchorSide.top || exitSide == AnchorSide.bottom) {
        final tension = math.max(60.0, dy * 0.5);
        final dir = exitSide == AnchorSide.bottom ? 1.0 : -1.0;
        cp1 = Offset(p1.dx, p1.dy + tension * dir);
        cp2 = Offset(p2.dx, p2.dy - tension * dir);
      } else {
        final tension = math.max(60.0, dx * 0.5);
        final dir = exitSide == AnchorSide.right ? 1.0 : -1.0;
        cp1 = Offset(p1.dx + tension * dir, p1.dy);
        cp2 = Offset(p2.dx - tension * dir, p2.dy);
      }

      double minDistance = double.infinity;
      for (int step = 0; step <= 8; step++) {
        final t = step / 8.0;
        final pt = _evaluateCubic(p1, cp1, cp2, p2, t);
        final dist = (canvasPos - pt).distance;
        if (dist < minDistance) {
          minDistance = dist;
        }
      }

      if (minDistance < 15.0) {
        return edge.id;
      }
    }
    return null;
  }

  void _abortDrag() {
    if (_draggingNodeId != null || _draggingBoundaryId != null) {
      ref.read(diagramProvider.notifier).finishDragging();
    }
    _draggingNodeId = null;
    _draggingBoundaryId = null;
    _lastPointerPosition = null;
    _activePointerId = null;
    if (_isDraggingNode) {
      setState(() => _isDraggingNode = false);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    // If a drag is already active, this might be a second finger touching the screen.
    // In that case, we abort the current drag session so that multi-touch pan/zoom
    // can proceed normally without dragging any nodes.
    if (_activePointerId != null) {
      _abortDrag();
      return;
    }

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
        _activePointerId = event.pointer;
        // Disable InteractiveViewer pan while we drag a node
        setState(() => _isDraggingNode = true);
      }
      return;
    }

    final boundaryId = _hitTestBoundary(canvasPos);
    if (boundaryId != null) {
      _draggingBoundaryId = boundaryId;
      _activePointerId = event.pointer;
      ref.read(diagramProvider.notifier).selectBoundary(boundaryId);
      setState(() => _isDraggingNode = true); // block IV panning for boundaries too
      return;
    }

    final edgeId = _hitTestEdge(canvasPos);
    if (edgeId != null) {
      ref.read(diagramProvider.notifier).selectEdge(edgeId);
      return;
    }

    // Empty space — let InteractiveViewer pan
    ref.read(diagramProvider.notifier).selectNode(null);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    // Ignore events that do not match the active dragging pointer,
    // or if no drag is currently active.
    if (_activePointerId == null || event.pointer != _activePointerId) return;
    if (_lastPointerPosition == null) return;

    if (_draggingNodeId != null) {
      // CRITICAL: Convert BOTH positions to canvas-space using full matrix inversion.
      // Simply dividing by scale is WRONG — it ignores the translation component
      // of the matrix. This caused nodes to drift when zoomed in/out.
      final currentCanvas = _screenToCanvas(event.localPosition);
      final prevCanvas = _screenToCanvas(_lastPointerPosition!);
      final canvasDelta = currentCanvas - prevCanvas;

      final node = ref
          .read(diagramProvider)
          .nodes
          .firstWhere((n) => n.id == _draggingNodeId);
      ref.read(diagramProvider.notifier).updateNodePosition(
            _draggingNodeId!,
            node.position + canvasDelta,
          );
    } else if (_draggingBoundaryId != null) {
      final currentCanvas = _screenToCanvas(event.localPosition);
      final prevCanvas = _screenToCanvas(_lastPointerPosition!);
      final canvasDelta = currentCanvas - prevCanvas;

      final boundary = ref
          .read(diagramProvider)
          .boundaries
          .firstWhere((b) => b.id == _draggingBoundaryId);
      ref.read(diagramProvider.notifier).updateBoundaryRect(
            _draggingBoundaryId!,
            boundary.rect.shift(canvasDelta),
          );
    }

    _lastPointerPosition = event.localPosition;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer == _activePointerId) {
      _abortDrag();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagramProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF8FAFC);
    final gridColor =
        isDark ? const Color(0xFF5A6A80) : const Color(0xFFE2E8F0);
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
        onPointerCancel: (_) => _abortDrag(),
        behavior: HitTestBehavior.translucent,
        child: InteractiveViewer(
          transformationController: _transformationController,
          // Disable panning when we're actively dragging a node to prevent
          // the InteractiveViewer from capturing our drag gesture
          panEnabled: !_isDraggingNode,
          scaleEnabled: !_isDraggingNode,
          constrained: false,
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
