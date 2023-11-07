import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/ny_future_builder.dart';
import 'package:permission_policy/permission_policy.dart';

/// RoleView is a widget that shows a child widget if the user has a
/// role.
/// Example:
/// ```dart
/// RoleView(
/// widgetMap: () => {
///   "admin": Text("Admin"),
///   "user": Text("User"),
/// },
/// defaultView: () => Text("No role assigned"),
/// )
/// ```
class RoleView extends StatelessWidget {
  const RoleView(
      {Key? key, required this.widgetMap, this.defaultView, this.loading})
      : super(key: key);

  final Widget Function()? defaultView;
  final Widget Function()? loading;
  final Map<String, Widget> Function() widgetMap;

  @override
  Widget build(BuildContext context) {
    return NyFutureBuilder(
        future: PermissionPolicy.getRole(),
        child: (context, role) {
          if (role == null || role == "") {
            if (defaultView != null) {
              return defaultView!();
            }
            return const SizedBox.shrink();
          }
          return widgetMap()[role] ?? const SizedBox.shrink();
        },
        loading: loading == null ? const SizedBox.shrink() : loading!());
  }
}
