import 'dart:convert';
import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: (Map<String, dynamic>? data) async {
      if (data != null && data.containsKey('screenshots')) {
        final Map<String, dynamic> screenshots = data['screenshots'] as Map<String, dynamic>;
        for (final String name in screenshots.keys) {
          final String base64Data = screenshots[name] as String;
          final List<int> bytes = base64Decode(base64Data);
          final File file = File('integration_test/screenshots/$name.png');
          await file.create(recursive: true);
          await file.writeAsBytes(bytes);
          print('Screenshot saved: $name.png');
        }
      }
    },
  );
}
