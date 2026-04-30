/// Result of a permission check operation
class PermissionResult {
  /// Whether the permission was granted
  final bool granted;

  /// Reason for the result (useful for debugging and auditing)
  final String? reason;

  /// Roles that contributed to this result
  final List<String> contributingRoles;

  /// Permissions that contributed to this result
  final List<String> contributingPermissions;

  const PermissionResult({
    required this.granted,
    this.reason,
    this.contributingRoles = const [],
    this.contributingPermissions = const [],
  });

  /// Creates a granted permission result
  factory PermissionResult.granted({
    String? reason,
    List<String> contributingRoles = const [],
    List<String> contributingPermissions = const [],
  }) {
    return PermissionResult(
      granted: true,
      reason: reason ?? 'Permission granted',
      contributingRoles: contributingRoles,
      contributingPermissions: contributingPermissions,
    );
  }

  /// Creates a denied permission result
  factory PermissionResult.denied({
    String? reason,
    List<String> contributingRoles = const [],
    List<String> contributingPermissions = const [],
  }) {
    return PermissionResult(
      granted: false,
      reason: reason ?? 'Permission denied',
      contributingRoles: contributingRoles,
      contributingPermissions: contributingPermissions,
    );
  }

  @override
  String toString() => 'PermissionResult(granted: $granted, reason: $reason)';

  /// Creates a copy of this result with updated values
  PermissionResult copyWith({
    bool? granted,
    String? reason,
    List<String>? contributingRoles,
    List<String>? contributingPermissions,
  }) {
    return PermissionResult(
      granted: granted ?? this.granted,
      reason: reason ?? this.reason,
      contributingRoles: contributingRoles ?? this.contributingRoles,
      contributingPermissions:
          contributingPermissions ?? this.contributingPermissions,
    );
  }
}
