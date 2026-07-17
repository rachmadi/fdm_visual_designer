// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/metamodel.dart';
import '../lib/core/state.dart';

/// Helper: create a DiagramNotifier backed by a ProviderContainer
DiagramNotifier makeNotifier() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container.read(diagramProvider.notifier);
}

/// Helper: create a simple StructuralNode at [pos]
FDMNode makeStructural(String id, Offset pos) => FDMNode(
      id: id,
      type: NodeType.structural,
      name: id,
      path: '/$id',
      queryVector: QueryVector(),
      position: pos,
    );

/// Helper: create a SecurityBoundary with given rect
SecurityBoundary makeBoundary(String id, Rect rect) => SecurityBoundary(
      id: id,
      accessLevel: 'public',
      enclosedNodeIds: const [],
      rect: rect,
    );

void main() {
  // ────────────────────────────────────────────────────────────────────────────
  // REQ-024: Boundary Drawing Mode
  // ────────────────────────────────────────────────────────────────────────────

  group('REQ-024: Boundary Drawing Mode', () {
    test('U-24-4: toggleBoundaryDrawingMode turns mode ON', () {
      final n = makeNotifier();
      expect(n.state.isBoundaryDrawingMode, isFalse);
      n.toggleBoundaryDrawingMode();
      expect(n.state.isBoundaryDrawingMode, isTrue);
    });

    test('U-24-5: toggleBoundaryDrawingMode turns mode OFF', () {
      final n = makeNotifier();
      n.toggleBoundaryDrawingMode(); // ON
      n.toggleBoundaryDrawingMode(); // OFF
      expect(n.state.isBoundaryDrawingMode, isFalse);
    });

    test('U-24-6: updateBoundaryDraft sets boundaryDraftEnd', () {
      final n = makeNotifier();
      n.startBoundaryDraw(const Offset(100, 100));
      n.updateBoundaryDraft(const Offset(300, 300));
      expect(n.state.boundaryDraftEnd, const Offset(300, 300));
    });

    test('U-24-1: commitBoundaryDraft with valid size creates boundary', () {
      final n = makeNotifier();
      n.toggleBoundaryDrawingMode();
      n.startBoundaryDraw(const Offset(100, 100));
      n.updateBoundaryDraft(const Offset(400, 350));
      n.commitBoundaryDraft();
      expect(n.state.boundaries.length, 1);
      final rect = n.state.boundaries.first.rect;
      expect(rect.left, 100);
      expect(rect.top, 100);
      expect(rect.right, 400);
      expect(rect.bottom, 350);
    });

    test('U-24-2: commitBoundaryDraft with too-small draft does NOT create boundary', () {
      final n = makeNotifier();
      n.toggleBoundaryDrawingMode();
      n.startBoundaryDraw(const Offset(100, 100));
      n.updateBoundaryDraft(const Offset(130, 120)); // 30×20 — too small
      n.commitBoundaryDraft();
      expect(n.state.boundaries, isEmpty);
    });

    test('U-24-3: cancelBoundaryDraw clears draft state and turns mode off', () {
      final n = makeNotifier();
      n.startBoundaryDraw(const Offset(200, 200));
      n.cancelBoundaryDraw();
      expect(n.state.isBoundaryDrawingMode, isFalse);
      expect(n.state.boundaryDraftStart, isNull);
      expect(n.state.boundaryDraftEnd, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // REQ-025: Drag-to-Resize Handle
  // ────────────────────────────────────────────────────────────────────────────

  group('REQ-025: Drag-to-Resize Handle', () {
    test('U-25-1: updateBoundaryRect resizes to valid size, topLeft unchanged', () {
      final n = makeNotifier();
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 200, 200));
      n.addBoundary(b);
      // Simulate dragging bottom-right to (450, 400)
      n.updateBoundaryRect('b1', Rect.fromLTRB(100, 100, 450, 400));
      final r = n.state.boundaries.first.rect;
      expect(r.left, 100);
      expect(r.top, 100);
      expect(r.right, 450);
      expect(r.bottom, 400);
    });

    test('U-25-2: updateBoundaryRect clamps to minimum 80×80', () {
      final n = makeNotifier();
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 200, 200));
      n.addBoundary(b);
      // Try to resize to 30×40 (too small)
      n.updateBoundaryRect('b1', Rect.fromLTRB(100, 100, 130, 140));
      final r = n.state.boundaries.first.rect;
      expect(r.width, greaterThanOrEqualTo(80));
      expect(r.height, greaterThanOrEqualTo(80));
    });

    test('U-25-3: resize that covers a node adds it to enclosedNodeIds', () {
      final n = makeNotifier();
      // Node center ≈ Offset(200+100, 200+40) = (300, 240)
      final node = makeStructural('n1', const Offset(200, 200));
      n.addNode(node);
      // Boundary initially does NOT cover node center
      final b = makeBoundary('b1', const Rect.fromLTWH(400, 400, 200, 200));
      n.addBoundary(b);
      expect(n.state.boundaries.first.enclosedNodeIds, isEmpty);
      // Resize to cover node
      n.updateBoundaryRect('b1', const Rect.fromLTWH(100, 100, 400, 300));
      expect(n.state.boundaries.first.enclosedNodeIds, contains('n1'));
    });

    test('U-25-4: resize that no longer covers a node removes it from enclosedNodeIds', () {
      final n = makeNotifier();
      // Node center ≈ (300, 240)
      final node = makeStructural('n1', const Offset(200, 200));
      n.addNode(node);
      // Boundary covers node
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 400, 300));
      n.addBoundary(b);
      // Resize so node is no longer inside
      n.updateBoundaryRect('b1', Rect.fromLTRB(100, 100, 180, 180));
      expect(n.state.boundaries.first.enclosedNodeIds, isNot(contains('n1')));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // REQ-026: Deteksi Node Konsisten
  // ────────────────────────────────────────────────────────────────────────────

  group('REQ-026: Consistent Node Detection', () {
    test('U-26-1: node entering boundary during updateNodePosition is detected', () {
      final n = makeNotifier();
      // Node starts outside boundary
      final node = makeStructural('n1', const Offset(600, 600));
      n.addNode(node);
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 400, 400));
      n.addBoundary(b);
      expect(n.state.boundaries.first.enclosedNodeIds, isEmpty);
      // Move node so its center (200+100, 200+40)=(300,240) falls inside boundary
      n.updateNodePosition('n1', const Offset(200, 200));
      expect(n.state.boundaries.first.enclosedNodeIds, contains('n1'));
    });

    test('U-26-2: node leaving boundary during updateNodePosition is removed', () {
      final n = makeNotifier();
      // Node starts inside boundary
      final node = makeStructural('n1', const Offset(200, 200));
      n.addNode(node);
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 400, 400));
      n.addBoundary(b);
      // Should be detected inside after add
      n.updateNodePosition('n1', const Offset(200, 200)); // trigger recompute
      expect(n.state.boundaries.first.enclosedNodeIds, contains('n1'));
      // Move far outside
      n.updateNodePosition('n1', const Offset(1000, 1000));
      expect(n.state.boundaries.first.enclosedNodeIds, isNot(contains('n1')));
    });

    test('U-26-3: finishDragging keeps enclosedNodeIds accurate', () {
      final n = makeNotifier();
      final node = makeStructural('n1', const Offset(200, 200));
      n.addNode(node);
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 400, 400));
      n.addBoundary(b);
      n.updateNodePosition('n1', const Offset(200, 200));
      n.finishDragging();
      expect(n.state.boundaries.first.enclosedNodeIds, contains('n1'));
    });

    test('U-26-4: deleting a node removes it from enclosedNodeIds', () {
      final n = makeNotifier();
      final node = makeStructural('n1', const Offset(200, 200));
      n.addNode(node);
      final b = makeBoundary('b1', const Rect.fromLTWH(100, 100, 400, 400));
      n.addBoundary(b);
      n.updateNodePosition('n1', const Offset(200, 200));
      expect(n.state.boundaries.first.enclosedNodeIds, contains('n1'));
      n.deleteNode('n1');
      expect(n.state.boundaries.first.enclosedNodeIds, isNot(contains('n1')));
    });

    test('U-26-5: node in overlapping boundaries is member of both', () {
      final n = makeNotifier();
      // Node center ≈ (200+100, 200+40) = (300, 240)
      final node = makeStructural('n1', const Offset(200, 200));
      n.addNode(node);
      // Two boundaries that both cover node center
      final b1 = makeBoundary('b1', const Rect.fromLTWH(100, 100, 400, 300));
      final b2 = makeBoundary('b2', const Rect.fromLTWH(150, 150, 350, 250));
      n.addBoundary(b1);
      n.addBoundary(b2);
      // Trigger recompute
      n.updateNodePosition('n1', const Offset(200, 200));
      expect(n.state.boundaries[0].enclosedNodeIds, contains('n1'));
      expect(n.state.boundaries[1].enclosedNodeIds, contains('n1'));
    });
  });
}
