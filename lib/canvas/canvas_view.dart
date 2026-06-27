import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
  final double _canvasWidth = 3000.0;
  final double _canvasHeight = 3000.0;

  // Manual pan/zoom state
  Offset _canvasOffset = Offset.zero;
  double _scale = 1.0;
  
  // Drag tracking
  String? _draggingNodeId;
  String? _draggingBoundaryId;
  bool _isPanning = false;
  Offset _lastPointerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Center the viewport inside the 3000x3000 canvas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _canvasOffset = Offset(
          -(_canvasWidth - size.width) / 2,
          -(_canvasHeight - size.height) / 2,
        );
      });
    });
  }

  /// Convert screen position to canvas coordinates
  Offset _screenToCanvas(Offset screenPos) {
    return (screenPos - _canvasOffset) / _scale;
  }

  /// Hit test: find which node is at the given canvas position
  String? _hitTestNode(Offset canvasPos) {
    final state = ref.read(diagramProvider);
    // Iterate in reverse so topmost (last drawn) node is hit first
    for (int i = state.nodes.length - 1; i >= 0; i--) {
      final node = state.nodes[i];
      final double w = node.type == NodeType.structural ? 200 : 220;
      final double h = node.type == NodeType.structural ? 80 : 200; // approximate
      final rect = Rect.fromLTWH(node.position.dx, node.position.dy, w, h);
      if (rect.contains(canvasPos)) {
        return node.id;
      }
    }
    return null;
  }

  /// Hit test: find which boundary is at the given canvas position
  String? _hitTestBoundary(Offset canvasPos) {
    final state = ref.read(diagramProvider);
    for (int i = state.boundaries.length - 1; i >= 0; i--) {
      final b = state.boundaries[i];
      // Check the label area (top-left corner of boundary)
      final labelRect = Rect.fromLTWH(b.rect.left + 10, b.rect.top - 12, 80, 24);
      if (labelRect.contains(canvasPos)) {
        return b.id;
      }
    }
    return null;
  }

  void _onPointerDown(PointerDownEvent event) {
    final canvasPos = _screenToCanvas(event.localPosition);
    _lastPointerPosition = event.localPosition;
    
    // Try to hit a node first
    final nodeId = _hitTestNode(canvasPos);
    if (nodeId != null) {
      _draggingNodeId = nodeId;
      final isConnecting = ref.read(diagramProvider).isConnecting;
      if (isConnecting) {
        ref.read(diagramProvider.notifier).completeConnection(nodeId);
      } else {
        ref.read(diagramProvider.notifier).selectNode(nodeId);
      }
      return;
    }

    // Try to hit a boundary
    final boundaryId = _hitTestBoundary(canvasPos);
    if (boundaryId != null) {
      _draggingBoundaryId = boundaryId;
      ref.read(diagramProvider.notifier).selectBoundary(boundaryId);
      return;
    }

    // Empty space: start canvas panning
    _isPanning = true;
    ref.read(diagramProvider.notifier).selectNode(null);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final delta = event.localPosition - _lastPointerPosition;
    _lastPointerPosition = event.localPosition;

    if (_draggingNodeId != null) {
      // Move node (delta adjusted for zoom scale)
      final scaledDelta = delta / _scale;
      final node = ref.read(diagramProvider).nodes.firstWhere((n) => n.id == _draggingNodeId);
      ref.read(diagramProvider.notifier).updateNodePosition(
        _draggingNodeId!, 
        node.position + scaledDelta,
      );
    } else if (_draggingBoundaryId != null) {
      // Move boundary
      final scaledDelta = delta / _scale;
      final boundary = ref.read(diagramProvider).boundaries.firstWhere((b) => b.id == _draggingBoundaryId);
      ref.read(diagramProvider.notifier).updateBoundaryRect(
        _draggingBoundaryId!,
        boundary.rect.shift(scaledDelta),
      );
    } else if (_isPanning) {
      // Pan the canvas
      setState(() {
        _canvasOffset += delta;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_draggingNodeId != null) {
      ref.read(diagramProvider.notifier).finishDragging();
    }
    if (_draggingBoundaryId != null) {
      ref.read(diagramProvider.notifier).finishDragging();
    }
    _draggingNodeId = null;
    _draggingBoundaryId = null;
    _isPanning = false;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Mouse wheel zoom
      setState(() {
        final oldScale = _scale;
        if (event.scrollDelta.dy < 0) {
          _scale = (_scale * 1.1).clamp(0.1, 3.0);
        } else {
          _scale = (_scale / 1.1).clamp(0.1, 3.0);
        }
        // Zoom toward pointer position
        final pointerPos = event.localPosition;
        _canvasOffset = pointerPos - (pointerPos - _canvasOffset) * (_scale / oldScale);
      });
    }
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
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerSignal: _onPointerSignal,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_canvasOffset.dx, _canvasOffset.dy)
                    ..scale(_scale),
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
          ],
        ),
      ),
    );
  }
}
