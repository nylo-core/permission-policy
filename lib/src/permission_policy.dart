import 'package:flutter/foundation.dart';
import 'models/permission.dart';
import 'models/role.dart';
import 'models/permission_result.dart';
import 'services/permission_service.dart';
import 'storage/permission_storage.dart';
import 'storage/default_permission_storage.dart';

/// Main class for managing permissions and roles in your Flutter app
class PermissionPolicy {
  static PermissionPolicy? _instance;
  late final PermissionService _service;

  /// Private constructor
  PermissionPolicy._internal(PermissionStorage storage) {
    _service = PermissionService(storage);
  }

  /// Get the singleton instance
  static PermissionPolicy get instance {
    _instance ??= PermissionPolicy._internal(DefaultPermissionStorage());
    return _instance!;
  }

  /// Initialize with custom storage.
  ///
  /// Replaces the singleton so that [PermissionPolicy.instance] — and every
  /// widget that reads from it (`PermissionGuard`, `PermissionBuilder`,
  /// `RoleSelector`) — is backed by the supplied [storage]. Call this once,
  /// before [initialize], if you need a non-default storage backend.
  static PermissionPolicy createWithStorage(PermissionStorage storage) {
    _instance = PermissionPolicy._internal(storage);
    return _instance!;
  }

  /// Reset the singleton (useful for testing)
  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  /// Initialize the permission system
  Future<void> initialize() async {
    await _service.initialize();
  }

  /// Configure the permission system with permissions and roles
  ///
  /// Example:
  /// ```dart
  /// await PermissionPolicy.instance.configure(
  ///   permissions: [
  ///     Permission(id: 'read_posts', name: 'Read Posts'),
  ///     Permission(id: 'write_posts', name: 'Write Posts'),
  ///     Permission(id: 'delete_posts', name: 'Delete Posts'),
  ///   ],
  ///   roles: [
  ///     Role(id: 'viewer', name: 'Viewer', permissions: ['read_posts']),
  ///     Role(id: 'editor', name: 'Editor', permissions: ['read_posts', 'write_posts']),
  ///     Role(id: 'admin', name: 'Admin', permissions: ['read_posts', 'write_posts', 'delete_posts']),
  ///   ],
  /// );
  /// ```
  Future<void> configure({
    required List<Permission> permissions,
    required List<Role> roles,
  }) async {
    await _service.configure(
      permissions: permissions,
      roles: roles,
    );
  }

  /// Configure with a simple map structure
  ///
  /// Example:
  /// ```dart
  /// await PermissionPolicy.instance.configureSimple({
  ///   'admin': ['read_posts', 'write_posts', 'delete_posts'],
  ///   'editor': ['read_posts', 'write_posts'],
  ///   'viewer': ['read_posts'],
  /// });
  /// ```
  Future<void> configureSimple(
      Map<String, List<String>> rolePermissions) async {
    final permissions = <Permission>[];
    final roles = <Role>[];
    final allPermissionIds = <String>{};

    // Collect all unique permission IDs
    for (final permissionList in rolePermissions.values) {
      allPermissionIds.addAll(permissionList);
    }

    // Create Permission objects
    for (final permissionId in allPermissionIds) {
      permissions.add(Permission(
        id: permissionId,
        name: permissionId.replaceAll('_', ' ').toUpperCase(),
      ));
    }

    // Create Role objects
    for (final entry in rolePermissions.entries) {
      roles.add(Role(
        id: entry.key,
        name: entry.key.replaceAll('_', ' ').toUpperCase(),
        permissions: entry.value,
      ));
    }

    await configure(permissions: permissions, roles: roles);
  }

  /// Give a role to the device
  Future<void> giveRole(String roleId) async {
    await _service.giveRole(roleId);
  }

  /// Remove a role from the device
  Future<void> removeRole(String roleId) async {
    await _service.removeRole(roleId);
  }

  /// Check if the device has a specific role
  Future<bool> hasRole(String roleId) async {
    return await _service.hasRole(roleId);
  }

  /// Check if the device has any of the specified roles
  Future<bool> hasAnyRole(List<String> roleIds) async {
    return await _service.hasAnyRole(roleIds);
  }

  /// Check if the device has all of the specified roles
  Future<bool> hasAllRoles(List<String> roleIds) async {
    return await _service.hasAllRoles(roleIds);
  }

  /// Check if the device has a specific permission
  Future<bool> hasPermission(String permissionId) async {
    final result = await _service.hasPermission(permissionId);
    return result.granted;
  }

  /// Check if the device has any of the specified permissions
  Future<bool> hasAnyPermission(List<String> permissionIds) async {
    final result = await _service.hasAnyPermission(permissionIds);
    return result.granted;
  }

  /// Check if the device has all of the specified permissions
  Future<bool> hasAllPermissions(List<String> permissionIds) async {
    final result = await _service.hasAllPermissions(permissionIds);
    return result.granted;
  }

  /// Get detailed permission check result
  Future<PermissionResult> checkPermission(String permissionId) async {
    return await _service.hasPermission(permissionId);
  }

  /// Get detailed permission check result for any permission
  Future<PermissionResult> checkAnyPermission(
      List<String> permissionIds) async {
    return await _service.hasAnyPermission(permissionIds);
  }

  /// Get detailed permission check result for all permissions
  Future<PermissionResult> checkAllPermissions(
      List<String> permissionIds) async {
    return await _service.hasAllPermissions(permissionIds);
  }

  /// Get all permissions for the device
  Future<Set<String>> getDevicePermissions() async {
    return await _service.getDevicePermissions();
  }

  /// Get all roles assigned to the device
  Future<List<String>> getDeviceRoles() async {
    return await _service.getDeviceRoles();
  }

  /// Get all available permissions
  Future<List<Permission>> getPermissions() async {
    return await _service.getPermissions();
  }

  /// Get all available roles
  Future<List<Role>> getRoles() async {
    return await _service.getRoles();
  }

  /// Get all assignable roles
  Future<List<Role>> getAssignableRoles() async {
    return await _service.getAssignableRoles();
  }

  /// Clear all roles for the device
  Future<void> clearRoles() async {
    await _service.clearRoles();
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _service.clear();
  }
}
