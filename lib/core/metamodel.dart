import 'dart:ui';

enum NodeType {
  structural,
  entity,
}

enum DataType {
  string,
  number,
  boolean,
  timestamp,
  geopoint,
  reference,
  array,
  map,
  nullValue,
}

extension DataTypeExtension on DataType {
  String get nameString {
    switch (this) {
      case DataType.string:
        return 'string';
      case DataType.number:
        return 'number';
      case DataType.boolean:
        return 'boolean';
      case DataType.timestamp:
        return 'timestamp';
      case DataType.geopoint:
        return 'geopoint';
      case DataType.reference:
        return 'reference';
      case DataType.array:
        return 'array';
      case DataType.map:
        return 'map';
      case DataType.nullValue:
        return 'null';
    }
  }

  static DataType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'string':
        return DataType.string;
      case 'number':
        return DataType.number;
      case 'boolean':
        return DataType.boolean;
      case 'timestamp':
        return DataType.timestamp;
      case 'geopoint':
        return DataType.geopoint;
      case 'reference':
        return DataType.reference;
      case 'array':
        return DataType.array;
      case 'map':
        return DataType.map;
      default:
        return DataType.nullValue;
    }
  }
}

class PropertyNode {
  final String key;
  final DataType dataType;
  final bool isUnbounded;
  final bool isReferencing;

  PropertyNode({
    required this.key,
    required this.dataType,
    this.isUnbounded = false,
    this.isReferencing = false,
  });

  PropertyNode copyWith({
    String? key,
    DataType? dataType,
    bool? isUnbounded,
    bool? isReferencing,
  }) {
    return PropertyNode(
      key: key ?? this.key,
      dataType: dataType ?? this.dataType,
      isUnbounded: isUnbounded ?? this.isUnbounded,
      isReferencing: isReferencing ?? this.isReferencing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'dataType': dataType.nameString,
      'isUnbounded': isUnbounded,
      'isReferencing': isReferencing,
    };
  }

  factory PropertyNode.fromJson(Map<String, dynamic> json) {
    return PropertyNode(
      key: json['key'] as String? ?? '',
      dataType: DataTypeExtension.fromString(json['dataType'] as String? ?? 'string'),
      isUnbounded: json['isUnbounded'] as bool? ?? false,
      isReferencing: json['isReferencing'] as bool? ?? false,
    );
  }
}

enum EstimatedIndex {
  single,
  composite,
  none,
}

extension EstimatedIndexExtension on EstimatedIndex {
  String get nameString {
    switch (this) {
      case EstimatedIndex.single:
        return 'single';
      case EstimatedIndex.composite:
        return 'composite';
      case EstimatedIndex.none:
        return 'none';
    }
  }

  static EstimatedIndex fromString(String val) {
    switch (val.toLowerCase()) {
      case 'single':
        return EstimatedIndex.single;
      case 'composite':
        return EstimatedIndex.composite;
      default:
        return EstimatedIndex.none;
    }
  }
}

class SortField {
  final String field;
  final String direction; // 'asc' | 'desc'

  SortField({
    required this.field,
    required this.direction,
  });

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'direction': direction,
    };
  }

  factory SortField.fromJson(Map<String, dynamic> json) {
    return SortField(
      field: json['field'] as String? ?? '',
      direction: json['direction'] as String? ?? 'asc',
    );
  }
}

class QueryVector {
  final List<String> filterFields;
  final List<SortField> sortFields;
  final EstimatedIndex estimatedIndexes;

  QueryVector({
    this.filterFields = const [],
    this.sortFields = const [],
    this.estimatedIndexes = EstimatedIndex.none,
  });

  QueryVector copyWith({
    List<String>? filterFields,
    List<SortField>? sortFields,
    EstimatedIndex? estimatedIndexes,
  }) {
    return QueryVector(
      filterFields: filterFields ?? this.filterFields,
      sortFields: sortFields ?? this.sortFields,
      estimatedIndexes: estimatedIndexes ?? this.estimatedIndexes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filterFields': filterFields,
      'sortFields': sortFields.map((e) => e.toJson()).toList(),
      'estimatedIndexes': estimatedIndexes.nameString,
    };
  }

  factory QueryVector.fromJson(Map<String, dynamic> json) {
    final filters = json['filterFields'] as List<dynamic>?;
    final sorts = json['sortFields'] as List<dynamic>?;
    return QueryVector(
      filterFields: filters?.map((e) => e.toString()).toList() ?? [],
      sortFields: sorts?.map((e) => SortField.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      estimatedIndexes: EstimatedIndexExtension.fromString(json['estimatedIndexes'] as String? ?? 'none'),
    );
  }
}

class FDMNode {
  final String id;
  final NodeType type;
  final String name;
  final String path;
  final bool isDynamic;
  final bool isHighFrequency;
  final List<PropertyNode> properties;
  final QueryVector queryVector;
  final Offset position;

  FDMNode({
    required this.id,
    required this.type,
    required this.name,
    required this.path,
    this.isDynamic = false,
    this.isHighFrequency = false,
    this.properties = const [],
    required this.queryVector,
    required this.position,
  });

  FDMNode copyWith({
    String? id,
    NodeType? type,
    String? name,
    String? path,
    bool? isDynamic,
    bool? isHighFrequency,
    List<PropertyNode>? properties,
    QueryVector? queryVector,
    Offset? position,
  }) {
    return FDMNode(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      path: path ?? this.path,
      isDynamic: isDynamic ?? this.isDynamic,
      isHighFrequency: isHighFrequency ?? this.isHighFrequency,
      properties: properties ?? this.properties,
      queryVector: queryVector ?? this.queryVector,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == NodeType.structural ? 'structural' : 'entity',
      'name': name,
      'path': path,
      'isDynamic': isDynamic,
      'isHighFrequency': isHighFrequency,
      'properties': properties.map((e) => e.toJson()).toList(),
      'queryVector': queryVector.toJson(),
      'position': {'x': position.dx, 'y': position.dy},
    };
  }

  factory FDMNode.fromJson(Map<String, dynamic> json) {
    final posJson = json['position'] as Map<dynamic, dynamic>?;
    final typeStr = json['type'] as String? ?? 'entity';
    final x = posJson != null ? (posJson['x'] as num?)?.toDouble() ?? 0.0 : 0.0;
    final y = posJson != null ? (posJson['y'] as num?)?.toDouble() ?? 0.0 : 0.0;
    
    final props = json['properties'] as List<dynamic>?;
    final qv = json['queryVector'] as Map<dynamic, dynamic>?;

    return FDMNode(
      id: json['id'] as String? ?? '',
      type: typeStr == 'structural' ? NodeType.structural : NodeType.entity,
      name: json['name'] as String? ?? 'Unnamed',
      path: json['path'] as String? ?? '',
      isDynamic: json['isDynamic'] as bool? ?? false,
      isHighFrequency: json['isHighFrequency'] as bool? ?? false,
      properties: props?.map((e) => PropertyNode.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      queryVector: qv != null ? QueryVector.fromJson(Map<String, dynamic>.from(qv)) : QueryVector(),
      position: Offset(x, y),
    );
  }
}

enum EdgeType {
  hierarchy,
  referencing,
  denormalization,
}

class FDMEdge {
  final String id;
  final EdgeType type;
  final String sourceNodeId;
  final String? sourcePropertyKey;
  final String targetNodeId;
  final bool isOneToMany;
  final String? label;

  FDMEdge({
    required this.id,
    required this.type,
    required this.sourceNodeId,
    this.sourcePropertyKey,
    required this.targetNodeId,
    this.isOneToMany = false,
    this.label,
  });

  FDMEdge copyWith({
    String? id,
    EdgeType? type,
    String? sourceNodeId,
    String? sourcePropertyKey,
    String? targetNodeId,
    bool? isOneToMany,
    String? label,
  }) {
    return FDMEdge(
      id: id ?? this.id,
      type: type ?? this.type,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      sourcePropertyKey: sourcePropertyKey ?? this.sourcePropertyKey,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      isOneToMany: isOneToMany ?? this.isOneToMany,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == EdgeType.hierarchy 
          ? 'hierarchy' 
          : (type == EdgeType.referencing ? 'referencing' : 'denormalization'),
      'sourceNodeId': sourceNodeId,
      'sourcePropertyKey': sourcePropertyKey,
      'targetNodeId': targetNodeId,
      'isOneToMany': isOneToMany,
      'label': label,
    };
  }

  factory FDMEdge.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'hierarchy';
    EdgeType typeVal = EdgeType.hierarchy;
    if (typeStr == 'referencing') {
      typeVal = EdgeType.referencing;
    } else if (typeStr == 'denormalization') {
      typeVal = EdgeType.denormalization;
    }
    return FDMEdge(
      id: json['id'] as String? ?? '',
      type: typeVal,
      sourceNodeId: json['sourceNodeId'] as String? ?? '',
      sourcePropertyKey: json['sourcePropertyKey'] as String?,
      targetNodeId: json['targetNodeId'] as String? ?? '',
      isOneToMany: json['isOneToMany'] as bool? ?? false,
      label: json['label'] as String?,
    );
  }
}

class SecurityBoundary {
  final String id;
  final String accessLevel; // 'public' | 'private' | 'owner'
  final List<String> enclosedNodeIds;
  final Rect rect;

  SecurityBoundary({
    required this.id,
    required this.accessLevel,
    required this.enclosedNodeIds,
    required this.rect,
  });

  SecurityBoundary copyWith({
    String? id,
    String? accessLevel,
    List<String>? enclosedNodeIds,
    Rect? rect,
  }) {
    return SecurityBoundary(
      id: id ?? this.id,
      accessLevel: accessLevel ?? this.accessLevel,
      enclosedNodeIds: enclosedNodeIds ?? this.enclosedNodeIds,
      rect: rect ?? this.rect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accessLevel': accessLevel,
      'enclosedNodeIds': enclosedNodeIds,
      'bounds': {
        'x': rect.left,
        'y': rect.top,
        'width': rect.width,
        'height': rect.height,
      },
    };
  }

  factory SecurityBoundary.fromJson(Map<String, dynamic> json) {
    final bounds = json['bounds'] as Map<dynamic, dynamic>?;
    final bx = bounds != null ? (bounds['x'] as num?)?.toDouble() ?? 0.0 : 0.0;
    final by = bounds != null ? (bounds['y'] as num?)?.toDouble() ?? 0.0 : 0.0;
    final bw = bounds != null ? (bounds['width'] as num?)?.toDouble() ?? 100.0 : 100.0;
    final bh = bounds != null ? (bounds['height'] as num?)?.toDouble() ?? 100.0 : 100.0;
    
    final nodes = json['enclosedNodeIds'] as List<dynamic>?;
    return SecurityBoundary(
      id: json['id'] as String? ?? '',
      accessLevel: json['accessLevel'] as String? ?? 'public',
      enclosedNodeIds: nodes?.map((e) => e.toString()).toList() ?? [],
      rect: Rect.fromLTWH(bx, by, bw, bh),
    );
  }
}

class ValidationResult {
  final String ruleId;
  final String severity; // 'error' | 'warning'
  final String targetNodeId;
  final String message;

  ValidationResult({
    required this.ruleId,
    required this.severity,
    required this.targetNodeId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'severity': severity,
      'targetNodeId': targetNodeId,
      'message': message,
    };
  }

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      ruleId: json['ruleId'] as String,
      severity: json['severity'] as String,
      targetNodeId: json['targetNodeId'] as String,
      message: json['message'] as String,
    );
  }
}
