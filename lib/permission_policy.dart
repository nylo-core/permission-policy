library permission_policy;

import 'package:nylo_support/helpers/helper.dart';
import 'package:permission_policy/typedefs.dart';
export 'package:permission_policy/typedefs.dart';
export 'package:permission_policy/widgets/permission_view.dart';
export 'package:permission_policy/widgets/role_selector_widget.dart';
export 'package:permission_policy/widgets/role_view_widget.dart';
export 'package:permission_policy/widgets/user_role_widget.dart';
export 'package:permission_policy/widgets/user_permissions_widget.dart';

/// Permission policy is a simple way to manage permissions for your app.
class PermissionPolicy {
  /// The key used to store the role in the storage
  static String storageKey = "PERMISSION_POLICY";

  /// Private constructor for PermissionPolicy
  PermissionPolicy._privateConstructor();

  /// The singleton instance of PermissionPolicy
  static final PermissionPolicy instance =
      PermissionPolicy._privateConstructor();

  /// The roles and permissions for your app.
  RoleAndPermissions _roleAndPermissions = {};

  /// Adds roles to Permission policy
  addRoles(RoleAndPermissions roles) {
    _roleAndPermissions = roles;
  }

  /// Get all the assignable roles
  List<String> assignableRoles() {
    return _roleAndPermissions.keys.toList();
  }

  /// finds all the permissions for a role
  findPermissionsForRole(String role) {
    if (!_roleAndPermissions.containsKey(role)) {
      throw Exception(
          'Role does not exist. Please ensure you have added the role using the "PermissionPolicy.instance.addRoles()" method.');
    }
    return _roleAndPermissions[role];
  }

  /// Assigns a new role to a user
  static giveRole(String role) async {
    await NyStorage.store(storageKey, role);
  }

  /// Checks if the user has a [permission]
  static Future<bool> hasPermission(String permission) async {
    String role = await PermissionPolicy.getRole();
    if (role.isEmpty) {
      return false;
    }
    List<String> permissions =
        PermissionPolicy.instance.findPermissionsForRole(role);

    if (!permissions.contains(role)) {
      return false;
    }
    return true;
  }

  /// Removes a role from a user
  static removeRole() async {
    await NyStorage.delete(storageKey);
  }

  /// Get all role for a user
  static Future<String> getRole() async {
    return await NyStorage.read(storageKey) ?? "";
  }
}
