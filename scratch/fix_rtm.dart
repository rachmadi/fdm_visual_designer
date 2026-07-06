import 'dart:io';

void main() {
  final file = File('E:/rachmadi/Antigravity/fdm_visual_designer/dokumentasi-pengembangan/00_requirement_traceability_matrix.md');
  final text = file.readAsStringSync();
  final lines = text.split(RegExp(r'\r\n|\r|\n'));
  final normalized = lines.join('\n');
  file.writeAsStringSync(normalized);
  print('RTM file normalized with LF newlines.');
}
