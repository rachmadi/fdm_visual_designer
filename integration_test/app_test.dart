import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fdm_visual_designer/main.dart' as app;

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FDM Visual Designer E2E Integration Tests', () {
    final Map<String, String> screenshotQueue = {};

    Future<void> takeScreenshot(WidgetTester tester, String name) async {
      await tester.pumpAndSettle();
      final RenderRepaintBoundary boundary = tester.renderObject(
        find.byKey(app.globalScreenKey),
      );
      final ui.Image image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      screenshotQueue[name] = base64Encode(pngBytes);
    }

    testWidgets('Run Combined E2E Flow (Stage 1 to 5)', (tester) async {
      // ==========================================
      // STAGE 1: LAYOUT & NODE CREATION
      // ==========================================
      print('=== Starting Stage 1: Layout & Node Creation ===');
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await takeScreenshot(tester, '1_launch_screen');

      // Verify layout
      expect(find.text('FDM Visual Designer'), findsOneWidget);
      expect(find.text('NODE PALETTE'), findsOneWidget);

      final addStructuralBtn = find.text('Add Structural Node').first;
      final addEntityBtn = find.text('Add Entity Node').first;

      // Add a couple of nodes
      await tester.tap(addStructuralBtn);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await tester.tap(addEntityBtn);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      expect(find.text('new_collection'), findsAtLeastNWidgets(1));
      expect(find.text('NewEntity'), findsAtLeastNWidgets(1));

      await takeScreenshot(tester, '2_added_nodes_grid');
      await Future.delayed(const Duration(seconds: 1));
      print('✅ Stage 1 Done');

      // ==========================================
      // STAGE 2: NODE INTERACTION - SELECTING & DRAG
      // ==========================================
      print('=== Starting Stage 2: Node Selection & Dragging ===');
      // Tap entity node to select it
      await tester.tap(find.text('NewEntity').first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      expect(find.text('EDIT NODE PROPERTIES'), findsOneWidget);

      await takeScreenshot(tester, '3_selected_node_properties');
      await Future.delayed(const Duration(seconds: 1));
      print('✅ Stage 2 Done');

      // ==========================================
      // STAGE 3: PROPERTY EDITOR WITH ENTER SUBMIT & INDEX ESTIMATION
      // ==========================================
      print('=== Starting Stage 3: Property Editor (Enter Submit & Single-Field Index) ===');
      
      // 1. Add property via form
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('add_prop_name_input')), 'task_id');
      await tester.pumpAndSettle();

      // Submit by simulating Enter key press (captures focus Enter event)
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Verify task_id added
      expect(find.text('task_id: String'), findsOneWidget);

      // 2. Validate empty, duplicate, start-with-number warnings
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('add_prop_name_input')), 'temp');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('add_prop_name_input')), '');
      await tester.pumpAndSettle();
      expect(find.text('Field name cannot be empty'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('add_prop_name_input')), '1num');
      await tester.pumpAndSettle();
      expect(find.text('Field name cannot start with a number'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('add_prop_name_input')), 'task_id');
      await tester.pumpAndSettle();
      expect(find.text('Field name already exists in this node'), findsOneWidget);

      // Cancel adding
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // 3. Configure Query Vector for 'task_id' (filter + sort on the SAME field)
      // Open filter dropdown and select task_id
      await tester.ensureVisible(find.byKey(const Key('qv_filter_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('qv_filter_dropdown')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.tap(find.text('task_id').last);
      await tester.pumpAndSettle();

      // Tap add filter button
      await tester.ensureVisible(find.byKey(const Key('qv_filter_add_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('qv_filter_add_button')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Open sort dropdown and select task_id
      await tester.ensureVisible(find.byKey(const Key('qv_sort_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('qv_sort_dropdown')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.tap(find.text('task_id').last);
      await tester.pumpAndSettle();

      // Tap add sort button
      await tester.ensureVisible(find.byKey(const Key('qv_sort_add_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('qv_sort_add_button')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Verify estimated index is SINGLE-FIELD, not COMPOSITE!
      expect(find.text('Index: Single-Field Index'), findsOneWidget);

      await takeScreenshot(tester, '4_query_vector_single_field');
      print('✅ Stage 3 Done');

      // ==========================================
      // STAGE 4: RELATION BUILDER & NO-DUPLICATES
      // ==========================================
      print('=== Starting Stage 4: Relation Builder (No-Duplicates & Context-Aware) ===');
      // Create relation in sidebar left
      await tester.tap(find.text('Select Source'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.tap(find.text('new_collection (Structural)').last);
      await tester.pumpAndSettle();

      // Verify that relation type is automatically restricted to Hierarchy
      expect(find.text('Hierarchy (SN ⇄ EN)'), findsOneWidget);

      await tester.tap(find.text('Select Target'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.tap(find.text('NewEntity (Entity)').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect Nodes'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      await takeScreenshot(tester, '5_connected_nodes');
      print('✅ Stage 4 Done');

      // ==========================================
      // STAGE 5: EDIT/DELETE RELATION via CANVAS TAP
      // ==========================================
      print('=== Starting Stage 5: Select & Edit/Delete Connection via Canvas ===');
      
      // Tap on the edge line to select it
      // Let's compute the screen midpoint between the two nodes dynamically
      final Offset pos1 = tester.getCenter(find.text('new_collection').first);
      final Offset pos2 = tester.getCenter(find.text('NewEntity').first);
      final Offset edgeMidPoint = Offset((pos1.dx + pos2.dx) / 2, ((pos1.dy + pos2.dy) / 2) + 30.0);

      await tester.tapAt(edgeMidPoint);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // If selected, right panel shows EDIT CONNECTION PROPERTIES
      expect(find.text('EDIT CONNECTION PROPERTIES'), findsOneWidget);
      expect(find.text('Delete Connection'), findsOneWidget);

      // Tap Delete Connection button
      await tester.tap(find.text('Delete Connection'));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Verify connection is removed
      expect(find.text('EDIT CONNECTION PROPERTIES'), findsNothing);

      await takeScreenshot(tester, '6_deleted_connection');
      print('✅ Stage 5 Done');

      // CRITICAL: Tahan jendela browser selama 35 detik agar dapat diperiksa pengguna
      print('=== Menahan jendela browser selama 35 detik... ===');
      await Future.delayed(const Duration(seconds: 35));
    });

    // Finalize screenshots
    tearDownAll(() {
      binding.reportData = {'screenshots': screenshotQueue};
    });
  });
}
