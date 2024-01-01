import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/ny_list_view.dart';
import 'package:permission_policy/permission_policy.dart';

/// RoleSelector is a widget that shows a list of roles that can be assigned to
/// a user.
class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, this.onUpdate, this.builder});

  final Widget Function(String data)? builder;
  final Function()? onUpdate;

  @override
  Widget build(BuildContext context) {
    return NyListView.separated(
      shrinkWrap: true,
      data: () async => PermissionPolicy.instance.assignableRoles(),
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
      child: (context, role) {
        if (builder != null) {
          return builder!(role);
        }
        return MaterialButton(
            child: Text(role),
            onPressed: () async {
              await PermissionPolicy.giveRole(role);
              if (onUpdate == null) {
                return;
              }
              onUpdate!();
            });
      },
    );
  }
}
