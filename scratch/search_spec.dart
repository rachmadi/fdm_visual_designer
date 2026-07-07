import 'dart:io';

void main() {
  final file = File('lib/panels/sidebar_right.dart');
  if (!file.existsSync()) return;
  
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Simpan')) {
      print('Line ${i + 1}: ${lines[i]}');
    }
  }
}
