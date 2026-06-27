import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'canvas/canvas_view.dart';
import 'ui/toolbar.dart';
import 'ui/sidebar_left.dart';
import 'panels/sidebar_right.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FdmVisualDesignerApp(),
    ),
  );
}

class FdmVisualDesignerApp extends StatelessWidget {
  const FdmVisualDesignerApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          background: const Color(0xFF0F172A),
        ),
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.dark, // Defaulting to sleek dark mode for premium aesthetics
      home: const WorkspaceScreen(),
    );
  }
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Toolbar (full width)
            const Toolbar(),
            
            // Middle section containing SidebarLeft, Canvas, and SidebarRight
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SidebarLeft(),
                  const Expanded(
                    child: CanvasView(),
                  ),
                  const SidebarRight(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
