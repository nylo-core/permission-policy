import '../models/permission.dart';
import '../models/role.dart';

/// Abstract interface for permission storage
abstract class PermissionStorage {
  /// Initialize the storage
  Future<void> initialize();

  /// Store permissions
  Future<void> storePermissions(List<Permission> permissions);

  /// Get all permissions
  Future<List<Permission>> getPermissions();

  /// Get a specific permission by ID
  Future<Permission?> getPermission(String id);

  /// Store roles
  Future<void> storeRoles(List<Role> roles);

  /// Get all roles
  Future<List<Role>> getRoles();

  /// Get a specific role by ID
  Future<Role?> getRole(String id);

  /// Store the device's assigned role IDs
  Future<void> storeDeviceRoles(List<String> roleIds);

  /// Get the device's assigned role IDs
  Future<List<String>> getDeviceRoles();

  /// Clear the device's assigned roles
  Future<void> clearDeviceRoles();

  /// Clear all data
  Future<void> clear();
}
