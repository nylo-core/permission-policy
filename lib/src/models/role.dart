/// Represents a role in the permission system
class Role {
  /// The unique identifier for this role
  final String id;

  /// Human-readable name for this role
  final String name;

  /// Optional description of this role
  final String? description;

  /// Priority level (higher values = more important)
  final int priority;

  /// Permissions directly assigned to this role
  final List<String> permissions;

  /// Parent roles that this role inherits from
  final List<String> inheritsFrom;

  /// Whether this role can be assigned to users
  final bool isAssignable;

  /// Whether this role is a system role (cannot be deleted)
  final bool isSystem;

  /// Additional metadata for this role
  final Map<String, dynamic> metadata;

  const Role({
    required this.id,
    required this.name,
    this.description,
    this.priority = 0,
    this.permissions = const [],
    this.inheritsFrom = const [],
    this.isAssignable = true,
    this.isSystem = false,
    this.metadata = const {},
  });

  /// Creates a Role from a map
  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      priority: map['priority'] as int? ?? 0,
      permissions: List<String>.from(map['permissions'] ?? []),
      inheritsFrom: List<String>.from(map['inheritsFrom'] ?? []),
      isAssignable: map['isAssignable'] as bool? ?? true,
      isSystem: map['isSystem'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Converts this Role to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'permissions': permissions,
      'inheritsFrom': inheritsFrom,
      'isAssignable': isAssignable,
      'isSystem': isSystem,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Role(id: $id, name: $name)';

  /// Creates a copy of this role with updated values
  Role copyWith({
    String? id,
    String? name,
    String? description,
    int? priority,
    List<String>? permissions,
    List<String>? inheritsFrom,
    bool? isAssignable,
    bool? isSystem,
    Map<String, dynamic>? metadata,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      permissions: permissions ?? this.permissions,
      inheritsFrom: inheritsFrom ?? this.inheritsFrom,
      isAssignable: isAssignable ?? this.isAssignable,
      isSystem: isSystem ?? this.isSystem,
      metadata: metadata ?? this.metadata,
    );
  }
}
