import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/widgets/ny_future_builder.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:permission_policy/permission_policy.dart';

/// UserRole is a widget that shows the role for the current user.
class UserRole extends StatefulWidget {
  const UserRole({Key? key}) : super(key: key);

  static String state = "user_role";

  @override
  _UserRoleState createState() => _UserRoleState();
}

class _UserRoleState extends NyState<UserRole> {
  _UserRoleState() {
    stateName = UserRole.state;
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
          future: PermissionPolicy.getRole(),
          child: (context, role) {
            if (role == null) {
              return const SizedBox.shrink();
            }
            return Text(
              role,
              textAlign: TextAlign.center,
            ).fontWeightBold();
          },
          loading: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
