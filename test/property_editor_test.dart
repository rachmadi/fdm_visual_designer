import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fdm_visual_designer/core/metamodel.dart';
import 'package:fdm_visual_designer/core/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Property Editor State & Validation Tests', () {
    test('State Mutation: reorderProperties', () {
      final container = ProviderContainer();
      final notifier = container.read(diagramProvider.notifier);

      // Create a node with properties
      final node = FDMNode(
        id: 'node_1',
        type: NodeType.entity,
        name: 'User',
        path: '/users/\$userId',
        properties: [
          PropertyNode(key: 'name', dataType: DataType.string),
          PropertyNode(key: 'email', dataType: DataType.string),
          PropertyNode(key: 'age', dataType: DataType.number),
        ],
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      // Initialize state with node
      notifier.state = DiagramState(nodes: [node]);

      // Reorder: Move 'name' (index 0) to after 'email' (index 1), so newIndex is 2
      notifier.reorderProperties('node_1', 0, 2);

      final updatedNode = container.read(diagramProvider).nodes.first;
      expect(updatedNode.properties[0].key, equals('email'));
      expect(updatedNode.properties[1].key, equals('name'));
      expect(updatedNode.properties[2].key, equals('age'));
    });

    test('State Mutation: insertPropertyAt', () {
      final container = ProviderContainer();
      final notifier = container.read(diagramProvider.notifier);

      final node = FDMNode(
        id: 'node_1',
        type: NodeType.entity,
        name: 'User',
        path: '/users/\$userId',
        properties: [
          PropertyNode(key: 'name', dataType: DataType.string),
          PropertyNode(key: 'age', dataType: DataType.number),
        ],
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      notifier.state = DiagramState(nodes: [node]);

      // Insert 'email' at index 1
      notifier.insertPropertyAt(
        'node_1',
        1,
        PropertyNode(key: 'email', dataType: DataType.string),
      );

      final updatedNode = container.read(diagramProvider).nodes.first;
      expect(updatedNode.properties.length, equals(3));
      expect(updatedNode.properties[0].key, equals('name'));
      expect(updatedNode.properties[1].key, equals('email'));
      expect(updatedNode.properties[2].key, equals('age'));
    });

    test('State Mutation: renameProperty via updateProperty', () {
      final container = ProviderContainer();
      final notifier = container.read(diagramProvider.notifier);

      final node = FDMNode(
        id: 'node_1',
        type: NodeType.entity,
        name: 'User',
        path: '/users/\$userId',
        properties: [
          PropertyNode(key: 'name', dataType: DataType.string),
        ],
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      notifier.state = DiagramState(nodes: [node]);

      // Update name to full_name
      notifier.updateProperty(
        'node_1',
        'name',
        PropertyNode(key: 'full_name', dataType: DataType.string),
      );

      final updatedNode = container.read(diagramProvider).nodes.first;
      expect(updatedNode.properties[0].key, equals('full_name'));
    });
  });
}
