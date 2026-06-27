import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fdm_visual_designer/core/metamodel.dart';
import 'package:fdm_visual_designer/engine/validator.dart';

void main() {
  group('FDM Well-Formedness Rules (WFR) Validator Engine Tests', () {
    test('Rule 1: Firestore Strict Alternation (SN -> EN -> SN)', () {
      final nodes = [
        FDMNode(id: 'sn1', type: NodeType.structural, name: 'chats', path: '/chats', queryVector: QueryVector(), position: Offset.zero),
        FDMNode(id: 'sn2', type: NodeType.structural, name: 'messages', path: '/chats/messages', queryVector: QueryVector(), position: Offset.zero),
      ];
      final edges = [
        FDMEdge(id: 'e1', type: EdgeType.hierarchy, sourceNodeId: 'sn1', targetNodeId: 'sn2'), // SN -> SN (invalid)
      ];

      final results = validateDiagram(nodes, edges, [], true);
      expect(results.any((r) => r.ruleId == 'R1'), isTrue);
    });

    test('Rule 2: Referencing target must exist and be an Entity Node', () {
      final nodes = [
        FDMNode(
          id: 'en1', 
          type: NodeType.entity, 
          name: 'Chat', 
          path: '/chats/\$chatId', 
          properties: [PropertyNode(key: 'user_ref', dataType: DataType.reference, isReferencing: true)],
          queryVector: QueryVector(), 
          position: Offset.zero,
        ),
      ];
      final edges = [
        FDMEdge(id: 'e1', type: EdgeType.referencing, sourceNodeId: 'en1', sourcePropertyKey: 'user_ref', targetNodeId: 'nonexistent'),
      ];

      final results = validateDiagram(nodes, edges, [], true);
      expect(results.any((r) => r.ruleId == 'R2'), isTrue);
    });

    test('Rule 3: Denormalized Property source property key link', () {
      final nodes = [
        FDMNode(id: 'en1', type: NodeType.entity, name: 'Chat', path: '/chats/\$chatId', properties: [], queryVector: QueryVector(), position: Offset.zero),
        FDMNode(id: 'en2', type: NodeType.entity, name: 'User', path: '/users/\$userId', queryVector: QueryVector(), position: Offset.zero),
      ];
      final edges = [
        // Source node has no properties, so 'username' is invalid
        FDMEdge(id: 'e1', type: EdgeType.denormalization, sourceNodeId: 'en1', sourcePropertyKey: 'username', targetNodeId: 'en2'),
      ];

      final results = validateDiagram(nodes, edges, [], true);
      expect(results.any((r) => r.ruleId == 'R3'), isTrue);
    });

    test('Rule 4: Dynamic path must use \$ wildcard prefix or {} brackets', () {
      final nodeInvalid = FDMNode(
        id: 'en1', 
        type: NodeType.entity, 
        name: 'Chat', 
        path: '/chats/chatId', // Invalid: dynamic but doesn't have $ or {}
        isDynamic: true,
        queryVector: QueryVector(), 
        position: Offset.zero,
      );

      final nodeValid = FDMNode(
        id: 'en2', 
        type: NodeType.entity, 
        name: 'User', 
        path: '/users/\$userId', // Valid
        isDynamic: true,
        queryVector: QueryVector(), 
        position: Offset.zero,
      );

      final resultsInvalid = validateDiagram([nodeInvalid], [], [], true);
      final resultsValid = validateDiagram([nodeValid], [], [], true);

      expect(resultsInvalid.any((r) => r.ruleId == 'R4'), isTrue);
      expect(resultsValid.any((r) => r.ruleId == 'R4'), isFalse);
    });

    test('Rule 5: Query Vector references defined properties', () {
      final node = FDMNode(
        id: 'en1',
        type: NodeType.entity,
        name: 'Chat',
        path: '/chats/\$chatId',
        properties: [PropertyNode(key: 'sent_at', dataType: DataType.timestamp)],
        queryVector: QueryVector(
          filterFields: ['sent_at'],
          sortFields: [SortField(field: 'sender_id', direction: 'asc')], // Invalid: sender_id not in properties
        ),
        position: Offset.zero,
      );

      final results = validateDiagram([node], [], [], true);
      expect(results.any((r) => r.ruleId == 'R5'), isTrue);
    });

    test('Rule 6: Security Boundary partial overlap', () {
      final boundary = SecurityBoundary(
        id: 'sb1',
        accessLevel: 'public',
        enclosedNodeIds: [],
        rect: const Rect.fromLTWH(0, 0, 200, 200),
      );
      final nodePartiallyOverlapping = FDMNode(
        id: 'en1',
        type: NodeType.entity,
        name: 'Chat',
        path: '/chats/\$chatId',
        queryVector: QueryVector(),
        position: const Offset(100, 100), // Node is 220x180, so rect is [100, 100, 320, 280]. Overlaps with [0,0,200,200] but not contained.
      );

      final results = validateDiagram([nodePartiallyOverlapping], [], [boundary], true);
      expect(results.any((r) => r.ruleId == 'R6'), isTrue);
    });

    test('Rule 7: Physical warning - unbounded complex type (1MB limit)', () {
      final node = FDMNode(
        id: 'en1',
        type: NodeType.entity,
        name: 'Chat',
        path: '/chats/\$chatId',
        properties: [
          PropertyNode(key: 'messages', dataType: DataType.array, isUnbounded: true), // Trigger
        ],
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      final results = validateDiagram([node], [], [], true);
      expect(results.any((r) => r.ruleId == 'R7' && r.severity == 'warning'), isTrue);
    });

    test('Rule 8: Physical warning - high frequency writes (>1/s limit)', () {
      final node = FDMNode(
        id: 'en1',
        type: NodeType.entity,
        name: 'Chat',
        path: '/chats/\$chatId',
        isHighFrequency: true, // Trigger
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      final results = validateDiagram([node], [], [], true);
      expect(results.any((r) => r.ruleId == 'R8' && r.severity == 'warning'), isTrue);
    });
  });
}
