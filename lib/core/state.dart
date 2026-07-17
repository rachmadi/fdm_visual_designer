import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'metamodel.dart';
import '../engine/validator.dart';

class DiagramState {
  final List<FDMNode> nodes;
  final List<FDMEdge> edges;
  final List<SecurityBoundary> boundaries;
  final String? selectedNodeId;
  final String? selectedBoundaryId;
  final String? selectedEdgeId;
  final bool isFirestoreMode;
  final List<ValidationResult> validationResults;
  final bool showValidationReport;
  final String? pendingSourceNodeId;
  final String? pendingSourcePropertyKey;
  final EdgeType connectionMode;
  final bool isConnecting;

  // Stacks for undo/redo
  final List<Map<String, dynamic>> undoStack;
  final List<Map<String, dynamic>> redoStack;

  // REQ-024: Boundary drawing mode
  final bool isBoundaryDrawingMode;
  final Offset? boundaryDraftStart;
  final Offset? boundaryDraftEnd;

  DiagramState({
    this.nodes = const [],
    this.edges = const [],
    this.boundaries = const [],
    this.selectedNodeId,
    this.selectedBoundaryId,
    this.selectedEdgeId,
    this.isFirestoreMode = true,
    this.validationResults = const [],
    this.showValidationReport = true,
    this.pendingSourceNodeId,
    this.pendingSourcePropertyKey,
    this.connectionMode = EdgeType.referencing,
    this.isConnecting = false,
    this.undoStack = const [],
    this.redoStack = const [],
    this.isBoundaryDrawingMode = false,
    this.boundaryDraftStart,
    this.boundaryDraftEnd,
  });

  DiagramState copyWith({
    List<FDMNode>? nodes,
    List<FDMEdge>? edges,
    List<SecurityBoundary>? boundaries,
    String? selectedNodeId = _undefined,
    String? selectedBoundaryId = _undefined,
    String? selectedEdgeId = _undefined,
    bool? isFirestoreMode,
    List<ValidationResult>? validationResults,
    bool? showValidationReport,
    String? pendingSourceNodeId = _undefined,
    String? pendingSourcePropertyKey = _undefined,
    EdgeType? connectionMode,
    bool? isConnecting,
    List<Map<String, dynamic>>? undoStack,
    List<Map<String, dynamic>>? redoStack,
    bool? isBoundaryDrawingMode,
    Object? boundaryDraftStart = _undefinedSentinel,
    Object? boundaryDraftEnd = _undefinedSentinel,
  }) {
    return DiagramState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      boundaries: boundaries ?? this.boundaries,
      selectedNodeId: selectedNodeId == _undefined ? this.selectedNodeId : selectedNodeId,
      selectedBoundaryId: selectedBoundaryId == _undefined ? this.selectedBoundaryId : selectedBoundaryId,
      selectedEdgeId: selectedEdgeId == _undefined ? this.selectedEdgeId : selectedEdgeId,
      isFirestoreMode: isFirestoreMode ?? this.isFirestoreMode,
      validationResults: validationResults ?? this.validationResults,
      showValidationReport: showValidationReport ?? this.showValidationReport,
      pendingSourceNodeId: pendingSourceNodeId == _undefined ? this.pendingSourceNodeId : pendingSourceNodeId,
      pendingSourcePropertyKey: pendingSourcePropertyKey == _undefined ? this.pendingSourcePropertyKey : pendingSourcePropertyKey,
      connectionMode: connectionMode ?? this.connectionMode,
      isConnecting: isConnecting ?? this.isConnecting,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      isBoundaryDrawingMode: isBoundaryDrawingMode ?? this.isBoundaryDrawingMode,
      boundaryDraftStart: identical(boundaryDraftStart, _undefinedSentinel) ? this.boundaryDraftStart : boundaryDraftStart as Offset?,
      boundaryDraftEnd: identical(boundaryDraftEnd, _undefinedSentinel) ? this.boundaryDraftEnd : boundaryDraftEnd as Offset?,
    );
  }

  static const String _undefined = '__undefined__';
  static const Object _undefinedSentinel = Object();

  Map<String, dynamic> toSnapshot() {
    return {
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
      'boundaries': boundaries.map((e) => e.toJson()).toList(),
      'isFirestoreMode': isFirestoreMode,
    };
  }
}

class DiagramNotifier extends Notifier<DiagramState> {
  @override
  DiagramState build() {
    return DiagramState();
  }

  void _saveToUndoStack() {
    final snapshot = state.toSnapshot();
    final newUndo = List<Map<String, dynamic>>.from(state.undoStack)..add(snapshot);
    state = state.copyWith(undoStack: newUndo, redoStack: []);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    
    final previousUndo = List<Map<String, dynamic>>.from(state.undoStack);
    final currentSnapshot = state.toSnapshot();
    final lastSnapshot = previousUndo.removeLast();
    
    final newRedo = List<Map<String, dynamic>>.from(state.redoStack)..add(currentSnapshot);
    
    state = _restoreFromSnapshot(lastSnapshot).copyWith(
      undoStack: previousUndo,
      redoStack: newRedo,
    );
    _runValidation();
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    
    final previousRedo = List<Map<String, dynamic>>.from(state.redoStack);
    final currentSnapshot = state.toSnapshot();
    final nextSnapshot = previousRedo.removeLast();
    
    final newUndo = List<Map<String, dynamic>>.from(state.undoStack)..add(currentSnapshot);
    
    state = _restoreFromSnapshot(nextSnapshot).copyWith(
      undoStack: newUndo,
      redoStack: previousRedo,
    );
    _runValidation();
  }

  DiagramState _restoreFromSnapshot(Map<String, dynamic> snapshot) {
    final nodesJson = snapshot['nodes'] as List<dynamic>;
    final edgesJson = snapshot['edges'] as List<dynamic>;
    final boundariesJson = snapshot['boundaries'] as List<dynamic>;
    final isFirestore = snapshot['isFirestoreMode'] as bool;

    final nodes = nodesJson.map((e) => FDMNode.fromJson(e as Map<String, dynamic>)).toList();
    final edges = edgesJson.map((e) => FDMEdge.fromJson(e as Map<String, dynamic>)).toList();
    final boundaries = boundariesJson.map((e) => SecurityBoundary.fromJson(e as Map<String, dynamic>)).toList();

    return DiagramState(
      nodes: nodes,
      edges: edges,
      boundaries: boundaries,
      isFirestoreMode: isFirestore,
      selectedNodeId: null,
      selectedBoundaryId: null,
      selectedEdgeId: null,
    );
  }

  void addNode(FDMNode node) {
    _saveToUndoStack();
    final newNodes = List<FDMNode>.from(state.nodes)..add(node);
    state = state.copyWith(nodes: newNodes, selectedNodeId: node.id, selectedBoundaryId: null, selectedEdgeId: null);
    _runValidation();
  }

  void deleteNode(String id) {
    _saveToUndoStack();
    final newNodes = state.nodes.where((n) => n.id != id).toList();
    // also delete edges connected to this node
    final newEdges = state.edges.where((e) => e.sourceNodeId != id && e.targetNodeId != id).toList();
    // also remove from boundaries
    final newBoundaries = state.boundaries.map((b) {
      final enclosed = b.enclosedNodeIds.where((nodeId) => nodeId != id).toList();
      return b.copyWith(enclosedNodeIds: enclosed);
    }).toList();

    state = state.copyWith(
      nodes: newNodes,
      edges: newEdges,
      boundaries: newBoundaries,
      selectedNodeId: state.selectedNodeId == id ? null : state.selectedNodeId,
    );
    _runValidation();
  }

  /// REQ-026: Recomputes enclosedNodeIds for every boundary based on current node positions.
  List<SecurityBoundary> _recomputeAllBoundaryEnclosures(List<FDMNode> nodes, List<SecurityBoundary> boundaries) {
    return boundaries.map((b) {
      final enclosed = <String>[];
      for (final node in nodes) {
        final nodeCenter = Offset(
          node.position.dx + (node.type == NodeType.structural ? 100.0 : 110.0),
          node.position.dy + (node.type == NodeType.structural ? 40.0 : 60.0),
        );
        if (b.rect.contains(nodeCenter)) {
          enclosed.add(node.id);
        }
      }
      return b.copyWith(enclosedNodeIds: enclosed);
    }).toList();
  }

  void updateNodePosition(String id, Offset newPos) {
    final newNodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(position: newPos);
      }
      return n;
    }).toList();
    // REQ-026: Recompute enclosures whenever a node moves
    final newBoundaries = _recomputeAllBoundaryEnclosures(newNodes, state.boundaries);
    state = state.copyWith(nodes: newNodes, boundaries: newBoundaries);
  }

  void finishDragging() {
    // REQ-026: Ensure enclosures are up-to-date after drag ends, then save undo
    final newBoundaries = _recomputeAllBoundaryEnclosures(state.nodes, state.boundaries);
    state = state.copyWith(boundaries: newBoundaries);
    _saveToUndoStack();
  }

  void updateNodeNameAndPath(String id, String name, String path, bool isDynamic, bool isHighFrequency) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(
          name: name,
          path: path,
          isDynamic: isDynamic,
          isHighFrequency: isHighFrequency,
        );
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
    _runValidation();
  }

  void addProperty(String nodeId, PropertyNode prop) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        final newProps = List<PropertyNode>.from(n.properties)..add(prop);
        return n.copyWith(properties: newProps);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
    _runValidation();
  }

  void deleteProperty(String nodeId, String propertyKey) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        final newProps = n.properties.where((p) => p.key != propertyKey).toList();
        return n.copyWith(properties: newProps);
      }
      return n;
    }).toList();
    
    // Also delete edges connected to this property
    final newEdges = state.edges.where((e) {
      return !(e.sourceNodeId == nodeId && e.sourcePropertyKey == propertyKey);
    }).toList();

    state = state.copyWith(nodes: newNodes, edges: newEdges);
    _runValidation();
  }

  void updateProperty(String nodeId, String originalKey, PropertyNode updatedProp) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        final newProps = n.properties.map((p) {
          if (p.key == originalKey) {
            return updatedProp;
          }
          return p;
        }).toList();
        return n.copyWith(properties: newProps);
      }
      return n;
    }).toList();

    // If property key changed, update edges
    List<FDMEdge> newEdges = state.edges;
    if (originalKey != updatedProp.key) {
      newEdges = state.edges.map((e) {
        if (e.sourceNodeId == nodeId && e.sourcePropertyKey == originalKey) {
          return e.copyWith(sourcePropertyKey: updatedProp.key);
        }
        return e;
      }).toList();
    }

    state = state.copyWith(nodes: newNodes, edges: newEdges);
    _runValidation();
  }

  void reorderProperties(String nodeId, int oldIndex, int newIndex) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        final props = List<PropertyNode>.from(n.properties);
        var targetIndex = newIndex;
        if (oldIndex < targetIndex) {
          targetIndex -= 1;
        }
        final item = props.removeAt(oldIndex);
        props.insert(targetIndex, item);
        return n.copyWith(properties: props);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
    _runValidation();
  }

  void insertPropertyAt(String nodeId, int index, PropertyNode prop) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        final props = List<PropertyNode>.from(n.properties);
        if (index >= 0 && index <= props.length) {
          props.insert(index, prop);
        } else {
          props.add(prop);
        }
        return n.copyWith(properties: props);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
    _runValidation();
  }

  void addEdge(FDMEdge edge) {
    _saveToUndoStack();
    final index = state.edges.indexWhere((e) =>
        e.sourceNodeId == edge.sourceNodeId &&
        e.targetNodeId == edge.targetNodeId &&
        e.type == edge.type &&
        e.sourcePropertyKey == edge.sourcePropertyKey);

    List<FDMEdge> newEdges;
    if (index != -1) {
      newEdges = List<FDMEdge>.from(state.edges);
      newEdges[index] = newEdges[index].copyWith(
        isOneToMany: edge.isOneToMany,
        label: edge.label,
      );
    } else {
      newEdges = List<FDMEdge>.from(state.edges)..add(edge);
    }
    state = state.copyWith(edges: newEdges);
    _runValidation();
  }

  void updateEdgeProperties(String edgeId, {bool? isOneToMany, String? label}) {
    _saveToUndoStack();
    final newEdges = state.edges.map((e) {
      if (e.id == edgeId) {
        return e.copyWith(
          isOneToMany: isOneToMany ?? e.isOneToMany,
          label: label ?? e.label,
        );
      }
      return e;
    }).toList();
    state = state.copyWith(edges: newEdges);
    _runValidation();
  }

  void setConnectionMode(EdgeType mode) {
    state = state.copyWith(connectionMode: mode);
  }

  void startConnection(String sourceId, String? propKey) {
    state = state.copyWith(
      pendingSourceNodeId: sourceId,
      pendingSourcePropertyKey: propKey,
      isConnecting: true,
    );
  }

  void cancelConnection() {
    state = state.copyWith(
      pendingSourceNodeId: null,
      pendingSourcePropertyKey: null,
      isConnecting: false,
    );
  }

  void completeConnection(String targetId) {
    if (state.pendingSourceNodeId == null || state.pendingSourceNodeId == targetId) {
      cancelConnection();
      return;
    }

    _saveToUndoStack();

    final sourceNode = state.nodes.firstWhere((n) => n.id == state.pendingSourceNodeId);
    
    // Determine target node exists
    final targetNodeExists = state.nodes.any((n) => n.id == targetId);
    if (!targetNodeExists) {
      cancelConnection();
      return;
    }

    final rand = math.Random();
    final id = 'edge_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(1000000)}';
    String? sourceProp = state.pendingSourcePropertyKey;
    String label = '';
    bool isOneToMany = false;

    if (state.connectionMode == EdgeType.referencing) {
      if (sourceProp != null && sourceNode.type == NodeType.entity) {
        final prop = sourceNode.properties.firstWhere((p) => p.key == sourceProp);
        if (prop.dataType == DataType.array) {
          isOneToMany = true;
        }
      }
    } else if (state.connectionMode == EdgeType.denormalization) {
      label = sourceProp ?? 'replicated';
    }

    final newEdge = FDMEdge(
      id: id,
      sourceNodeId: state.pendingSourceNodeId!,
      targetNodeId: targetId,
      type: state.connectionMode,
      sourcePropertyKey: sourceProp,
      label: label,
      isOneToMany: isOneToMany,
    );

    final index = state.edges.indexWhere((e) =>
        e.sourceNodeId == state.pendingSourceNodeId &&
        e.targetNodeId == targetId &&
        e.type == state.connectionMode &&
        e.sourcePropertyKey == sourceProp);

    List<FDMEdge> newEdges;
    if (index != -1) {
      newEdges = List<FDMEdge>.from(state.edges);
      newEdges[index] = newEdges[index].copyWith(
        isOneToMany: isOneToMany,
        label: label,
      );
    } else {
      newEdges = List<FDMEdge>.from(state.edges)..add(newEdge);
    }

    state = state.copyWith(
      edges: newEdges,
      pendingSourceNodeId: null,
      pendingSourcePropertyKey: null,
      isConnecting: false,
    );
    _runValidation();
  }

  void deleteEdge(String edgeId) {
    _saveToUndoStack();
    final newEdges = state.edges.where((e) => e.id != edgeId).toList();
    state = state.copyWith(edges: newEdges, selectedEdgeId: state.selectedEdgeId == edgeId ? null : state.selectedEdgeId);
    _runValidation();
  }

  void addBoundary(SecurityBoundary boundary) {
    _saveToUndoStack();
    final newBoundaries = List<SecurityBoundary>.from(state.boundaries)..add(boundary);
    state = state.copyWith(boundaries: newBoundaries, selectedBoundaryId: boundary.id, selectedNodeId: null, selectedEdgeId: null);
    _runValidation();
  }

  void updateBoundaryRect(String boundaryId, Rect newRect) {
    // REQ-025: Enforce minimum size when resizing
    final clampedRect = Rect.fromLTWH(
      newRect.left,
      newRect.top,
      newRect.width < 80 ? 80 : newRect.width,
      newRect.height < 80 ? 80 : newRect.height,
    );
    final newBoundaries = state.boundaries.map((b) {
      if (b.id == boundaryId) {
        // REQ-026: recompute enclosed nodes using consistent center-point logic
        final enclosed = <String>[];
        for (final node in state.nodes) {
          final nodeCenter = Offset(
            node.position.dx + (node.type == NodeType.structural ? 100.0 : 110.0),
            node.position.dy + (node.type == NodeType.structural ? 40.0 : 60.0),
          );
          if (clampedRect.contains(nodeCenter)) {
            enclosed.add(node.id);
          }
        }
        return b.copyWith(rect: clampedRect, enclosedNodeIds: enclosed);
      }
      return b;
    }).toList();
    state = state.copyWith(boundaries: newBoundaries);
    _runValidation();
  }

  void updateBoundaryProperties(String boundaryId, String accessLevel) {
    _saveToUndoStack();
    final newBoundaries = state.boundaries.map((b) {
      if (b.id == boundaryId) {
        return b.copyWith(accessLevel: accessLevel);
      }
      return b;
    }).toList();
    state = state.copyWith(boundaries: newBoundaries);
    _runValidation();
  }

  void deleteBoundary(String boundaryId) {
    _saveToUndoStack();
    final newBoundaries = state.boundaries.where((b) => b.id != boundaryId).toList();
    state = state.copyWith(boundaries: newBoundaries, selectedBoundaryId: state.selectedBoundaryId == boundaryId ? null : state.selectedBoundaryId);
    _runValidation();
  }

  void selectNode(String? id) {
    state = state.copyWith(
      selectedNodeId: id,
      selectedBoundaryId: null,
      selectedEdgeId: null,
    );
  }

  void selectBoundary(String? id) {
    state = state.copyWith(
      selectedBoundaryId: id,
      selectedNodeId: null,
      selectedEdgeId: null,
    );
  }

  void selectEdge(String? id) {
    state = state.copyWith(
      selectedEdgeId: id,
      selectedNodeId: null,
      selectedBoundaryId: null,
    );
  }

  void setFirestoreMode(bool val) {
    _saveToUndoStack();
    state = state.copyWith(isFirestoreMode: val);
    _runValidation();
  }

  void updateQueryVector(String nodeId, QueryVector qv) {
    _saveToUndoStack();
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        return n.copyWith(queryVector: qv);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
    _runValidation();
  }

  void toggleValidationReport() {
    state = state.copyWith(showValidationReport: !state.showValidationReport);
  }

  void loadDiagram(List<FDMNode> nodes, List<FDMEdge> edges, List<SecurityBoundary> boundaries, bool isFirestoreMode) {
    _saveToUndoStack();
    state = state.copyWith(
      nodes: nodes,
      edges: edges,
      boundaries: boundaries,
      isFirestoreMode: isFirestoreMode,
      selectedNodeId: null,
      selectedBoundaryId: null,
      selectedEdgeId: null,
    );
    _runValidation();
  }

  void clearCanvas() {
    _saveToUndoStack();
    state = DiagramState(isFirestoreMode: state.isFirestoreMode);
    _runValidation();
  }

  void _runValidation() {
    final results = validateDiagram(state.nodes, state.edges, state.boundaries, state.isFirestoreMode);
    state = state.copyWith(validationResults: results);
  }

  // ── REQ-024: Boundary Drawing Mode ─────────────────────────────────────────

  /// Toggles boundary drawing mode on/off.
  void toggleBoundaryDrawingMode() {
    final next = !state.isBoundaryDrawingMode;
    state = state.copyWith(
      isBoundaryDrawingMode: next,
      boundaryDraftStart: null,
      boundaryDraftEnd: null,
    );
  }

  /// Records the starting point of a boundary drag.
  void startBoundaryDraw(Offset start) {
    state = state.copyWith(
      boundaryDraftStart: start,
      boundaryDraftEnd: start,
    );
  }

  /// Updates the current end point of the draft rectangle while dragging.
  void updateBoundaryDraft(Offset end) {
    state = state.copyWith(boundaryDraftEnd: end);
  }

  /// Commits the draft as a real SecurityBoundary if it is large enough (min 60×60).
  void commitBoundaryDraft() {
    final start = state.boundaryDraftStart;
    final end = state.boundaryDraftEnd;

    if (start != null && end != null) {
      final rect = Rect.fromPoints(start, end);
      if (rect.width >= 60 && rect.height >= 60) {
        _saveToUndoStack();
        final rand = math.Random();
        final id = 'boundary_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(1000000)}';
        final enclosed = <String>[];
        for (final node in state.nodes) {
          final nodeCenter = Offset(
            node.position.dx + (node.type == NodeType.structural ? 100.0 : 110.0),
            node.position.dy + (node.type == NodeType.structural ? 40.0 : 60.0),
          );
          if (rect.contains(nodeCenter)) {
            enclosed.add(node.id);
          }
        }
        final boundary = SecurityBoundary(
          id: id,
          accessLevel: 'public',
          enclosedNodeIds: enclosed,
          rect: rect,
        );
        final newBoundaries = List<SecurityBoundary>.from(state.boundaries)..add(boundary);
        state = state.copyWith(
          boundaries: newBoundaries,
          selectedBoundaryId: id,
          selectedNodeId: null,
          selectedEdgeId: null,
          isBoundaryDrawingMode: false,
          boundaryDraftStart: null,
          boundaryDraftEnd: null,
        );
        _runValidation();
        return;
      }
    }
    cancelBoundaryDraw();
  }

  /// Cancels the current boundary draw without creating anything.
  void cancelBoundaryDraw() {
    state = state.copyWith(
      isBoundaryDrawingMode: false,
      boundaryDraftStart: null,
      boundaryDraftEnd: null,
    );
  }
}

final diagramProvider = NotifierProvider<DiagramNotifier, DiagramState>(() {
  return DiagramNotifier();
});

final canvasKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

class NodeHoverNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setHover(bool val) {
    state = val;
  }
}

final nodeHoverProvider = NotifierProvider<NodeHoverNotifier, bool>(() {
  return NodeHoverNotifier();
});

