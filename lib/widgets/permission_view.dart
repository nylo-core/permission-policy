import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/ny_future_builder.dart';
import 'package:permission_policy/permission_policy.dart';

/// PermissionView is a widget that shows a child widget if the user has a
/// permission.
/// Example:
/// ```dart
/// PermissionView(
///  permissions: ["create_user"],
///  child: Text("Create User"),
/// )
/// ```
class PermissionView extends StatelessWidget {
  const PermissionView(
      {Key? key, required this.child, required this.permissions, this.loading})
      : super(key: key);

  final List<String> permissions;
  final Widget Function()? loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NyFutureBuilder(
        future: PermissionPolicy.getRole(),
        child: (context, role) {
          if (role == null || role == "") {
            return const SizedBox.shrink();
          }
          if (role.toLowerCase() == "admin") {
            return child;
          }
          List<String> userPermissions =
              PermissionPolicy.instance.findPermissionsForRole(role);

          for (var userPermission in userPermissions) {
            if (permissions.contains(userPermission)) {
              return child;
            }
          }
          return const SizedBox.shrink();
        },
        loading: loading == null ? const SizedBox.shrink() : loading!());
  }
}
