import 'dart:ui';
import '../core/metamodel.dart';

List<ValidationResult> validateDiagram(
  List<FDMNode> nodes,
  List<FDMEdge> edges,
  List<SecurityBoundary> boundaries,
  bool isFirestoreMode,
) {
  final List<ValidationResult> results = [];

  FDMNode? findNode(String id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  // Check Rule 1: Structural Node alternation (Firestore mode only)
  if (isFirestoreMode) {
    for (final edge in edges) {
      if (edge.type == EdgeType.hierarchy) {
        final source = findNode(edge.sourceNodeId);
        final target = findNode(edge.targetNodeId);
        
        if (source != null && target != null) {
          if (source.type == NodeType.structural && target.type != NodeType.entity) {
            results.add(ValidationResult(
              ruleId: 'R1',
              severity: 'error',
              targetNodeId: source.id,
              message: 'Structural Node (${source.name}) must only connect to Entity Nodes (Strict Alternation).',
            ));
          }
          if (source.type == NodeType.entity && target.type != NodeType.structural) {
            results.add(ValidationResult(
              ruleId: 'R1',
              severity: 'error',
              targetNodeId: source.id,
              message: 'Entity Node (${source.name}) must only connect to Structural Nodes (Strict Alternation).',
            ));
          }
        }
      }
    }
  }

  // Check Rule 2: Referencing target must exist and be an Entity Node
  for (final edge in edges) {
    if (edge.type == EdgeType.referencing) {
      final target = findNode(edge.targetNodeId);
      if (target == null) {
        results.add(ValidationResult(
          ruleId: 'R2',
          severity: 'error',
          targetNodeId: edge.sourceNodeId,
          message: 'Referencing edge targets a node that does not exist.',
        ));
      } else if (target.type != NodeType.entity) {
        results.add(ValidationResult(
          ruleId: 'R2',
          severity: 'error',
          targetNodeId: edge.sourceNodeId,
          message: 'Referencing edge must target an Entity Node.',
        ));
      }
    }
  }

  // Check Rule 3: Denormalized Property source check
  for (final edge in edges) {
    if (edge.type == EdgeType.denormalization) {
      final source = findNode(edge.sourceNodeId);
      if (source == null) {
        results.add(ValidationResult(
          ruleId: 'R3',
          severity: 'error',
          targetNodeId: edge.targetNodeId,
          message: 'Denormalization source node does not exist.',
        ));
      } else if (edge.sourcePropertyKey == null || 
                 !source.properties.any((p) => p.key == edge.sourcePropertyKey)) {
        results.add(ValidationResult(
          ruleId: 'R3',
          severity: 'error',
          targetNodeId: edge.sourceNodeId,
          message: 'Denormalized property does not have a valid source property key.',
        ));
      }
    }
  }

  // Check Rule 4: Dynamic path must use $ or {}
  for (final node in nodes) {
    if (node.isDynamic) {
      final segments = node.path.split('/');
      final lastSegment = segments.isNotEmpty ? segments.last : '';
      if (!lastSegment.startsWith(r'$') && !(lastSegment.startsWith('{') && lastSegment.endsWith('}'))) {
        results.add(ValidationResult(
          ruleId: 'R4',
          severity: 'error',
          targetNodeId: node.id,
          message: 'Dynamic path segment must start with \$ or be enclosed in {}.',
        ));
      }
    }
  }

  // Check Rule 5: Query Vector fields must exist in properties
  for (final node in nodes) {
    if (node.type == NodeType.entity) {
      final qv = node.queryVector;
      for (final f in qv.filterFields) {
        if (!node.properties.any((p) => p.key == f)) {
          results.add(ValidationResult(
            ruleId: 'R5',
            severity: 'error',
            targetNodeId: node.id,
            message: 'Query Vector references field "$f" which is not defined in properties.',
          ));
        }
      }
      for (final s in qv.sortFields) {
        if (!node.properties.any((p) => p.key == s.field)) {
          results.add(ValidationResult(
            ruleId: 'R5',
            severity: 'error',
            targetNodeId: node.id,
            message: 'Query Vector references sort field "${s.field}" which is not defined in properties.',
          ));
        }
      }
    }
  }

  // Check Rule 6: Security Boundary partial overlap
  for (final boundary in boundaries) {
    for (final node in nodes) {
      if (node.type == NodeType.entity) {
        // Assume Entity Node dimensions are 220x180 (approximated for validation)
        final nodeRect = Rect.fromLTWH(node.position.dx, node.position.dy, 220, 180);
        final overlaps = nodeRect.overlaps(boundary.rect);
        
        // Check if fully contained
        final isContained = boundary.rect.contains(nodeRect.topLeft) &&
                            boundary.rect.contains(nodeRect.topRight) &&
                            boundary.rect.contains(nodeRect.bottomLeft) &&
                            boundary.rect.contains(nodeRect.bottomRight);
                            
        if (overlaps && !isContained) {
          results.add(ValidationResult(
            ruleId: 'R6',
            severity: 'error',
            targetNodeId: node.id,
            message: 'Security Boundary partially overlaps Entity Node "${node.name}". Must fully enclose or exclude it.',
          ));
        }
      }
    }
  }

  // Check Rule 7: Physical limit - Unbounded Array/Map warning
  for (final node in nodes) {
    for (final prop in node.properties) {
      if (prop.isUnbounded && (prop.dataType == DataType.array || prop.dataType == DataType.map)) {
        results.add(ValidationResult(
          ruleId: 'R7',
          severity: 'warning',
          targetNodeId: node.id,
          message: 'Property "${prop.key}" is unbounded. Watch out for the 1MB document size limit.',
        ));
      }
    }
  }

  // Check Rule 8: Physical limit - High Frequency Write warning
  for (final node in nodes) {
    if (node.isHighFrequency) {
      results.add(ValidationResult(
        ruleId: 'R8',
        severity: 'warning',
        targetNodeId: node.id,
        message: 'Entity "${node.name}" has high write frequency. Watch out for the 1 write/second limit per document.',
      ));
    }
  }

  return results;
}
