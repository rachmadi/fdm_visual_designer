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
      // Find the RepaintBoundary of the entire screen
      final RenderRepaintBoundary boundary = tester.renderObject(
        find.byKey(app.globalScreenKey),
      );
      final ui.Image image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      screenshotQueue[name] = base64Encode(pngBytes);
    }

    testWidgets('Verify app layout, create structural node, and select it', (tester) async {
      // 1. Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Capture screenshot 1: Empty canvas startup state
      await takeScreenshot(tester, '1_launch_screen');

      // 2. Verify that the toolbar is present and displays "FDM Visual Designer"
      expect(find.text('FDM Visual Designer'), findsOneWidget);
      expect(find.text('NODE PALETTE'), findsOneWidget);

      // 3. Click the "Add Structural Node" button in the left sidebar
      final addStructuralBtn = find.text('Add Structural Node');
      expect(addStructuralBtn, findsOneWidget);
      await tester.tap(addStructuralBtn);
      await tester.pumpAndSettle();

      // 4. Verify a new node named "new_collection" is created on the canvas
      expect(find.text('new_collection'), findsAtLeastNWidgets(1));

      // Capture screenshot 2: After adding structural node
      await takeScreenshot(tester, '2_added_structural_node');

      // 5. Select the node to see its properties in the right sidebar
      await tester.tap(find.text('new_collection').first);
      await tester.pumpAndSettle();

      // 6. Verify that the Right Sidebar properties panel is open and displays node details
      expect(find.text('EDIT NODE PROPERTIES'), findsOneWidget);
      expect(find.text('Node Name:'), findsOneWidget);

      // Capture screenshot 3: Selected node showing right sidebar properties
      await takeScreenshot(tester, '3_selected_node_properties');

      // 7. Click the "Add Entity Node" button in the left sidebar
      final addEntityBtn = find.text('Add Entity Node');
      expect(addEntityBtn, findsOneWidget);
      await tester.tap(addEntityBtn);
      await tester.pumpAndSettle();

      // 8. Verify the new entity node is created
      expect(find.text('NewEntity'), findsAtLeastNWidgets(1));

      // Capture screenshot 4: After adding entity node
      await takeScreenshot(tester, '4_added_entity_node');

      // Send all screenshots to the driver
      binding.reportData = {'screenshots': screenshotQueue};

      // Pause a bit
      await Future.delayed(const Duration(seconds: 2));
    });
  });
}
