import 'dart:convert';
import 'package:nylo_support/local_storage/local_storage.dart';
import '../models/permission.dart';
import '../models/role.dart';
import 'permission_storage.dart';

/// Default implementation using Nylo's local storage
class DefaultPermissionStorage implements PermissionStorage {
  static const String _permissionsKey = 'permission_policy_v3_permissions';
  static const String _rolesKey = 'permission_policy_v3_roles';
  static const String _deviceRolesKey = 'permission_policy_device_roles';

  @override
  Future<void> initialize() async {
    // No initialization needed for NyStorage
  }

  @override
  Future<void> storePermissions(List<Permission> permissions) async {
    // Clear existing permissions first
    await NyStorage.delete(_permissionsKey);

    // Store each permission as a collection item
    for (final permission in permissions) {
      await NyStorage.addToCollection(_permissionsKey,
          item: jsonEncode(permission.toMap()));
    }
  }

  @override
  Future<List<Permission>> getPermissions() async {
    final data = await NyStorage.readCollection(_permissionsKey);
    if (data.isEmpty) return [];

    return data.map((item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return Permission.fromMap(decoded);
    }).toList();
  }

  @override
  Future<Permission?> getPermission(String id) async {
    final permissions = await getPermissions();
    return permissions.where((p) => p.id == id).firstOrNull;
  }

  @override
  Future<void> storeRoles(List<Role> roles) async {
    // Clear existing roles first
    await NyStorage.delete(_rolesKey);

    // Store each role as a collection item
    for (final role in roles) {
      await NyStorage.addToCollection(_rolesKey,
          item: jsonEncode(role.toMap()));
    }
  }

  @override
  Future<List<Role>> getRoles() async {
    final data = await NyStorage.readCollection(_rolesKey);
    if (data.isEmpty) return [];

    return data.map((item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return Role.fromMap(decoded);
    }).toList();
  }

  @override
  Future<Role?> getRole(String id) async {
    final roles = await getRoles();
    return roles.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<void> storeDeviceRoles(List<String> roleIds) async {
    await NyStorage.save(_deviceRolesKey, jsonEncode(roleIds));
  }

  @override
  Future<List<String>> getDeviceRoles() async {
    final data = await NyStorage.read<String>(_deviceRolesKey);
    if (data == null) return [];

    return List<String>.from(jsonDecode(data));
  }

  @override
  Future<void> clearDeviceRoles() async {
    await NyStorage.delete(_deviceRolesKey);
  }

  @override
  Future<void> clear() async {
    await NyStorage.delete(_permissionsKey);
    await NyStorage.delete(_rolesKey);
    await NyStorage.delete(_deviceRolesKey);
  }
}
