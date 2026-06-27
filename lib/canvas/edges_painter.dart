import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/metamodel.dart';

class EdgesPainter extends CustomPainter {
  final List<FDMNode> nodes;
  final List<FDMEdge> edges;
  final String? selectedEdgeId;

  EdgesPainter({
    required this.nodes,
    required this.edges,
    this.selectedEdgeId,
  });

  FDMNode? _findNode(String id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
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

  Offset _getInputHandle(FDMNode node) {
    if (node.type == NodeType.structural) {
      return Offset(node.position.dx + 100, node.position.dy);
    } else {
      return Offset(node.position.dx + 110, node.position.dy);
    }
  }

  Offset _getOutputHandle(FDMNode node) {
    if (node.type == NodeType.structural) {
      return Offset(node.position.dx + 100, node.position.dy + 80);
    } else {
      return Offset(node.position.dx + 110, node.position.dy + _getNodeHeight(node));
    }
  }

  Offset _getPropertyHandle(FDMNode node, String? propKey) {
    if (propKey == null || propKey.isEmpty) {
      return Offset(node.position.dx + 220, node.position.dy + _getNodeHeight(node) / 2);
    }
    final index = node.properties.indexWhere((p) => p.key == propKey);
    if (index == -1) {
      return Offset(node.position.dx + 220, node.position.dy + _getNodeHeight(node) / 2);
    }
    final y = node.position.dy + 36.0 + 18.0 + 1.0 + 6.0 + index * 28.0 + 14.0;
    return Offset(node.position.dx + 220, y);
  }

  Offset _getTargetLeftCenter(FDMNode node) {
    return Offset(node.position.dx, node.position.dy + _getNodeHeight(node) / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final hierarchyPaint = Paint()
      ..color = const Color(0xFF2E75B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final referencingPaint = Paint()
      ..color = const Color(0xFFE07B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final denormalizationPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final selectedPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    for (final edge in edges) {
      final source = _findNode(edge.sourceNodeId);
      final target = _findNode(edge.targetNodeId);
      if (source == null || target == null) continue;

      final isSelected = selectedEdgeId == edge.id;

      if (edge.type == EdgeType.hierarchy) {
        // Vertical hierarchy
        final p1 = _getOutputHandle(source);
        final p2 = _getInputHandle(target);
        
        final currentPaint = isSelected ? selectedPaint : hierarchyPaint;
        
        // Draw orthagonal line
        final path = Path();
        path.moveTo(p1.dx, p1.dy);
        final midY = p1.dy + (p2.dy - p1.dy) / 2;
        path.lineTo(p1.dx, midY);
        path.lineTo(p2.dx, midY);
        path.lineTo(p2.dx, p2.dy);
        
        canvas.drawPath(path, currentPaint);
      } else if (edge.type == EdgeType.referencing) {
        // Horizontal pointer
        final p1 = _getPropertyHandle(source, edge.sourcePropertyKey);
        final p2 = _getTargetLeftCenter(target);
        
        final currentPaint = isSelected ? selectedPaint : referencingPaint;
        
        _drawDashedLine(canvas, p1, p2, currentPaint);
        _drawArrowhead(canvas, p2, p1, currentPaint);

        // If referencing is 1:N (asterisk at source)
        final prop = source.properties.firstWhere((p) => p.key == edge.sourcePropertyKey, orElse: () => PropertyNode(key: '', dataType: DataType.nullValue));
        if (edge.isOneToMany || prop.dataType == DataType.array) {
          _drawAsterisk(canvas, p1);
        }
      } else if (edge.type == EdgeType.denormalization) {
        // Duplication link (thick, double arrowheads)
        final p1 = _getPropertyHandle(source, edge.sourcePropertyKey);
        final p2 = _getTargetLeftCenter(target);
        
        final currentPaint = isSelected ? selectedPaint : denormalizationPaint;
        
        canvas.drawLine(p1, p2, currentPaint);
        _drawDoubleArrowhead(canvas, p2, p1, currentPaint);
        
        // Draw label inline
        if (edge.label != null && edge.label!.isNotEmpty) {
          _drawEdgeLabel(canvas, p1, p2, edge.label!);
        }
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dashWidth = 6, double dashSpace = 4}) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    final int count = (distance / (dashWidth + dashSpace)).floor();
    if (count <= 0) return;

    final double xStep = dx / distance;
    final double yStep = dy / distance;
    
    for (int i = 0; i < count; i++) {
      final start = p1 + Offset(xStep * i * (dashWidth + dashSpace), yStep * i * (dashWidth + dashSpace));
      final end = start + Offset(xStep * dashWidth, yStep * dashWidth);
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawArrowhead(Canvas canvas, Offset tip, Offset from, Paint paint) {
    final angle = (tip - from).direction;
    const double arrowSize = 10;
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(tip.dx - arrowSize * math.cos(angle - math.pi / 6), tip.dy - arrowSize * math.sin(angle - math.pi / 6));
    path.lineTo(tip.dx - arrowSize * math.cos(angle + math.pi / 6), tip.dy - arrowSize * math.sin(angle + math.pi / 6));
    path.close();
    
    final fillPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  void _drawDoubleArrowhead(Canvas canvas, Offset tip, Offset from, Paint paint) {
    final angle = (tip - from).direction;
    final direction = Offset(math.cos(angle), math.sin(angle));
    
    _drawArrowhead(canvas, tip, from, paint);
    
    final secondTip = tip - direction * 8;
    _drawArrowhead(canvas, secondTip, from, paint);
  }

  void _drawAsterisk(Canvas canvas, Offset handlePos) {
    // Draw small asterisk (*) at the base of arrow
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '*',
        style: TextStyle(
          color: Color(0xFFE07B00),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, handlePos + const Offset(4, -14));
  }

  void _drawEdgeLabel(Canvas canvas, Offset p1, Offset p2, String label) {
    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF991B1B),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, mid - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant EdgesPainter oldDelegate) {
    return true; // Repaint whenever nodes are dragged or modified
  }
}
