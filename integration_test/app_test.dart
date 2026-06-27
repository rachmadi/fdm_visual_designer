import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fdm_visual_designer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FDM Visual Designer E2E Integration Tests', () {
    testWidgets('Verify app layout, create structural node, and select it', (tester) async {
      // 1. Launch the app
      app.main();
      await tester.pumpAndSettle();

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

      // 5. Select the node to see its properties in the right sidebar
      await tester.tap(find.text('new_collection').first);
      await tester.pumpAndSettle();

      // 6. Verify that the Right Sidebar properties panel is open and displays node details
      expect(find.text('EDIT NODE PROPERTIES'), findsOneWidget);
      expect(find.text('Node Name:'), findsOneWidget);

      // 7. Click the "Add Entity Node" button in the left sidebar
      final addEntityBtn = find.text('Add Entity Node');
      expect(addEntityBtn, findsOneWidget);
      await tester.tap(addEntityBtn);
      await tester.pumpAndSettle();

      // 8. Verify the new entity node is created
      expect(find.text('NewEntity'), findsAtLeastNWidgets(1));

      // Pause a bit so the headed execution is visible on the screen
      await Future.delayed(const Duration(seconds: 4));
    });
  });
}
