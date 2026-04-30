import 'dart:convert';

/// Represents a single permission in the system
class Permission {
  /// The unique identifier for this permission
  final String id;

  /// Human-readable name for this permission
  final String name;

  /// Optional description of what this permission allows
  final String? description;

  /// Category or group this permission belongs to
  final String? category;

  /// Priority level (higher values = more important)
  final int priority;

  /// Parent permissions that this permission inherits from
  final List<String> inheritsFrom;

  /// Additional metadata for this permission
  final Map<String, dynamic> metadata;

  const Permission({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.priority = 0,
    this.inheritsFrom = const [],
    this.metadata = const {},
  });

  /// Creates a Permission from a map
  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String?,
      priority: map['priority'] as int? ?? 0,
      inheritsFrom: List<String>.from(map['inheritsFrom'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Converts this Permission to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'priority': priority,
      'inheritsFrom': inheritsFrom,
      'metadata': metadata,
    };
  }

  /// Creates a Permission from JSON
  factory Permission.fromJson(String json) {
    return Permission.fromMap(
      Map<String, dynamic>.from(jsonDecode(json)),
    );
  }

  /// Converts this Permission to JSON
  String toJson() => jsonEncode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Permission(id: $id, name: $name)';

  /// Creates a copy of this permission with updated values
  Permission copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? priority,
    List<String>? inheritsFrom,
    Map<String, dynamic>? metadata,
  }) {
    return Permission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      inheritsFrom: inheritsFrom ?? this.inheritsFrom,
      metadata: metadata ?? this.metadata,
    );
  }
}
