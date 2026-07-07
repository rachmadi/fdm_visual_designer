import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/metamodel.dart';
import '../../core/state.dart';

class SidebarLeft extends ConsumerStatefulWidget {
  const SidebarLeft({super.key});

  @override
  ConsumerState<SidebarLeft> createState() => _SidebarLeftState();
}

class _SidebarLeftState extends ConsumerState<SidebarLeft> {
  String? _selectedSourceNodeId;
  String? _selectedSourcePropKey;
  EdgeType _selectedEdgeType = EdgeType.hierarchy;
  String? _selectedTargetNodeId;
  bool _isOneToMany = false;
  final TextEditingController _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
  void _createNode(NodeType type) {
    final rand = math.Random();
    final existingNodes = ref.read(diagramProvider).nodes;
    final count = existingNodes.length;

    // Grid-based spawn to avoid overlap.
    // Layout: 4 columns, rows grow downward. Each cell is 280x200px.
    // Structural nodes spawn in left half, Entity nodes in right half.
    const double baseX = 1200.0;
    const double baseY = 1300.0;
    const double cellW = 280.0;
    const double cellH = 220.0;
    const int cols = 4;

    final col = count % cols;
    final row = count ~/ cols;

    // Add slight random jitter (±20px) so nodes don't line up perfectly
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


  void _createBoundary() {
    final rand = math.Random();
    final id = 'boundary_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(1000000)}';
    final rect = Rect.fromLTWH(1350.0 + rand.nextInt(50), 1350.0 + rand.nextInt(50), 300, 250);
    
    final boundary = SecurityBoundary(
      id: id,
      accessLevel: 'public',
      enclosedNodeIds: [],
      rect: rect,
    );

    ref.read(diagramProvider.notifier).addBoundary(boundary);
  }

  void _connectNodes() {
    if (_selectedSourceNodeId == null || _selectedTargetNodeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select source and target nodes.')),
      );
      return;
    }

    if (_selectedSourceNodeId == _selectedTargetNodeId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and target nodes must be different.')),
      );
      return;
    }

    final rand = math.Random();
    final id = 'edge_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(1000000)}';
    final edge = FDMEdge(
      id: id,
      type: _selectedEdgeType,
      sourceNodeId: _selectedSourceNodeId!,
      sourcePropertyKey: _selectedEdgeType == EdgeType.hierarchy ? null : _selectedSourcePropKey,
      targetNodeId: _selectedTargetNodeId!,
      isOneToMany: _isOneToMany,
      label: _selectedEdgeType == EdgeType.denormalization ? _labelController.text : null,
    );

    ref.read(diagramProvider.notifier).addEdge(edge);
    // Reset relation builder state
    setState(() {
      _selectedSourcePropKey = null;
      _labelController.clear();
      _isOneToMany = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection created successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagramProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final sidebarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final sectionBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textCol = isDark ? Colors.white : const Color(0xFF1E293B);

    final sourceNode = state.nodes.any((n) => n.id == _selectedSourceNodeId)
        ? state.nodes.firstWhere((n) => n.id == _selectedSourceNodeId)
        : (state.nodes.isNotEmpty ? state.nodes.first : null);
    final sourceProps = (_selectedSourceNodeId != null && sourceNode != null) ? sourceNode.properties : <PropertyNode>[];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Palette section
            Text(
              'NODE PALETTE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textCol.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _createNode(NodeType.structural),
              icon: const Icon(Icons.create_new_folder, size: 16),
              label: const Text('Add Structural Node'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBF4FF),
                foregroundColor: const Color(0xFF1A3A5C),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Color(0xFF2E75B6)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _createNode(NodeType.entity),
              icon: const Icon(Icons.note_add, size: 16),
              label: const Text('Add Entity Node'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E75B6),
                foregroundColor: Colors.white,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _createBoundary,
              icon: const Icon(Icons.security, size: 16),
              label: const Text('Add Security Boundary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5),
                foregroundColor: isDark ? Colors.green.shade100 : const Color(0xFF065F46),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: isDark ? const Color(0xFF047857) : const Color(0xFF34D399)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Relation Builder section
            Text(
              'RELATION BUILDER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textCol.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (state.isConnecting) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: Color(0xFFD97706), size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Click Target Node on Canvas',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connecting from: ${state.nodes.any((n) => n.id == state.pendingSourceNodeId) ? state.nodes.firstWhere((n) => n.id == state.pendingSourceNodeId).name : "Unknown"}'
                      '${state.pendingSourcePropertyKey != null ? " .${state.pendingSourcePropertyKey}" : ""}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.read(diagramProvider.notifier).cancelConnection(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        minimumSize: const Size(0, 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Cancel Connection', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: textCol.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Click any circular handle on the canvas nodes to link them directly!',
                        style: TextStyle(fontSize: 10, color: textCol.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Source Dropdown
                  const Text('Source Node:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedSourceNodeId,
                    hint: const Text('Select Source', style: TextStyle(fontSize: 12)),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    items: state.nodes.map((node) {
                      return DropdownMenuItem<String>(
                        value: node.id,
                        child: Text('${node.name} (${node.type == NodeType.structural ? "Structural" : "Entity"})', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSourceNodeId = val;
                        _selectedSourcePropKey = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // If not hierarchy edge, show property selector
                  if (_selectedEdgeType != EdgeType.hierarchy && _selectedSourceNodeId != null && sourceNode != null && sourceNode.type == NodeType.entity) ...[
                    const Text('Source Property:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedSourcePropKey,
                      hint: const Text('Select Property', style: TextStyle(fontSize: 12)),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                      ),
                      items: sourceProps.map((prop) {
                        return DropdownMenuItem<String>(
                          value: prop.key,
                          child: Text('${prop.key}: ${prop.dataType.nameString}', style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSourcePropKey = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Relationship Type Selector
                  const Text('Relation Type:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<EdgeType>(
                    value: _selectedEdgeType,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: EdgeType.hierarchy,
                        child: Text('Hierarchy (SN ⇄ EN)', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: EdgeType.referencing,
                        child: Text('Referencing (Pointer)', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: EdgeType.denormalization,
                        child: Text('Denormalization (Sync)', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedEdgeType = val ?? EdgeType.hierarchy;
                        _selectedSourcePropKey = null;
                      });
                      ref.read(diagramProvider.notifier).setConnectionMode(val ?? EdgeType.hierarchy);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Target Dropdown
                  const Text('Target Node:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedTargetNodeId,
                    hint: const Text('Select Target', style: TextStyle(fontSize: 12)),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    items: state.nodes.map((node) {
                      return DropdownMenuItem<String>(
                        value: node.id,
                        child: Text('${node.name} (${node.type == NodeType.structural ? "Structural" : "Entity"})', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedTargetNodeId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Specific settings based on relation type
                  if (_selectedEdgeType == EdgeType.referencing) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: _isOneToMany,
                          onChanged: (val) {
                            setState(() {
                              _isOneToMany = val ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'One-to-Many (*) Cardinality',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (_selectedEdgeType == EdgeType.denormalization) ...[
                    const Text('Label (Replication sync path):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _labelController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'e.g. sender_name',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  ElevatedButton(
                    onPressed: _connectNodes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      foregroundColor: textCol,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Connect Nodes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              'KEYBOARD SHORTCUTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textCol.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildShortcutRow('Undo Action', ['Ctrl', '+', 'Z'], isDark, textCol),
                  _buildShortcutRow('Redo Action', ['Ctrl', '+', 'Shift', '+', 'Z'], isDark, textCol),
                  _buildShortcutRow('Toggle Dark Theme', ['Ctrl', '+', 'Shift', '+', 'D'], isDark, textCol),
                  _buildShortcutRow('Delete Selected', ['Del'], isDark, textCol),
                  _buildShortcutRow('Add Structural Node', ['S'], isDark, textCol),
                  _buildShortcutRow('Add Entity Node', ['E'], isDark, textCol),
                  _buildShortcutRow('Toggle Validation', ['V'], isDark, textCol),
                  _buildShortcutRow('Cancel / Deselect', ['Esc'], isDark, textCol),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyCap(String key, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        key,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String description, List<String> keys, bool isDark, Color textCol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 10, color: textCol.withOpacity(0.8)),
            ),
          ),
          Wrap(
            spacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: keys.map((key) {
              if (key == '+') {
                return Text('+', style: TextStyle(fontSize: 9, color: textCol.withOpacity(0.5)));
              }
              return _buildKeyCap(key, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
