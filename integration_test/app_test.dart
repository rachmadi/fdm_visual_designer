import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
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

    testWidgets('Run Combined E2E Flow (Stage 1 to 3)', (tester) async {
      // ==========================================
      // STAGE 1: LAYOUT & NODE CREATION
      // ==========================================
      print('=== Memulai Stage 1: Layout & Pembuatan Node ===');
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await takeScreenshot(tester, '1_launch_screen');

      // Verify layout
      expect(find.text('FDM Visual Designer'), findsOneWidget);
      expect(find.text('NODE PALETTE'), findsOneWidget);
      expect(find.text('KEYBOARD SHORTCUTS'), findsOneWidget);

      final addStructuralBtn = find.text('Add Structural Node').first;
      final addEntityBtn = find.text('Add Entity Node').first;

      // Add 3 pairs of nodes in grid spawn layout
      for (int i = 0; i < 3; i++) {
        await tester.tap(addStructuralBtn);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.tap(addEntityBtn);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      expect(find.text('new_collection'), findsAtLeastNWidgets(3));
      expect(find.text('NewEntity'), findsAtLeastNWidgets(3));

      await takeScreenshot(tester, '2_added_nodes_grid');
      await Future.delayed(const Duration(seconds: 2));

      // Select a structural node to show properties
      await tester.tap(find.text('new_collection').first);
      await tester.pumpAndSettle();

      expect(find.text('EDIT NODE PROPERTIES'), findsOneWidget);
      expect(find.text('Node Name:'), findsOneWidget);

      await takeScreenshot(tester, '3_selected_node_properties');
      await Future.delayed(const Duration(seconds: 2));
      print('✅ Stage 1 Selesai');

      // ==========================================
      // STAGE 2: NODE INTERACTION - ZOOM & DRAG
      // ==========================================
      print('=== Memulai Stage 2: Zoom & Drag ===');
      // Simulate pinch zoom out
      final Offset zoomCenterLeft = const Offset(700.0, 500.0);
      final Offset zoomCenterRight = const Offset(900.0, 500.0);

      final TestGesture pinchPointer1 = await tester.startGesture(zoomCenterLeft);
      final TestGesture pinchPointer2 = await tester.startGesture(zoomCenterRight);
      await tester.pump();

      await pinchPointer1.moveTo(const Offset(780.0, 500.0));
      await pinchPointer2.moveTo(const Offset(820.0, 500.0));
      await tester.pumpAndSettle();

      await pinchPointer1.up();
      await pinchPointer2.up();
      await tester.pumpAndSettle();

      await takeScreenshot(tester, '4_zoomed_out_canvas');
      await Future.delayed(const Duration(seconds: 2));

      // Drag selected node
      final nodeToDrag = find.text('new_collection').first;
      final nodePosBeforeDrag = tester.getCenter(nodeToDrag);

      final TestGesture dragPointer = await tester.startGesture(nodePosBeforeDrag);
      await tester.pump();

      await dragPointer.moveTo(nodePosBeforeDrag + const Offset(120.0, 80.0));
      await tester.pumpAndSettle();

      await dragPointer.up();
      await tester.pumpAndSettle();

      await takeScreenshot(tester, '5_dragged_node_zoomed_out');
      await Future.delayed(const Duration(seconds: 2));
      print('✅ Stage 2 Selesai');

      // ==========================================
      // STAGE 3: 4-POINT CONNECTION HANDLES
      // ==========================================
      print('=== Memulai Stage 3: 4 Titik Koneksi Dinamis ===');
      // Verifikasi Relation Builder panel di sidebar kiri
      expect(find.text('RELATION BUILDER'), findsOneWidget);
      expect(find.text('Source Node:'), findsOneWidget);
      expect(find.text('Target Node:'), findsOneWidget);

      await takeScreenshot(tester, '6_nodes_with_4_handles');
      print('✅ Stage 3 Selesai');

      // ==========================================
      // STAGE 4: PROPERTY EDITOR & VALIDATION
      // ==========================================
      print('=== Memulai Stage 4: Property Editor & Validasi ===');
      // Tap on an Entity Node to show properties
      await tester.tap(find.text('NewEntity').first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Verify property editor is open
      expect(find.text('PROPERTIES (0)'), findsOneWidget);

      // 1. Add new property
      await tester.tap(find.text('Tambah property'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(const Key('add_prop_name_input')), 'name');
      await tester.pumpAndSettle();
      
      // Save it
      await tester.tap(find.byKey(const Key('add_prop_save_button')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Verify property added
      expect(find.text('name: String'), findsOneWidget);

      // 2. Form validation rules
      await tester.tap(find.text('Tambah property'));
      await tester.pumpAndSettle();

      // Check empty warning
      await tester.enterText(find.byKey(const Key('add_prop_name_input')), 'temp');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('add_prop_name_input')), '');
      await tester.pumpAndSettle();
      expect(find.text('Nama field tidak boleh kosong'), findsOneWidget);

      // Check starts with number warning
      await tester.enterText(find.byKey(const Key('add_prop_name_input')), '1field');
      await tester.pumpAndSettle();
      expect(find.text('Nama field tidak boleh diawali angka'), findsOneWidget);

      // Check duplicate warning
      await tester.enterText(find.byKey(const Key('add_prop_name_input')), 'name');
      await tester.pumpAndSettle();
      expect(find.text('Nama field sudah ada di node ini'), findsOneWidget);

      // Cancel add
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // 3. Rename inline
      await tester.ensureVisible(find.text('name: String'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('name: String'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('inline_edit_prop_name_input')), 'user_name');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('inline_edit_prop_save_button')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      expect(find.text('user_name: String'), findsOneWidget);

      // 4. Delete property with SnackBar Undo
      await tester.ensureVisible(find.byKey(const Key('delete_prop_user_name')));
      await tester.pumpAndSettle();
      
      final deleteBtn = tester.widget<IconButton>(find.byKey(const Key('delete_prop_user_name')));
      deleteBtn.onPressed!();
      
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Field "user_name" dihapus'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      // Tap UNDO
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      // Verify restored
      expect(find.text('user_name: String'), findsOneWidget);

      await takeScreenshot(tester, '7_property_editor_validated');
      print('✅ Stage 4 Selesai');

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
