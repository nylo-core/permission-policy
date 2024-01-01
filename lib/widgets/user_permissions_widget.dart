import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/widgets/ny_future_builder.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:permission_policy/permission_policy.dart';

/// UserPermissions is a widget that shows the permissions for the current user.
class UserPermissions extends StatefulWidget {
  const UserPermissions({super.key});

  static String state = "user_permissions";

  @override
  createState() => _UserPermissionsState();
}

class _UserPermissionsState extends NyState<UserPermissions> {
  _UserPermissionsState() {
    stateName = UserPermissions.state;
  }

  @override
  stateUpdated(dynamic data) async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      color: Colors.black12,
      child: Center(
        child: NyFutureBuilder(
          future: PermissionPolicy.getRoles(),
          child: (context, roles) {
            if (roles == null || roles.isEmpty) {
              return const SizedBox.shrink();
            }

            List<String> permissions = [];
            for (var role in roles) {
              List<String> allPermissionsForRole =
                  PermissionPolicy.instance.findPermissionsForRole(role);
              permissions.addAll(allPermissionsForRole);
            }

            return Text(
              permissions.join(", ").toString(),
              textAlign: TextAlign.center,
            ).fontWeightBold();
          },
          loading: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
