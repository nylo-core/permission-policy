library permission_policy;

import 'package:flutter/cupertino.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/nylo.dart';
import 'package:permission_policy/typedefs.dart';
export 'package:permission_policy/typedefs.dart';
export 'package:permission_policy/widgets/permission_view.dart';
export 'package:permission_policy/widgets/role_selector_widget.dart';
export 'package:permission_policy/widgets/role_view_widget.dart';
export 'package:permission_policy/widgets/user_roles_widget.dart';
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
  void addRoles(RoleAndPermissions roles) {
    // Initialize Nylo
    if (!Backpack.instance.isNyloInitialized()) {
      Nylo nylo = Nylo();
      nylo.appLoader = const CupertinoActivityIndicator();
      Backpack.instance.set('nylo', nylo);
    }

    _roleAndPermissions = roles;
  }

  /// Get all the assignable roles
  List<String> assignableRoles() {
    return _roleAndPermissions.keys.toList();
  }

  /// finds all the permissions for a role
  List<String> findPermissionsForRole(String role) {
    if (!_roleAndPermissions.containsKey(role)) {
      throw Exception(
          'Role does not exist. Please ensure you have added the role using the "PermissionPolicy.instance.addRoles()" method.');
    }
    return _roleAndPermissions[role] ?? [];
  }

  /// Wipes all data from the permission data from storage
  static clearRoles() async {
    await NyStorage.delete(PermissionPolicy.storageKey);
  }

  /// Assigns a new role to a user
  static giveRole(String role) async {
    await NyStorage.addToCollection(storageKey,
        item: role, allowDuplicates: false);
  }

  /// Checks if the user has a [role]
  static Future<bool> hasRole(String role) async {
    List<String> rolesFromPermissionPolicy = await PermissionPolicy.getRoles();
    for (String roleFromPermissionPolicy in rolesFromPermissionPolicy) {
      if (roleFromPermissionPolicy == role) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the user has a [permission]
  static Future<bool> hasPermission(String permission) async {
    List<String> roles = await PermissionPolicy.getRoles();
    for (String role in roles) {
      List<String> permissions =
          PermissionPolicy.instance.findPermissionsForRole(role);

      if (permissions.contains(role)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the user has a permissions from all the roles
  /// they've been assigned.
  static Future<bool> containsPermissions(List<String> permissions) async {
    List<String> roles = await PermissionPolicy.getRoles();
    if (roles.map((e) => e.toLowerCase()).toList().contains('admin')) {
      return true;
    }

    for (String role in roles) {
      List<String> permissionsForRole =
          PermissionPolicy.instance.findPermissionsForRole(role);

      for (String permission in permissionsForRole) {
        if (permissions.contains(permission)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Removes a role from a user
  static removeRole(String role) async {
    await NyStorage.deleteValueFromCollection(PermissionPolicy.storageKey,
        value: role);
  }

  /// Get all role for a user
  static Future<List<String>> getRoles() async {
    return await NyStorage.readCollection(storageKey);
  }
}
