import 'dart:convert';
import 'dart:ui';
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
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map) return null;
      final decodedMap = Map<String, dynamic>.from(decoded);

      // 1. Check if it is a standard FDM Diagram Schema
      final fdmVersion = decodedMap['fdmVersion'] as String?;
      if (fdmVersion != null) {
        final diagramMode = decodedMap['diagramMode'] as String? ?? 'firestore';
        final isFirestoreMode = diagramMode == 'firestore';

        final nodesJson = decodedMap['nodes'] as List<dynamic>? ?? [];
        final edgesJson = decodedMap['edges'] as List<dynamic>? ?? [];
        final boundariesJson = decodedMap['securityBoundaries'] as List<dynamic>? ?? [];

        final nodes = nodesJson.map((e) => FDMNode.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        final edges = edgesJson.map((e) => FDMEdge.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        final boundaries = boundariesJson.map((e) => SecurityBoundary.fromJson(Map<String, dynamic>.from(e as Map))).toList();

        return {
          'nodes': nodes,
          'edges': edges,
          'boundaries': boundaries,
          'isFirestoreMode': isFirestoreMode,
        };
      }

      // 2. Otherwise, treat it as a Raw Database JSON and auto-generate schema!
      final List<FDMNode> nodes = [];
      final List<FDMEdge> edges = [];
      int index = 0;

      for (final key in decodedMap.keys) {
        final val = decodedMap[key];
        final nodeX = 1200.0 + (index * 380.0);
        final nodeY = 1200.0;

        if (val is Map) {
          final valMap = Map<String, dynamic>.from(val);
          // Create collection structural node
          final colId = 'node_col_$key';
          nodes.add(FDMNode(
            id: colId,
            type: NodeType.structural,
            name: key,
            path: '/$key',
            position: Offset(nodeX, nodeY),
            queryVector: QueryVector(),
          ));

          // Look at first document child to extract schema properties
          if (valMap.isNotEmpty) {
            final firstDocKey = valMap.keys.first;
            final firstDocVal = valMap[firstDocKey];

            if (firstDocVal is Map) {
              final firstDocMap = Map<String, dynamic>.from(firstDocVal);
              final List<PropertyNode> properties = [];
              
              for (final propKey in firstDocMap.keys) {
                final propVal = firstDocMap[propKey];
                DataType dt = DataType.string;
                if (propVal is bool) {
                  dt = DataType.boolean;
                } else if (propVal is num) {
                  dt = DataType.number;
                } else if (propVal is Map) {
                  dt = DataType.map;
                } else if (propVal is List) {
                  dt = DataType.array;
                }

                properties.add(PropertyNode(
                  key: propKey,
                  dataType: dt,
                ));
              }

              // Create document entity node
              final docId = 'node_doc_$key';
              // Make name singular
              final docName = key.endsWith('s') ? key.substring(0, key.length - 1) : '${key}_doc';
              
              nodes.add(FDMNode(
                id: docId,
                type: NodeType.entity,
                name: docName,
                path: '/$key/\$id',
                properties: properties,
                position: Offset(nodeX, nodeY + 240.0),
                queryVector: QueryVector(),
              ));

              // Create hierarchy edge
              edges.add(FDMEdge(
                id: 'edge_hier_$key',
                type: EdgeType.hierarchy,
                sourceNodeId: colId,
                targetNodeId: docId,
              ));
            }
          }
        }
        index++;
      }

      if (nodes.isNotEmpty) {
        return {
          'nodes': nodes,
          'edges': edges,
          'boundaries': <SecurityBoundary>[],
          'isFirestoreMode': true,
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing FDM JSON: $e');
      return null;
    }
  }
}
