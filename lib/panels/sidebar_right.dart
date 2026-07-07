import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/metamodel.dart';
import '../../core/state.dart';

class SidebarRight extends ConsumerStatefulWidget {
  const SidebarRight({super.key});

  @override
  ConsumerState<SidebarRight> createState() => _SidebarRightState();
}

class _SidebarRightState extends ConsumerState<SidebarRight> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();
  
  // Property Add Form
  final TextEditingController _propKeyController = TextEditingController();
  DataType _propType = DataType.string;
  bool _propUnbounded = false;
  bool _propReferencing = false;
  bool _showAddForm = false;

  // Property Edit Form
  final TextEditingController _editingPropKeyController = TextEditingController();
  String? _editingPropKey;
  String? _addPropertyError;
  String? _editPropertyError;

  // Query Vector Add Form
  final TextEditingController _filterFieldController = TextEditingController();
  final TextEditingController _sortFieldController = TextEditingController();
  String _sortDirection = 'asc';

  // Query Vector Dropdowns
  String? _selectedFilterField;
  String? _selectedSortField;
  bool _showCustomFilterInput = false;
  bool _showCustomSortInput = false;

  String? _lastSelectedNodeId;

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _propKeyController.dispose();
    _editingPropKeyController.dispose();
    _filterFieldController.dispose();
    _sortFieldController.dispose();
    super.dispose();
  }

  void _syncInputs(FDMNode? node, SecurityBoundary? boundary) {
    if (node != null && node.id != _lastSelectedNodeId) {
      _nameController.text = node.name;
      _pathController.text = node.path;
      _lastSelectedNodeId = node.id;
      // Reset editing states on node change
      _editingPropKey = null;
      _editPropertyError = null;
      _addPropertyError = null;
      _showAddForm = false;

      // Reset query vector states
      _selectedFilterField = null;
      _selectedSortField = null;
      _showCustomFilterInput = false;
      _showCustomSortInput = false;
      _filterFieldController.clear();
      _sortFieldController.clear();
    }
  }

  String? _validatePropertyName(String val, FDMNode node, {String? excludeKey}) {
    final key = val.trim();
    if (key.isEmpty) {
      return 'Nama field tidak boleh kosong';
    }
    final alphaNumericUnderscore = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!alphaNumericUnderscore.hasMatch(key)) {
      return 'Nama field hanya boleh mengandung huruf, angka, dan underscore';
    }
    final startsWithNumber = RegExp(r'^[0-9]');
    if (startsWithNumber.hasMatch(key)) {
      return 'Nama field tidak boleh diawali angka';
    }
    if (key.length > 64) {
      return 'Nama field terlalu panjang (maks. 64 karakter)';
    }
    final isDuplicate = node.properties.any((p) {
      if (excludeKey != null && p.key == excludeKey) return false;
      return p.key == key;
    });
    if (isDuplicate) {
      return 'Nama field sudah ada di node ini';
    }
    return null;
  }

  IconData _getDataTypeIcon(DataType type) {
    switch (type) {
      case DataType.string:
        return Icons.title;
      case DataType.number:
        return Icons.pin;
      case DataType.boolean:
        return Icons.toggle_on;
      case DataType.timestamp:
        return Icons.schedule;
      case DataType.geopoint:
        return Icons.location_on;
      case DataType.reference:
        return Icons.link;
      case DataType.array:
        return Icons.format_list_bulleted;
      case DataType.map:
        return Icons.layers;
      case DataType.nullValue:
        return Icons.remove_circle_outline;
    }
  }

  String _getDataTypeDisplayName(DataType type) {
    return type.displayName;
  }

  void _deletePropertyWithUndo(BuildContext context, String nodeId, PropertyNode prop, int originalIndex) {
    final diagramState = ref.read(diagramProvider);
    final connectedEdges = diagramState.edges.where((e) {
      return e.sourceNodeId == nodeId && e.sourcePropertyKey == prop.key;
    }).toList();

    ref.read(diagramProvider.notifier).deleteProperty(nodeId, prop.key);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Field "${prop.key}" dihapus'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(diagramProvider.notifier).insertPropertyAt(nodeId, originalIndex, prop);
            for (final edge in connectedEdges) {
              ref.read(diagramProvider.notifier).addEdge(edge);
            }
          },
        ),
      ),
    );
  }

  void _addProperty(String nodeId, FDMNode node) {
    final key = _propKeyController.text.trim();
    final err = _validatePropertyName(key, node);
    if (err != null) {
      setState(() {
        _addPropertyError = err;
      });
      return;
    }

    final prop = PropertyNode(
      key: key,
      dataType: _propType,
      isUnbounded: _propUnbounded,
      isReferencing: _propReferencing,
    );

    ref.read(diagramProvider.notifier).addProperty(nodeId, prop);
    
    // Clear form
    _propKeyController.clear();
    setState(() {
      _propType = DataType.string;
      _propUnbounded = false;
      _propReferencing = false;
      _addPropertyError = null;
      _showAddForm = false;
    });
  }

  void _addFilterField(FDMNode node) {
    final String field;
    if (_showCustomFilterInput) {
      field = _filterFieldController.text.trim();
    } else {
      field = _selectedFilterField ?? '';
    }
    if (field.isEmpty) return;

    final currentFilters = List<String>.from(node.queryVector.filterFields);
    if (!currentFilters.contains(field)) {
      currentFilters.add(field);
    }

    final newQv = node.queryVector.copyWith(
      filterFields: currentFilters,
      estimatedIndexes: _estimateIndex(currentFilters, node.queryVector.sortFields),
    );

    ref.read(diagramProvider.notifier).updateQueryVector(node.id, newQv);
    _filterFieldController.clear();
    setState(() {
      _selectedFilterField = null;
      _showCustomFilterInput = false;
    });
  }

  void _addSortField(FDMNode node) {
    final String field;
    if (_showCustomSortInput) {
      field = _sortFieldController.text.trim();
    } else {
      field = _selectedSortField ?? '';
    }
    if (field.isEmpty) return;

    final currentSorts = List<SortField>.from(node.queryVector.sortFields);
    if (!currentSorts.any((s) => s.field == field)) {
      currentSorts.add(SortField(field: field, direction: _sortDirection));
    }

    final newQv = node.queryVector.copyWith(
      sortFields: currentSorts,
      estimatedIndexes: _estimateIndex(node.queryVector.filterFields, currentSorts),
    );

    ref.read(diagramProvider.notifier).updateQueryVector(node.id, newQv);
    _sortFieldController.clear();
    setState(() {
      _selectedSortField = null;
      _showCustomSortInput = false;
    });
  }

  void _removeFilterField(FDMNode node, String field) {
    final currentFilters = node.queryVector.filterFields.where((f) => f != field).toList();
    final newQv = node.queryVector.copyWith(
      filterFields: currentFilters,
      estimatedIndexes: _estimateIndex(currentFilters, node.queryVector.sortFields),
    );
    ref.read(diagramProvider.notifier).updateQueryVector(node.id, newQv);
  }

  void _removeSortField(FDMNode node, String field) {
    final currentSorts = node.queryVector.sortFields.where((s) => s.field != field).toList();
    final newQv = node.queryVector.copyWith(
      sortFields: currentSorts,
      estimatedIndexes: _estimateIndex(node.queryVector.filterFields, currentSorts),
    );
    ref.read(diagramProvider.notifier).updateQueryVector(node.id, newQv);
  }

  EstimatedIndex _estimateIndex(List<String> filters, List<SortField> sorts) {
    // Estimator Logic:
    // - If filterFields > 1, or (filterFields == 1 and sorts is not empty) -> Composite
    // - Else if filterFields == 1 or sorts is not empty -> Single-Field
    // - Else -> None
    if (filters.length > 1 || (filters.isNotEmpty && sorts.isNotEmpty)) {
      return EstimatedIndex.composite;
    } else if (filters.isNotEmpty || sorts.isNotEmpty) {
      return EstimatedIndex.single;
    }
    return EstimatedIndex.none;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagramProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isDark ? Colors.white : const Color(0xFF1E293B);
    final sectionBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    // Find selected items
    FDMNode? selectedNode;
    if (state.selectedNodeId != null) {
      selectedNode = state.nodes.firstWhere((n) => n.id == state.selectedNodeId, orElse: () => state.nodes.first);
      _syncInputs(selectedNode, null);
    }

    SecurityBoundary? selectedBoundary;
    if (state.selectedBoundaryId != null) {
      selectedBoundary = state.boundaries.firstWhere((b) => b.id == state.selectedBoundaryId, orElse: () => state.boundaries.first);
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(left: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Tabs
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Text(
              selectedNode != null 
                  ? 'EDIT NODE PROPERTIES' 
                  : (selectedBoundary != null ? 'EDIT BOUNDARY PROPERTIES' : 'PROPERTIES'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textCol.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(),

          // Main Editor Area (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildEditorContent(selectedNode, selectedBoundary, textCol, sectionBg, isDark),
            ),
          ),

          // Bottom Validation Report Panel
          if (state.showValidationReport) ...[
            const Divider(height: 1),
            Container(
              height: 240,
              color: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
              child: _buildValidationReport(state, textCol, isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditorContent(FDMNode? node, SecurityBoundary? boundary, Color textCol, Color sectionBg, bool isDark) {
    if (node == null && boundary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.mouse, size: 24, color: textCol.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                'Select a node or boundary\non the canvas to edit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textCol.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (boundary != null) {
      // Security Boundary Properties
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Access Level:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: boundary.accessLevel,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'public', child: Text('PUBLIC')),
              DropdownMenuItem(value: 'private', child: Text('PRIVATE/OWNER')),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(diagramProvider.notifier).updateBoundaryProperties(boundary.id, val);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Enclosed Nodes (${boundary.enclosedNodeIds.length}):',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          if (boundary.enclosedNodeIds.isEmpty)
            Text(
              'Resize boundary to enclose nodes.',
              style: TextStyle(fontSize: 11, color: textCol.withOpacity(0.5), fontStyle: FontStyle.italic),
            )
          else
            ...boundary.enclosedNodeIds.map((nodeId) {
              final n = ref.read(diagramProvider).nodes.firstWhere((item) => item.id == nodeId, orElse: () => FDMNode(id: '', type: NodeType.structural, name: 'Unknown', path: '', queryVector: QueryVector(), position: Offset.zero));
              return Card(
                elevation: 0,
                color: sectionBg,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(n.type == NodeType.structural ? Icons.folder : Icons.description, size: 12),
                      const SizedBox(width: 8),
                      Text(n.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
        ],
      );
    }

    // Node Properties
    final isStructural = node!.type == NodeType.structural;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name
        const Text('Node Name:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            ref.read(diagramProvider.notifier).updateNodeNameAndPath(
              node.id,
              val,
              _pathController.text,
              node.isDynamic,
              node.isHighFrequency,
            );
          },
        ),
        const SizedBox(height: 12),

        // Path
        const Text('Jalur/Path:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: _pathController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            ref.read(diagramProvider.notifier).updateNodeNameAndPath(
              node.id,
              _nameController.text,
              val,
              node.isDynamic,
              node.isHighFrequency,
            );
          },
        ),
        const SizedBox(height: 8),

        // Dynamic Path Toggle
        Row(
          children: [
            Checkbox(
              value: node.isDynamic,
              onChanged: (val) {
                ref.read(diagramProvider.notifier).updateNodeNameAndPath(
                  node.id,
                  _nameController.text,
                  _pathController.text,
                  val ?? false,
                  node.isHighFrequency,
                );
              },
            ),
            const Text('Dynamic Path Segment (\$wildcard)', style: TextStyle(fontSize: 11)),
          ],
        ),

        if (!isStructural) ...[
          // High Write Frequency Toggle (R8 limit)
          Row(
            children: [
              Checkbox(
                value: node.isHighFrequency,
                onChanged: (val) {
                  ref.read(diagramProvider.notifier).updateNodeNameAndPath(
                    node.id,
                    _nameController.text,
                    _pathController.text,
                    node.isDynamic,
                    val ?? false,
                  );
                },
              ),
              const Row(
                children: [
                  Text('High Write Frequency ', style: TextStyle(fontSize: 11)),
                  Icon(Icons.flash_on, size: 10, color: Color(0xFFEF4444)),
                  Text(' (>1/s)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                ],
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // Entity specific properties
        if (!isStructural) ...[
          // Properties Editor
          Text('PROPERTIES (${node.properties.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Reorderable list of properties
          if (node.properties.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: node.properties.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(diagramProvider.notifier).reorderProperties(node.id, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final p = node.properties[index];
                final isComplex = p.dataType == DataType.array || p.dataType == DataType.map;
                final isEditing = _editingPropKey == p.key;

                return Card(
                  key: Key(p.key),
                  elevation: 0,
                  color: isEditing
                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                      : (isComplex ? const Color(0xFFFFFBEB) : sectionBg),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: isEditing
                          ? const Color(0xFF2E75B6)
                          : (isComplex ? const Color(0xFFE07B00).withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      key: const Key('inline_edit_prop_name_input'),
                                      controller: _editingPropKeyController,
                                      autofocus: true,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Nama field',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        border: const OutlineInputBorder(),
                                        errorText: _editPropertyError,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _editPropertyError = _validatePropertyName(val, node, excludeKey: p.key);
                                        });
                                      },
                                      onSubmitted: (val) {
                                        final err = _validatePropertyName(val, node, excludeKey: p.key);
                                        if (err == null) {
                                          ref.read(diagramProvider.notifier).updateProperty(
                                            node.id,
                                            p.key,
                                            p.copyWith(key: val.trim()),
                                          );
                                          setState(() {
                                            _editingPropKey = null;
                                            _editPropertyError = null;
                                          });
                                        } else {
                                          setState(() {
                                            _editPropertyError = err;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<DataType>(
                                    value: p.dataType,
                                    items: DataType.values.where((t) => t != DataType.nullValue).map((t) {
                                      return DropdownMenuItem(
                                        value: t,
                                        child: Text(_getDataTypeDisplayName(t), style: const TextStyle(fontSize: 12)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        ref.read(diagramProvider.notifier).updateProperty(
                                          node.id,
                                          p.key,
                                          p.copyWith(
                                            dataType: val,
                                            isUnbounded: (val == DataType.array || val == DataType.map) ? p.isUnbounded : false,
                                            isReferencing: (val == DataType.reference) ? p.isReferencing : false,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (p.dataType == DataType.array || p.dataType == DataType.map)
                                SwitchListTile(
                                  dense: true,
                                  title: const Text('Tidak terbatas', style: TextStyle(fontSize: 11)),
                                  subtitle: const Text('Tambahkan anotasi ⚠️ 1MB', style: TextStyle(fontSize: 10)),
                                  value: p.isUnbounded,
                                  onChanged: (val) {
                                    ref.read(diagramProvider.notifier).updateProperty(
                                      node.id,
                                      p.key,
                                      p.copyWith(isUnbounded: val),
                                    );
                                  },
                                ),
                              if (p.dataType == DataType.reference)
                                SwitchListTile(
                                  dense: true,
                                  title: const Text('Referencing', style: TextStyle(fontSize: 11)),
                                  subtitle: const Text('Hubungkan ke node lain', style: TextStyle(fontSize: 10)),
                                  value: p.isReferencing,
                                  onChanged: (val) {
                                    ref.read(diagramProvider.notifier).updateProperty(
                                      node.id,
                                      p.key,
                                      p.copyWith(isReferencing: val),
                                    );
                                  },
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _editingPropKey = null;
                                        _editPropertyError = null;
                                      });
                                    },
                                    child: const Text('Batal', style: TextStyle(fontSize: 11)),
                                  ),
                                  FilledButton(
                                    key: const Key('inline_edit_prop_save_button'),
                                    onPressed: () {
                                      final val = _editingPropKeyController.text;
                                      final err = _validatePropertyName(val, node, excludeKey: p.key);
                                      if (err == null) {
                                        ref.read(diagramProvider.notifier).updateProperty(
                                          node.id,
                                          p.key,
                                          p.copyWith(key: val.trim()),
                                        );
                                        setState(() {
                                          _editingPropKey = null;
                                          _editPropertyError = null;
                                        });
                                      } else {
                                        setState(() {
                                          _editPropertyError = err;
                                        });
                                      }
                                    },
                                    child: const Text('Simpan', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(_getDataTypeIcon(p.dataType), size: 14, color: isComplex ? const Color(0xFFE07B00) : Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _editingPropKey = p.key;
                                      _editingPropKeyController.text = p.key;
                                      _editPropertyError = null;
                                    });
                                  },
                                  child: Text(
                                    '${p.key}: ${_getDataTypeDisplayName(p.dataType)}${p.isUnbounded ? " (⚠️ 1MB)" : ""}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isComplex ? const Color(0xFF92400E) : textCol,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isComplex)
                                    IconButton(
                                      icon: Icon(
                                        p.isUnbounded ? Icons.warning : Icons.info,
                                        size: 14,
                                        color: p.isUnbounded ? const Color(0xFFE07B00) : Colors.grey,
                                      ),
                                      tooltip: 'Toggle Unbounded Limit',
                                      onPressed: () {
                                        ref.read(diagramProvider.notifier).updateProperty(
                                          node.id,
                                          p.key,
                                          p.copyWith(isUnbounded: !p.isUnbounded),
                                        );
                                      },
                                    ),
                                  IconButton(
                                    key: Key('delete_prop_${p.key}'),
                                    icon: const Icon(Icons.delete, size: 14, color: Color(0xFFEF4444)),
                                    onPressed: () => _deletePropertyWithUndo(context, node.id, p, index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),

          // Add Property trigger button & inline form
          if (!_showAddForm)
            FilledButton.tonalIcon(
              onPressed: () {
                setState(() {
                  _showAddForm = true;
                  _propKeyController.clear();
                  _propType = DataType.string;
                  _propUnbounded = false;
                  _propReferencing = false;
                  _addPropertyError = null;
                });
              },
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Tambah property', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('add_prop_name_input'),
                    controller: _propKeyController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Nama field',
                      hintText: 'mis. createdAt',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      border: const OutlineInputBorder(),
                      errorText: _addPropertyError,
                      prefixIcon: const Icon(Icons.label_outline, size: 14),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _addPropertyError = _validatePropertyName(val, node);
                      });
                    },
                    onSubmitted: (_) => _addProperty(node.id, node),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<DataType>(
                    value: _propType,
                    decoration: const InputDecoration(
                      labelText: 'Tipe data',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    items: DataType.values.where((t) => t != DataType.nullValue).map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(_getDataTypeDisplayName(t), style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _propType = val ?? DataType.string;
                      });
                    },
                  ),
                  if (_propType == DataType.array || _propType == DataType.map) ...[
                    const SizedBox(height: 4),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Tidak terbatas', style: TextStyle(fontSize: 11)),
                      subtitle: const Text('Tambahkan anotasi ⚠️ 1MB', style: TextStyle(fontSize: 10)),
                      value: _propUnbounded,
                      onChanged: (val) {
                        setState(() {
                          _propUnbounded = val;
                        });
                      },
                    ),
                  ],
                  if (_propType == DataType.reference) ...[
                    const SizedBox(height: 4),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Referencing', style: TextStyle(fontSize: 11)),
                      subtitle: const Text('Hubungkan ke node lain', style: TextStyle(fontSize: 10)),
                      value: _propReferencing,
                      onChanged: (val) {
                        setState(() {
                          _propReferencing = val;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAddForm = false;
                            _addPropertyError = null;
                          });
                        },
                        child: const Text('Batal', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: const Key('add_prop_save_button'),
                        onPressed: () => _addProperty(node.id, node),
                        child: const Text('Simpan', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // QUERY VECTOR PANEL (Firestore Access Pattern)
          Text('QUERY VECTOR', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Declare access pattern for this document:',
            style: TextStyle(fontSize: 10, color: textCol.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sectionBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter fields add
                Row(
                  children: [
                    Expanded(
                      child: _showCustomFilterInput
                          ? TextField(
                              controller: _filterFieldController,
                              style: TextStyle(fontSize: 11, color: textCol),
                              decoration: InputDecoration(
                                hintText: 'Custom filter field',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close, size: 14),
                                  onPressed: () {
                                    setState(() {
                                      _showCustomFilterInput = false;
                                      _selectedFilterField = null;
                                    });
                                  },
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedFilterField,
                              decoration: const InputDecoration(
                                labelText: 'Filter field (F)',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(fontSize: 11, color: textCol),
                              items: [
                                ...node.properties.map((p) => DropdownMenuItem(
                                      value: p.key,
                                      child: Text(p.key, style: TextStyle(fontSize: 11, color: textCol)),
                                    )),
                                DropdownMenuItem(
                                  value: '__custom__',
                                  child: Text('-- Custom Field --', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: textCol.withOpacity(0.7))),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == '__custom__') {
                                  setState(() {
                                    _showCustomFilterInput = true;
                                    _filterFieldController.clear();
                                  });
                                } else {
                                  setState(() {
                                    _selectedFilterField = val;
                                  });
                                }
                              },
                            ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 20, color: Color(0xFF2E75B6)),
                      onPressed: () => _addFilterField(node),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Sort fields add
                Row(
                  children: [
                    Expanded(
                      child: _showCustomSortInput
                          ? TextField(
                              controller: _sortFieldController,
                              style: TextStyle(fontSize: 11, color: textCol),
                              decoration: InputDecoration(
                                hintText: 'Custom sort field',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close, size: 14),
                                  onPressed: () {
                                    setState(() {
                                      _showCustomSortInput = false;
                                      _selectedSortField = null;
                                    });
                                  },
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedSortField,
                              decoration: const InputDecoration(
                                labelText: 'Sort field (S)',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(fontSize: 11, color: textCol),
                              items: [
                                ...node.properties.map((p) => DropdownMenuItem(
                                      value: p.key,
                                      child: Text(p.key, style: TextStyle(fontSize: 11, color: textCol)),
                                    )),
                                DropdownMenuItem(
                                  value: '__custom__',
                                  child: Text('-- Custom Field --', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: textCol.withOpacity(0.7))),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == '__custom__') {
                                  setState(() {
                                    _showCustomSortInput = true;
                                    _sortFieldController.clear();
                                  });
                                } else {
                                  setState(() {
                                    _selectedSortField = val;
                                  });
                                }
                              },
                            ),
                    ),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: _sortDirection,
                      items: const [
                        DropdownMenuItem(value: 'asc', child: Text('ASC', style: TextStyle(fontSize: 10))),
                        DropdownMenuItem(value: 'desc', child: Text('DESC', style: TextStyle(fontSize: 10))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _sortDirection = val ?? 'asc';
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 20, color: Color(0xFF2E75B6)),
                      onPressed: () => _addSortField(node),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Display Filters (F)
          if (node.queryVector.filterFields.isNotEmpty) ...[
            const Text('Filters (F):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 4,
              children: node.queryVector.filterFields.map((f) {
                return Chip(
                  padding: EdgeInsets.zero,
                  label: Text('where($f)', style: const TextStyle(fontSize: 10)),
                  onDeleted: () => _removeFilterField(node, f),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
          ],

          // Display Sorts (S)
          if (node.queryVector.sortFields.isNotEmpty) ...[
            const Text('Sorts (S):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 4,
              children: node.queryVector.sortFields.map((s) {
                return Chip(
                  padding: EdgeInsets.zero,
                  label: Text('orderBy(${s.field}, ${s.direction.toUpperCase()})', style: const TextStyle(fontSize: 10)),
                  onDeleted: () => _removeSortField(node, s.field),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
          ],

          // Index Estimate Result
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: node.queryVector.estimatedIndexes == EstimatedIndex.composite
                  ? const Color(0xFFFFF1F2)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: node.queryVector.estimatedIndexes == EstimatedIndex.composite
                    ? const Color(0xFFFECDD3)
                    : const Color(0xFFA7F3D0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  node.queryVector.estimatedIndexes == EstimatedIndex.composite
                      ? Icons.layers
                      : (node.queryVector.estimatedIndexes == EstimatedIndex.single ? Icons.description : Icons.help),
                  size: 14,
                  color: node.queryVector.estimatedIndexes == EstimatedIndex.composite
                      ? const Color(0xFFBE123C)
                      : const Color(0xFF047857),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Index: ${node.queryVector.estimatedIndexes == EstimatedIndex.composite ? "Composite Index Required" : (node.queryVector.estimatedIndexes == EstimatedIndex.single ? "Single-Field Index" : "No indexing needed")}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: node.queryVector.estimatedIndexes == EstimatedIndex.composite
                          ? const Color(0xFFBE123C)
                          : const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Delete Node Button at the bottom
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(diagramProvider.notifier).deleteNode(node.id);
          },
          icon: const Icon(Icons.delete, size: 14),
          label: const Text('Delete Node'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationReport(DiagramState state, Color textCol, bool isDark) {
    final errors = state.validationResults.where((r) => r.severity == 'error').toList();
    final warnings = state.validationResults.where((r) => r.severity == 'warning').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          child: Row(
            children: [
              const Icon(Icons.assignment, size: 14),
              const SizedBox(width: 8),
              const Text(
                'VALIDATION REPORT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: errors.isNotEmpty ? const Color(0xFFEF4444) : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${errors.length} E',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: warnings.isNotEmpty ? const Color(0xFFF59E0B) : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${warnings.length} W',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Report list
        Expanded(
          child: state.validationResults.isEmpty
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'All rules passed! Model is well-formed.',
                        style: TextStyle(fontSize: 11, color: textCol.withOpacity(0.5)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: state.validationResults.length,
                  itemBuilder: (context, index) {
                    final res = state.validationResults[index];
                    final isError = res.severity == 'error';
                    
                    return InkWell(
                      onTap: () {
                        // Focus on node
                        ref.read(diagramProvider.notifier).selectNode(res.targetNodeId);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.15))),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isError ? Icons.warning : Icons.info,
                              color: isError ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '[${res.ruleId}] ${res.message}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isError ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 12, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
