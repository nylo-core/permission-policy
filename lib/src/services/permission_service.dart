import '../models/permission.dart';
import '../models/role.dart';
import '../models/permission_result.dart';
import '../storage/permission_storage.dart';

/// Core service for managing permissions and roles
class PermissionService {
  final PermissionStorage _storage;

  /// Cache for resolved permissions to improve performance
  final Map<String, Set<String>> _permissionCache = {};

  /// Cache invalidation flag
  bool _cacheInvalidated = true;

  PermissionService(this._storage);

  /// Initialize the service
  Future<void> initialize() async {
    await _storage.initialize();
  }

  /// Configure permissions and roles
  Future<void> configure({
    required List<Permission> permissions,
    required List<Role> roles,
  }) async {
    await _storage.storePermissions(permissions);
    await _storage.storeRoles(roles);
    _invalidateCache();
  }

  /// Get all configured permissions
  Future<List<Permission>> getPermissions() async {
    return await _storage.getPermissions();
  }

  /// Get all configured roles
  Future<List<Role>> getRoles() async {
    return await _storage.getRoles();
  }

  /// Get assignable roles (roles that can be assigned)
  Future<List<Role>> getAssignableRoles() async {
    final roles = await getRoles();
    return roles.where((role) => role.isAssignable).toList();
  }

  /// Get the device's assigned role IDs
  Future<List<String>> getDeviceRoles() async {
    return await _storage.getDeviceRoles();
  }

  /// Add a role to the device
  Future<void> giveRole(String roleId) async {
    final roles = await _storage.getDeviceRoles();
    if (!roles.contains(roleId)) {
      roles.add(roleId);
      await _storage.storeDeviceRoles(roles);
      _invalidateCache();
    }
  }

  /// Remove a role from the device
  Future<void> removeRole(String roleId) async {
    final roles = await _storage.getDeviceRoles();
    if (roles.remove(roleId)) {
      await _storage.storeDeviceRoles(roles);
      _invalidateCache();
    }
  }

  /// Clear all device roles
  Future<void> clearRoles() async {
    await _storage.clearDeviceRoles();
    _invalidateCache();
  }

  /// Check if the device has a specific role
  Future<bool> hasRole(String roleId) async {
    final roles = await _storage.getDeviceRoles();
    return roles.contains(roleId);
  }

  /// Check if the device has any of the specified roles
  Future<bool> hasAnyRole(List<String> roleIds) async {
    final roles = await _storage.getDeviceRoles();
    return roleIds.any((roleId) => roles.contains(roleId));
  }

  /// Check if the device has all of the specified roles
  Future<bool> hasAllRoles(List<String> roleIds) async {
    final roles = await _storage.getDeviceRoles();
    return roleIds.every((roleId) => roles.contains(roleId));
  }

  /// Check if the device has a specific permission
  Future<PermissionResult> hasPermission(String permissionId) async {
    final devicePermissions = await _resolveDevicePermissions();
    if (devicePermissions.contains(permissionId)) {
      final deviceRoles = await _storage.getDeviceRoles();
      return PermissionResult.granted(
        reason: 'Permission granted through roles',
        contributingRoles: deviceRoles,
        contributingPermissions: [permissionId],
      );
    }

    return PermissionResult.denied(
      reason: 'Permission not found',
    );
  }

  /// Check if the device has any of the specified permissions
  Future<PermissionResult> hasAnyPermission(
    List<String> permissionIds,
  ) async {
    for (final permissionId in permissionIds) {
      final result = await hasPermission(permissionId);
      if (result.granted) {
        return result;
      }
    }

    return PermissionResult.denied(
      reason: 'None of the required permissions found',
    );
  }

  /// Check if the device has all of the specified permissions
  Future<PermissionResult> hasAllPermissions(
    List<String> permissionIds,
  ) async {
    final contributingRoles = <String>[];
    final contributingPermissions = <String>[];

    for (final permissionId in permissionIds) {
      final result = await hasPermission(permissionId);
      if (!result.granted) {
        return result;
      }
      contributingRoles.addAll(result.contributingRoles);
      contributingPermissions.addAll(result.contributingPermissions);
    }

    return PermissionResult.granted(
      reason: 'All required permissions granted',
      contributingRoles: contributingRoles.toSet().toList(),
      contributingPermissions: contributingPermissions.toSet().toList(),
    );
  }

  /// Get all permissions for the device
  Future<Set<String>> getDevicePermissions() async {
    return await _resolveDevicePermissions();
  }

  /// Resolve all permissions for the device (including inherited permissions)
  Future<Set<String>> _resolveDevicePermissions() async {
    const cacheKey = 'device';

    if (!_cacheInvalidated && _permissionCache.containsKey(cacheKey)) {
      return _permissionCache[cacheKey]!;
    }

    final permissions = <String>{};

    final deviceRoleIds = await _storage.getDeviceRoles();
    final roles = await getRoles();
    final deviceRoles = roles.where((role) => deviceRoleIds.contains(role.id));

    for (final role in deviceRoles) {
      final rolePermissions = await _resolveRolePermissions(role, roles);
      permissions.addAll(rolePermissions);
    }

    _permissionCache[cacheKey] = permissions;
    _cacheInvalidated = false;
    return permissions;
  }

  /// Resolve all permissions for a role (including inherited permissions)
  Future<Set<String>> resolveRolePermissions(
    Role role,
    List<Role> allRoles,
  ) async {
    final permissions = <String>{};
    final visited = <String>{};

    await _resolveRolePermissionsRecursive(
        role, allRoles, permissions, visited);

    return permissions;
  }

  /// Resolve all permissions for a role (including inherited permissions)
  Future<Set<String>> _resolveRolePermissions(
    Role role,
    List<Role> allRoles,
  ) async {
    return await resolveRolePermissions(role, allRoles);
  }

  /// Recursively resolve role permissions with inheritance
  Future<void> _resolveRolePermissionsRecursive(
    Role role,
    List<Role> allRoles,
    Set<String> permissions,
    Set<String> visited,
  ) async {
    if (visited.contains(role.id)) return;
    visited.add(role.id);

    // Add direct permissions
    permissions.addAll(role.permissions);

    // Add inherited permissions
    for (final parentRoleId in role.inheritsFrom) {
      final parentRole =
          allRoles.where((r) => r.id == parentRoleId).firstOrNull;
      if (parentRole != null) {
        await _resolveRolePermissionsRecursive(
            parentRole, allRoles, permissions, visited);
      }
    }

    // Resolve permission inheritance
    final allPermissions = await getPermissions();
    final newPermissions = <String>{};

    for (final permissionId in permissions.toList()) {
      final permission =
          allPermissions.where((p) => p.id == permissionId).firstOrNull;
      if (permission != null) {
        await _resolvePermissionInheritance(
            permission, allPermissions, newPermissions, <String>{});
      }
    }

    permissions.addAll(newPermissions);
  }

  /// Recursively resolve permission inheritance
  Future<void> _resolvePermissionInheritance(
    Permission permission,
    List<Permission> allPermissions,
    Set<String> resolvedPermissions,
    Set<String> visited,
  ) async {
    if (visited.contains(permission.id)) return;
    visited.add(permission.id);

    resolvedPermissions.add(permission.id);

    for (final parentPermissionId in permission.inheritsFrom) {
      final parentPermission =
          allPermissions.where((p) => p.id == parentPermissionId).firstOrNull;
      if (parentPermission != null) {
        await _resolvePermissionInheritance(
          parentPermission,
          allPermissions,
          resolvedPermissions,
          visited,
        );
      }
    }
  }

  /// Clear all data
  Future<void> clear() async {
    await _storage.clear();
    _invalidateCache();
  }

  /// Invalidate permission cache
  void _invalidateCache() {
    _permissionCache.clear();
    _cacheInvalidated = true;
  }
}
