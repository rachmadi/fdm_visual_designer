import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:html' as html; // Used to intercept browser shortcut conflicts
import 'canvas/canvas_view.dart';
import 'ui/toolbar.dart';
import 'ui/sidebar_left.dart';
import 'panels/sidebar_right.dart';
import 'core/metamodel.dart';
import 'core/state.dart';

final GlobalKey globalScreenKey = GlobalKey();

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

void main() {
  // Prevent browser default behaviors for conflicting shortcuts (Ctrl+D, Ctrl+E, Ctrl+L)
  html.window.onKeyDown.listen((html.KeyboardEvent event) {
    final isCtrl = event.ctrlKey || event.metaKey;
    final key = event.key?.toLowerCase();
    if (isCtrl && (key == 'd' || key == 'e' || key == 'l')) {
      event.preventDefault();
    }
  });

  runApp(
    const ProviderScope(
      child: FdmVisualDesignerApp(),
    ),
  );
}

class FdmVisualDesignerApp extends ConsumerWidget {
  const FdmVisualDesignerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FDM Visual Designer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E75B6),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E75B6),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        fontFamily: 'Roboto',
      ),
      themeMode: themeMode,
      home: const WorkspaceScreen(),
    );
  }
}

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    // Register global hardware keyboard event listener to bypass focus tree issues
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // Jangan memicu shortcut jika user sedang fokus menulis di TextField/input text
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null &&
        primaryFocus.context != null &&
        primaryFocus.context!.findAncestorWidgetOfExactType<EditableText>() != null) {
      return false;
    }

    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    final state = ref.read(diagramProvider);
    final notifier = ref.read(diagramProvider.notifier);

    // 1. Undo: Ctrl/Cmd + Z
    if (isCtrl && !isShift && event.logicalKey == LogicalKeyboardKey.keyZ) {
      notifier.undo();
      return true;
    }

    // 2. Redo: Ctrl/Cmd + Shift + Z
    if (isCtrl && isShift && event.logicalKey == LogicalKeyboardKey.keyZ) {
      notifier.redo();
      return true;
    }

    // 3. Toggle Dark/Light Mode: Ctrl/Cmd + Shift + D
    if (isCtrl && isShift && event.logicalKey == LogicalKeyboardKey.keyD) {
      ref.read(themeModeProvider.notifier).toggle();
      return true;
    }

    // 4. Delete/Backspace: Hapus yang dipilih
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (state.selectedNodeId != null) {
        notifier.deleteNode(state.selectedNodeId!);
        return true;
      } else if (state.selectedBoundaryId != null) {
        notifier.deleteBoundary(state.selectedBoundaryId!);
        return true;
      } else if (state.selectedEdgeId != null) {
        notifier.deleteEdge(state.selectedEdgeId!);
        return true;
      }
    }

    // 5. S: Add Structural Node in center viewport/grid
    if (!isCtrl && !isShift && event.logicalKey == LogicalKeyboardKey.keyS) {
      _createNodeViaShortcut(NodeType.structural);
      return true;
    }

    // 6. E: Add Entity Node in center viewport/grid
    if (!isCtrl && !isShift && event.logicalKey == LogicalKeyboardKey.keyE) {
      _createNodeViaShortcut(NodeType.entity);
      return true;
    }

    // 7. V: Toggle Validation Report panel
    if (!isCtrl && !isShift && event.logicalKey == LogicalKeyboardKey.keyV) {
      notifier.toggleValidationReport();
      return true;
    }

    // 8. Escape: Cancel/Deselect
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      notifier.selectNode(null);
      notifier.cancelConnection();
      return true;
    }

    return false;
  }

  void _createNodeViaShortcut(NodeType type) {
    final rand = math.Random();
    final existingNodes = ref.read(diagramProvider).nodes;
    final count = existingNodes.length;

    const double baseX = 1200.0;
    const double baseY = 1300.0;
    const double cellW = 280.0;
    const double cellH = 220.0;
    const int cols = 4;

    final col = count % cols;
    final row = count ~/ cols;

    final jitterX = rand.nextInt(40) - 20;
    final jitterY = rand.nextInt(40) - 20;

    final double spawnX = baseX + col * cellW + jitterX;
    final double spawnY = baseY + row * cellH + jitterY;
    final pos = Offset(spawnX, spawnY);

    final id = 'node_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(1000000)}';
    final name = type == NodeType.structural ? 'new_collection' : 'NewEntity';
    final path = type == NodeType.structural ? '/new_collection' : '/new_collection/\$id';

    final newNode = FDMNode(
      id: id,
      type: type,
      name: name,
      path: path,
      isDynamic: type == NodeType.entity,
      queryVector: QueryVector(),
      position: pos,
    );

    ref.read(diagramProvider.notifier).addNode(newNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: globalScreenKey,
        child: SafeArea(
          child: Column(
            children: [
              // Top Toolbar (full width)
              const Toolbar(),
              
              // Middle section containing SidebarLeft, Canvas, and SidebarRight
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sidebar Left (Node Palette & Connection Builder)
                    const SidebarLeft(),
                    
                    // Canvas (main workspace)
                    const Expanded(
                      child: CanvasView(),
                    ),
                    
                    // Sidebar Right (Properties Editor & Query Vector & Validation Report)
                    const SidebarRight(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
