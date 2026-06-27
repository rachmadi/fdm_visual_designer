import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
// Conditional import for web
import 'dart:html' as html;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/state.dart';
import '../../export/serializer.dart';

class Toolbar extends ConsumerWidget {
  const Toolbar({super.key});

  Future<void> _importJson(WidgetRef ref, BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          final jsonStr = utf8.decode(bytes);
          final parsed = FdmSerializer.parse(jsonStr);
          if (parsed != null) {
            ref.read(diagramProvider.notifier).loadDiagram(
              parsed['nodes'],
              parsed['edges'],
              parsed['boundaries'],
              parsed['isFirestoreMode'],
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagram loaded successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid FDM Diagram Schema JSON.')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  void _exportJson(WidgetRef ref) {
    final state = ref.read(diagramProvider);
    final jsonStr = FdmSerializer.serialize(state);
    FdmSerializer.downloadJsonWeb(jsonStr, 'fdm_diagram.json');
  }

  Future<void> _exportPng(WidgetRef ref, BuildContext context) async {
    try {
      final key = ref.read(canvasKeyProvider);
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Canvas viewport not ready.')),
        );
        return;
      }
      
      // Capture at 2.0x device pixel ratio for publication quality (High DPI equivalent)
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        if (kIsWeb) {
          final blob = html.Blob([bytes], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'fdm_diagram.png';
          html.document.body?.children.add(anchor);
          anchor.click();
          anchor.remove();
          html.Url.revokeObjectUrl(url);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PNG diagram exported successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PNG export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagramProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Logo / Title
          Row(
            children: [
              const Icon(Icons.hub, color: Color(0xFF2E75B6), size: 24),
              const SizedBox(width: 8),
              Text(
                'FDM Visual Designer',
                style: TextStyle(
                  color: textCol,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Firebase',
                  style: TextStyle(
                    color: Color(0xFF1A3A5C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Firestore vs RTDB Mode Toggle
          Row(
            children: [
              Text(
                'Mode:',
                style: TextStyle(color: textCol.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Firestore', style: TextStyle(fontSize: 12)),
                selected: state.isFirestoreMode,
                onSelected: (val) {
                  if (val) ref.read(diagramProvider.notifier).setFirestoreMode(true);
                },
                selectedColor: const Color(0xFF2E75B6),
                labelStyle: TextStyle(color: state.isFirestoreMode ? Colors.white : textCol),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('Realtime DB', style: TextStyle(fontSize: 12)),
                selected: !state.isFirestoreMode,
                onSelected: (val) {
                  if (val) ref.read(diagramProvider.notifier).setFirestoreMode(false);
                },
                selectedColor: const Color(0xFFE07B00),
                labelStyle: TextStyle(color: !state.isFirestoreMode ? Colors.white : textCol),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const VerticalDivider(width: 1, indent: 16, endIndent: 16),
          const SizedBox(width: 10),

          // Undo / Redo
          IconButton(
            icon: const Icon(Icons.undo, size: 18),
            tooltip: 'Undo',
            onPressed: state.undoStack.isNotEmpty 
                ? () => ref.read(diagramProvider.notifier).undo() 
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 18),
            tooltip: 'Redo',
            onPressed: state.redoStack.isNotEmpty 
                ? () => ref.read(diagramProvider.notifier).redo() 
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            tooltip: 'Clear Canvas',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Canvas'),
                  content: const Text('Are you sure you want to clear all nodes and edges from the workspace?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(diagramProvider.notifier).clearCanvas();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, indent: 16, endIndent: 16),
          const SizedBox(width: 8),

          // Import / Export
          ElevatedButton.icon(
            onPressed: () => _importJson(ref, context),
            icon: const Icon(Icons.upload_file, size: 14),
            label: const Text('Import JSON', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              foregroundColor: textCol,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E75B6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Export...', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            offset: const Offset(0, 40),
            onSelected: (value) {
              if (value == 'json') {
                _exportJson(ref);
              } else if (value == 'png') {
                _exportPng(ref, context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 16, color: Color(0xFF2E75B6)),
                    SizedBox(width: 8),
                    Text('FDM Schema JSON', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'png',
                child: Row(
                  children: [
                    Icon(Icons.image, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text('High-Res PNG Image', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
