import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:permission_policy/permission_policy.dart';

void main() {
  // Add roles and permissions to the permission policy
  RoleAndPermissions roleAndPermissions = {
    "Admin": ['admin'],
    "Subscriber": ['can_unsubscribe', 'view_exclusive_content'],
    "User": ['can_subscribe', 'view_content'],
  };
  PermissionPolicy.instance.addRoles(roleAndPermissions);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This is a simple example of how to use the permission policy.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Permission Policy")),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Text("Your role").fontWeightBold(),
                  UserRoles(), // This widget will show the users current role

                  Text("Your Permissions").fontWeightBold(),
                  UserPermissions(), // This widget will show the users current permissions
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 2)),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Select a role"),
                      ),
                      Expanded(
                        child: RoleSelector(onUpdate: () {
                          setState(() {});
                        }),
                      )
                    ],
                  ),
                ),
              ),
              RoleView(
                roles: ['user', 'subscriber'],
                child: Text("The user and subscriber UI"),
              ),
              PermissionView(
                  child: Text("You can subscribe"),
                  permissions: ['can_subscribe']),
              PermissionView(
                  child: Text("You can unsubscribe"),
                  permissions: ['can_unsubscribe']),
              PermissionView(
                  child: Text("You can view Content 🚀"),
                  permissions: ['view_content']),
              PermissionView(
                  child: Text("You can view exclusive Content 🎩"),
                  permissions: ['view_exclusive_content']),
              Divider(),
              ...PermissionPolicy.instance.assignableRoles().map((role) {
                return MaterialButton(
                  onPressed: () async {
                    await PermissionPolicy.removeRole(role);
                    setState(() {});
                  },
                  child: Text("Remove [$role] Role"),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
