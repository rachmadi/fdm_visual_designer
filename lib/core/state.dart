import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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

  // Stacks for undo/redo
  final List<Map<String, dynamic>> undoStack;
  final List<Map<String, dynamic>> redoStack;

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
    this.undoStack = const [],
    this.redoStack = const [],
  });

  DiagramState copyWith({
    List<FDMNode>? nodes,
    List<FDMEdge>? edges,
    List<SecurityBoundary>? boundaries,
    String? selectedNodeId,
    String? selectedBoundaryId,
    String? selectedEdgeId,
    bool? isFirestoreMode,
    List<ValidationResult>? validationResults,
    bool? showValidationReport,
    List<Map<String, dynamic>>? undoStack,
    List<Map<String, dynamic>>? redoStack,
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
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }

  static const String _undefined = '__undefined__';

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

  void updateNodePosition(String id, Offset newPos) {
    final newNodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(position: newPos);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
  }

  void finishDragging() {
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

  void addEdge(FDMEdge edge) {
    _saveToUndoStack();
    final newEdges = List<FDMEdge>.from(state.edges)..add(edge);
    state = state.copyWith(edges: newEdges);
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
    final newBoundaries = state.boundaries.map((b) {
      if (b.id == boundaryId) {
        // Find nodes enclosed by this new boundary rect
        final enclosed = <String>[];
        for (final node in state.nodes) {
          // Center of the node
          // Assuming a rough size for nodes (Structural: 150x60, Entity: 200x200)
          final nodeCenter = Offset(node.position.dx + 100, node.position.dy + 40);
          if (newRect.contains(nodeCenter)) {
            enclosed.add(node.id);
          }
        }
        return b.copyWith(rect: newRect, enclosedNodeIds: enclosed);
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
      selectedNodeId: id ?? DiagramState._undefined,
      selectedBoundaryId: DiagramState._undefined,
      selectedEdgeId: DiagramState._undefined,
    );
  }

  void selectBoundary(String? id) {
    state = state.copyWith(
      selectedBoundaryId: id ?? DiagramState._undefined,
      selectedNodeId: DiagramState._undefined,
      selectedEdgeId: DiagramState._undefined,
    );
  }

  void selectEdge(String? id) {
    state = state.copyWith(
      selectedEdgeId: id ?? DiagramState._undefined,
      selectedNodeId: DiagramState._undefined,
      selectedBoundaryId: DiagramState._undefined,
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
}

final diagramProvider = NotifierProvider<DiagramNotifier, DiagramState>(() {
  return DiagramNotifier();
});

final canvasKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

