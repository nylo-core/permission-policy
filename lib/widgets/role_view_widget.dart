import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/ny_future_builder.dart';
import 'package:permission_policy/permission_policy.dart';

/// RoleView is a widget that shows a child widget if the user has a
/// role.
/// Example:
/// ```dart
/// RoleView(
/// roles: ["user", "subscriber"],
/// defaultView: Text("No role assigned"),
/// child: Text("User or Subscriber"),
/// )
/// ```
class RoleView extends StatelessWidget {
  const RoleView(
      {Key? key,
      required this.roles,
      required this.child,
      this.defaultView,
      this.loading})
      : super(key: key);

  final Widget? loading, defaultView;
  final List<String> roles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NyFutureBuilder(
        future: PermissionPolicy.getRoles(),
        child: (context, roles) {
          if (roles == null || roles.isEmpty) {
            if (defaultView != null) {
              return defaultView!;
            }
            return const SizedBox.shrink();
          }
          for (var role in roles) {
            if (this.roles.contains(role)) {
              return child;
            }
          }
          return const SizedBox.shrink();
        },
        loading: loading == null ? const SizedBox.shrink() : loading!);
  }
}
