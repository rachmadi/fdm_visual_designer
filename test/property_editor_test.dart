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

    test('Query Vector: updateQueryVector and Index Estimation', () {
      final container = ProviderContainer();
      final notifier = container.read(diagramProvider.notifier);

      final node = FDMNode(
        id: 'node_1',
        type: NodeType.entity,
        name: 'User',
        path: '/users/\$userId',
        properties: [
          PropertyNode(key: 'age', dataType: DataType.number),
          PropertyNode(key: 'status', dataType: DataType.boolean),
        ],
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      notifier.state = DiagramState(nodes: [node]);

      // Update query vector with a filter and sort
      final qv = QueryVector(
        filterFields: ['age'],
        sortFields: [SortField(field: 'status', direction: 'asc')],
        estimatedIndexes: EstimatedIndex.composite,
      );
      notifier.updateQueryVector('node_1', qv);

      final updatedNode = container.read(diagramProvider).nodes.first;
      expect(updatedNode.queryVector.filterFields.length, equals(1));
      expect(updatedNode.queryVector.filterFields[0], equals('age'));
      expect(updatedNode.queryVector.sortFields.length, equals(1));
      expect(updatedNode.queryVector.sortFields[0].field, equals('status'));
      expect(updatedNode.queryVector.estimatedIndexes, equals(EstimatedIndex.composite));
    });

    test('Query Vector: single field index estimation when filter and sort are on the same field', () {
      final container = ProviderContainer();
      final notifier = container.read(diagramProvider.notifier);

      final node = FDMNode(
        id: 'node_1',
        name: 'Task',
        type: NodeType.entity,
        path: 'tasks/\$id',
        properties: [
          PropertyNode(key: 'task_id', dataType: DataType.string),
        ],
        queryVector: QueryVector(),
        position: Offset.zero,
      );

      notifier.state = DiagramState(nodes: [node]);

      // Filter and sort on the same field 'task_id'
      final qv = QueryVector(
        filterFields: ['task_id'],
        sortFields: [SortField(field: 'task_id', direction: 'asc')],
        estimatedIndexes: EstimatedIndex.single,
      );
      notifier.updateQueryVector('node_1', qv);

      final updatedNode = container.read(diagramProvider).nodes.first;
      expect(updatedNode.queryVector.estimatedIndexes, equals(EstimatedIndex.single));
    });
  });
}
