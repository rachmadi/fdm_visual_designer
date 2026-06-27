import 'dart:convert';
import 'package:flutter/foundation.dart';
// Conditional import for web download
// We can use dart:html on web and print on desktop
import 'dart:html' as html;
import '../../core/metamodel.dart';
import '../../core/state.dart';

class FdmSerializer {
  static String serialize(DiagramState state, {String title = 'FDM Diagram', String description = 'Exported from FDM Visual Designer'}) {
    final Map<String, dynamic> data = {
      'fdmVersion': '1.0',
      'diagramMode': state.isFirestoreMode ? 'firestore' : 'rtdb',
      'metadata': {
        'title': title,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      },
      'nodes': state.nodes.map((e) => e.toJson()).toList(),
      'edges': state.edges.map((e) => e.toJson()).toList(),
      'securityBoundaries': state.boundaries.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static void downloadJsonWeb(String jsonStr, String filename) {
    if (kIsWeb) {
      final bytes = utf8.encode(jsonStr);
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    }
  }

  static Map<String, dynamic>? parse(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final fdmVersion = decoded['fdmVersion'] as String?;
      if (fdmVersion == null) return null;

      final diagramMode = decoded['diagramMode'] as String? ?? 'firestore';
      final isFirestoreMode = diagramMode == 'firestore';

      final nodesJson = decoded['nodes'] as List<dynamic>? ?? [];
      final edgesJson = decoded['edges'] as List<dynamic>? ?? [];
      final boundariesJson = decoded['securityBoundaries'] as List<dynamic>? ?? [];

      final nodes = nodesJson.map((e) => FDMNode.fromJson(e as Map<String, dynamic>)).toList();
      final edges = edgesJson.map((e) => FDMEdge.fromJson(e as Map<String, dynamic>)).toList();
      final boundaries = boundariesJson.map((e) => SecurityBoundary.fromJson(e as Map<String, dynamic>)).toList();

      return {
        'nodes': nodes,
        'edges': edges,
        'boundaries': boundaries,
        'isFirestoreMode': isFirestoreMode,
      };
    } catch (e) {
      debugPrint('Error parsing FDM JSON: $e');
      return null;
    }
  }
}
