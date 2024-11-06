import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/ny_base_state.dart';
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
      {super.key,
      required this.permissions,
      required this.child,
      this.loading});

  final List<String> permissions;
  final Widget? loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NyFutureBuilder(
      future: PermissionPolicy.containsPermissions(permissions),
      child: (context, containsPermissions) {
        if (containsPermissions == null || containsPermissions == false) {
          return const SizedBox.shrink();
        }

        if (containsPermissions == true) {
          return child;
        }

        return const SizedBox.shrink();
      },
      loadingStyle: LoadingStyle.normal(
          child: loading == null ? const SizedBox.shrink() : loading!),
    );
  }
}
