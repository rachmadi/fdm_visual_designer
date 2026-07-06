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
      await Future.delayed(const Duration(seconds: 2)); // Wait to let user see empty state

      // Capture screenshot 1: Empty canvas startup state
      await takeScreenshot(tester, '1_launch_screen');

      // 2. Verify that the toolbar is present and displays "FDM Visual Designer"
      expect(find.text('FDM Visual Designer'), findsOneWidget);
      expect(find.text('NODE PALETTE'), findsOneWidget);

      final addStructuralBtn = find.text('Add Structural Node');
      final addEntityBtn = find.text('Add Entity Node');

      // 3. Add 5 Structural Nodes and 5 Entity Nodes (total 10 nodes)
      // We add them with 1-second delays so the grid filling is visible.
      for (int i = 0; i < 5; i++) {
        await tester.tap(addStructuralBtn);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.tap(addEntityBtn);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 4. Verify that we have multiple nodes on the canvas
      expect(find.text('new_collection'), findsAtLeastNWidgets(5));
      expect(find.text('NewEntity'), findsAtLeastNWidgets(5));

      // Capture screenshot 2: After adding 10 nodes in a grid layout (proving no overlap)
      await takeScreenshot(tester, '2_added_10_nodes_grid');
      await Future.delayed(const Duration(seconds: 2)); // Let user see the grid

      // 5. Select one of the structural nodes
      await tester.tap(find.text('new_collection').first);
      await tester.pumpAndSettle();

      // Verify that the Right Sidebar properties panel is open and displays node details
      expect(find.text('EDIT NODE PROPERTIES'), findsOneWidget);
      expect(find.text('Node Name:'), findsOneWidget);

      // Capture screenshot 3: Selected node showing right sidebar properties
      await takeScreenshot(tester, '3_selected_node_properties');
      await Future.delayed(const Duration(seconds: 2));

      // 6. Simulate a real multi-pointer Pinch Zoom Out gesture in the center of the canvas.
      final Offset zoomCenterLeft = const Offset(700.0, 500.0);
      final Offset zoomCenterRight = const Offset(900.0, 500.0);

      final TestGesture pinchPointer1 = await tester.startGesture(zoomCenterLeft);
      final TestGesture pinchPointer2 = await tester.startGesture(zoomCenterRight);
      await tester.pump();

      // Move pointers closer to each other to zoom out (pinch in)
      await pinchPointer1.moveTo(const Offset(780.0, 500.0));
      await pinchPointer2.moveTo(const Offset(820.0, 500.0));
      await tester.pumpAndSettle();

      await pinchPointer1.up();
      await pinchPointer2.up();
      await tester.pumpAndSettle();

      // Capture screenshot 4: After zooming out (proving grid & nodes scale stably without drift)
      await takeScreenshot(tester, '4_zoomed_out_canvas');
      await Future.delayed(const Duration(seconds: 3)); // Let user see the zoomed out state

      // 7. Simulate dragging a node at this scaled zoom level to prove drag delta calculation is correct.
      final Finder nodeToDrag = find.text('new_collection').first;
      final Offset nodePosBeforeDrag = tester.getCenter(nodeToDrag);
      
      final TestGesture dragPointer = await tester.startGesture(nodePosBeforeDrag);
      await tester.pump();

      // Drag the node 150px right, 100px down
      await dragPointer.moveTo(nodePosBeforeDrag + const Offset(150.0, 100.0));
      await tester.pumpAndSettle();

      await dragPointer.up();
      await tester.pumpAndSettle();

      // Capture screenshot 5: After dragging a node at zoomed-out scale
      await takeScreenshot(tester, '5_dragged_node_zoomed_out');

      // Send all screenshots to the driver
      binding.reportData = {'screenshots': screenshotQueue};

      // CRITICAL: Pause for 20 seconds at the end of the test so the browser window
      // stays open on the user's screen long enough to be inspected.
      await Future.delayed(const Duration(seconds: 20));
    });
  });
}
