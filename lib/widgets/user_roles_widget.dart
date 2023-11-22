import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/widgets/ny_future_builder.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:permission_policy/permission_policy.dart';

/// UserRole is a widget that shows the role for the current user.
class UserRoles extends StatefulWidget {
  const UserRoles({Key? key}) : super(key: key);

  static String state = "user_roles";

  @override
  _UserRolesState createState() => _UserRolesState();
}

class _UserRolesState extends NyState<UserRoles> {
  _UserRolesState() {
    stateName = UserRoles.state;
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
            return Text(
              roles.join(", ").toString(),
              textAlign: TextAlign.center,
            ).fontWeightBold();
          },
          loading: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
