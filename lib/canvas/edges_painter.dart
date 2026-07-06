import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/metamodel.dart';

/// Enum sisi yang digunakan untuk titik koneksi dinamis
enum AnchorSide { top, bottom, left, right }

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

  /// Menghitung pusat node di canvas space
  Offset _nodeCenter(FDMNode node) {
    return Offset(
      node.position.dx + _getNodeWidth(node) / 2,
      node.position.dy + _getNodeHeight(node) / 2,
    );
  }

  /// Dynamic anchor switching: memilih sisi terbaik berdasarkan posisi relatif
  /// source dan target node. Mengembalikan titik koneksi di sisi yang dipilih.
  ///
  /// [forSource] = true → hitung anchor untuk source node
  /// [forSource] = false → hitung anchor untuk target node
  Offset _getDynamicAnchor(FDMNode fromNode, FDMNode toNode, {required bool forSource}) {
    final fromCenter = _nodeCenter(fromNode);
    final toCenter = _nodeCenter(toNode);

    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;

    // Gunakan node yang relevan
    final node = forSource ? fromNode : toNode;
    final w = _getNodeWidth(node);
    final h = _getNodeHeight(node);
    final cx = node.position.dx + w / 2;
    final cy = node.position.dy + h / 2;

    // Tentukan sisi berdasarkan arah relatif dari source ke target
    // Perbandingan |dx| vs |dy| menentukan apakah koneksi lebih horizontal atau vertikal
    final absDx = dx.abs();
    final absDy = dy.abs();

    AnchorSide side;
    if (absDx > absDy) {
      // Lebih horizontal
      if (forSource) {
        side = dx > 0 ? AnchorSide.right : AnchorSide.left;
      } else {
        side = dx > 0 ? AnchorSide.left : AnchorSide.right;
      }
    } else {
      // Lebih vertikal
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

  /// Mendapatkan anchor titik dari property tertentu pada entity node (sisi kanan)
  Offset _getPropertyAnchor(FDMNode node, String? propKey) {
    final w = _getNodeWidth(node);
    if (propKey == null || propKey.isEmpty) {
      return Offset(node.position.dx + w, node.position.dy + _getNodeHeight(node) / 2);
    }
    final index = node.properties.indexWhere((p) => p.key == propKey);
    if (index == -1) {
      return Offset(node.position.dx + w, node.position.dy + _getNodeHeight(node) / 2);
    }
    // Posisi row property: header (36) + path (18) + divider (1) + padding (6) + index * 28 + 14 (center row)
    final y = node.position.dy + 36.0 + 18.0 + 1.0 + 6.0 + index * 28.0 + 14.0;
    return Offset(node.position.dx + w, y);
  }

  /// Membuat Bézier cubic path antara dua titik
  /// Arah kurva dipengaruhi oleh sisi anchor (vertikal vs horizontal)
  Path _buildBezierPath(Offset p1, Offset p2, {AnchorSide? sourceExitSide}) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    final dx = (p2.dx - p1.dx).abs();
    final dy = (p2.dy - p1.dy).abs();

    // Kontrol poin berdasarkan apakah koneksi lebih vertikal atau horizontal
    Offset cp1, cp2;

    if (sourceExitSide == AnchorSide.top || sourceExitSide == AnchorSide.bottom) {
      // Keluar secara vertikal → kurva membentuk S vertikal
      final tension = math.max(60.0, dy * 0.5);
      final dir = sourceExitSide == AnchorSide.bottom ? 1.0 : -1.0;
      cp1 = Offset(p1.dx, p1.dy + tension * dir);
      cp2 = Offset(p2.dx, p2.dy - tension * dir);
    } else if (sourceExitSide == AnchorSide.left || sourceExitSide == AnchorSide.right) {
      // Keluar secara horizontal → kurva membentuk S horizontal
      final tension = math.max(60.0, dx * 0.5);
      final dir = sourceExitSide == AnchorSide.right ? 1.0 : -1.0;
      cp1 = Offset(p1.dx + tension * dir, p1.dy);
      cp2 = Offset(p2.dx - tension * dir, p2.dy);
    } else {
      // Fallback: kurva sederhana
      final tension = math.max(60.0, (dx + dy) * 0.35);
      cp1 = Offset(p1.dx, p1.dy + tension);
      cp2 = Offset(p2.dx, p2.dy - tension);
    }

    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final hierarchyPaint = Paint()
      ..color = const Color(0xFF2E75B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final referencingPaint = Paint()
      ..color = const Color(0xFFE07B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final denormalizationPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final selectedPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (final edge in edges) {
      final source = _findNode(edge.sourceNodeId);
      final target = _findNode(edge.targetNodeId);
      if (source == null || target == null) continue;

      final isSelected = selectedEdgeId == edge.id;

      if (edge.type == EdgeType.hierarchy) {
        // Dynamic anchor: pilih sisi terbaik berdasarkan posisi relatif
        final p1 = _getDynamicAnchor(source, target, forSource: true);
        final p2 = _getDynamicAnchor(source, target, forSource: false);

        final currentPaint = isSelected ? selectedPaint : hierarchyPaint;

        // Tentukan sisi keluaran source untuk arah Bézier
        final srcCenter = _nodeCenter(source);
        final tgtCenter = _nodeCenter(target);
        final dx = tgtCenter.dx - srcCenter.dx;
        final dy = tgtCenter.dy - srcCenter.dy;
        AnchorSide exitSide;
        if (dx.abs() > dy.abs()) {
          exitSide = dx > 0 ? AnchorSide.right : AnchorSide.left;
        } else {
          exitSide = dy > 0 ? AnchorSide.bottom : AnchorSide.top;
        }

        final bezierPath = _buildBezierPath(p1, p2, sourceExitSide: exitSide);
        canvas.drawPath(bezierPath, currentPaint);

        // Gambar arrowhead di ujung target
        _drawArrowhead(canvas, p2, p1, currentPaint);

        // Titik koneksi kecil di ujung source
        _drawAnchorDot(canvas, p1, currentPaint.color);

      } else if (edge.type == EdgeType.referencing) {
        // Referencing: dari property handle di sisi kanan source → anchor dinamis target
        final p1 = _getPropertyAnchor(source, edge.sourcePropertyKey);

        // Target anchor: selalu dari sisi kiri jika source lebih ke kiri, atau dinamis
        final p2 = _getDynamicAnchor(source, target, forSource: false);

        final currentPaint = isSelected ? selectedPaint : referencingPaint;

        // Bézier horizontal keluar kanan
        final bezierPath = _buildBezierPath(p1, p2, sourceExitSide: AnchorSide.right);
        _drawDashedPath(canvas, bezierPath, currentPaint);
        _drawArrowhead(canvas, p2, p1, currentPaint);

        // Jika referencing 1:N (asterisk di source)
        final prop = source.properties.firstWhere(
          (p) => p.key == edge.sourcePropertyKey,
          orElse: () => PropertyNode(key: '', dataType: DataType.nullValue),
        );
        if (edge.isOneToMany || prop.dataType == DataType.array) {
          _drawAsterisk(canvas, p1);
        }

      } else if (edge.type == EdgeType.denormalization) {
        // Denormalization: dari property handle → dynamic anchor
        final p1 = _getPropertyAnchor(source, edge.sourcePropertyKey);
        final p2 = _getDynamicAnchor(source, target, forSource: false);

        final currentPaint = isSelected ? selectedPaint : denormalizationPaint;

        // Garis tebal solid
        final bezierPath = _buildBezierPath(p1, p2, sourceExitSide: AnchorSide.right);
        canvas.drawPath(bezierPath, currentPaint);
        _drawDoubleArrowhead(canvas, p2, p1, currentPaint);

        // Label inline di tengah edge
        if (edge.label != null && edge.label!.isNotEmpty) {
          _drawEdgeLabel(canvas, p1, p2, edge.label!);
        }
      }
    }
  }

  /// Menggambar garis putus-putus (dashed) mengikuti path Bézier
  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {double dashWidth = 8, double dashSpace = 5}) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final segLen = draw ? dashWidth : dashSpace;
        if (draw) {
          final extracted = metric.extractPath(
            distance,
            math.min(distance + segLen, metric.length),
          );
          canvas.drawPath(extracted, paint);
        }
        distance += segLen;
        draw = !draw;
      }
    }
  }

  void _drawArrowhead(Canvas canvas, Offset tip, Offset from, Paint paint) {
    final angle = (tip - from).direction;
    const double arrowSize = 10;
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle - math.pi / 6),
      tip.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle + math.pi / 6),
      tip.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
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

    final secondTip = tip - direction * 9;
    _drawArrowhead(canvas, secondTip, from, paint);
  }

  /// Titik bulat kecil di ujung awal edge
  void _drawAnchorDot(Canvas canvas, Offset center, Color color) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);
  }

  void _drawAsterisk(Canvas canvas, Offset handlePos) {
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
    textPainter.paint(
      canvas,
      mid - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant EdgesPainter oldDelegate) {
    return true; // Repaint saat node digeser atau dimodifikasi
  }
}
