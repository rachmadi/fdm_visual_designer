import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/metamodel.dart';
import '../../core/state.dart';

class EntityNodeWidget extends ConsumerWidget {
  final FDMNode node;

  const EntityNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNodeId = ref.watch(diagramProvider.select((s) => s.selectedNodeId));
    final isSelected = selectedNodeId == node.id;

    final validationResults = ref.watch(diagramProvider.select((s) => s.validationResults));
    final nodeErrors = validationResults.where((r) => r.targetNodeId == node.id && r.severity == 'error').toList();
    final nodeWarnings = validationResults.where((r) => r.targetNodeId == node.id && r.severity == 'warning').toList();

    const Color primaryCol = Color(0xFF2E75B6);
    const Color textDarkCol = Color(0xFF1A3A5C);

    final borderCol = isSelected ? Colors.amber.shade700 : primaryCol;

    return GestureDetector(
      onTap: () {
        ref.read(diagramProvider.notifier).selectNode(node.id);
      },
      onPanUpdate: (details) {
        final notifier = ref.read(diagramProvider.notifier);
        notifier.updateNodePosition(node.id, node.position + details.delta);
      },
      onPanEnd: (_) {
        ref.read(diagramProvider.notifier).finishDragging();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderCol, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    decoration: const BoxDecoration(
                      color: primaryCol,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            node.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (node.isHighFrequency)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on, size: 10, color: Color(0xFF991B1B)),
                                SizedBox(width: 2),
                                Text(
                                  '>1/s',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Path label just below header
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      node.path,
                      style: TextStyle(
                        fontSize: 9,
                        color: textDarkCol.withOpacity(0.6),
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: primaryCol),
                  // Properties List Body
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: node.properties.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'No properties defined',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: textDarkCol.withOpacity(0.4),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(node.properties.length, (index) {
                              final prop = node.properties[index];
                              final isComplex = prop.dataType == DataType.array || prop.dataType == DataType.map;
                              
                              final propWidget = Container(
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: isComplex
                                    ? BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFE07B00)),
                                      )
                                    : null,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 11, color: textDarkCol),
                                          children: [
                                            TextSpan(
                                              text: '${prop.key}: ',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            TextSpan(
                                              text: _getTypeString(prop),
                                              style: TextStyle(
                                                color: isComplex 
                                                    ? const Color(0xFFE07B00) 
                                                    : textDarkCol.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (prop.isUnbounded && isComplex)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(color: const Color(0xFFE07B00)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.warning, size: 8, color: Color(0xFF92400E)),
                                            SizedBox(width: 2),
                                            Text(
                                              '1MB',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );

                              // Each property row has a handle on the right edge
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  propWidget,
                                  // Property connection handle on the right edge
                                  Positioned(
                                    right: -12,
                                    top: 10,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isComplex ? const Color(0xFFE07B00) : primaryCol,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                  ),
                ],
              ),
              // Connection input handle (centered at top)
              Positioned(
                top: -4,
                left: 106,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryCol,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Connection output handle (centered at bottom)
              Positioned(
                bottom: -4,
                left: 106,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryCol,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Error badge in top-right
              if (nodeErrors.isNotEmpty)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Tooltip(
                    message: nodeErrors.map((e) => '[${e.ruleId}] ${e.message}').join('\n'),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                )
              else if (nodeWarnings.isNotEmpty)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Tooltip(
                    message: nodeWarnings.map((e) => '[${e.ruleId}] ${e.message}').join('\n'),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeString(PropertyNode prop) {
    switch (prop.dataType) {
      case DataType.array:
        return '[]array';
      case DataType.map:
        return '{}map';
      default:
        return prop.dataType.nameString;
    }
  }
}
