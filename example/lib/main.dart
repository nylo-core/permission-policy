import 'package:flutter/material.dart';
import 'package:permission_policy/permission_policy.dart';

void main() {
  // Add roles and permissions to the permission policy
  RoleAndPermissions roleAndPermissions = {
    "Admin": ['admin'],
    "Subscriber": ['can_unsubscribe', 'view_exclusive_content'],
    "User": ['can_subscribe', 'view_content'],
  };
  PermissionPolicy.instance.addRoles(roleAndPermissions);

  runApp(const MyApp());
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
      appBar: AppBar(title: const Text("Permission Policy")),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Text("Your role"),
                  UserRoles(), // This widget will show the users current role

                  Text("Your Permissions"),
                  UserPermissions(), // This widget will show the users current permissions
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 2)),
                  child: Column(
                    children: [
                      const Padding(
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
              const RoleView(
                roles: ['user', 'subscriber'],
                child: Text("The user and subscriber UI"),
              ),
              const PermissionView(
                  permissions: ['can_subscribe'],
                  child: Text("You can subscribe")),
              const PermissionView(
                  permissions: ['can_unsubscribe'],
                  child: Text("You can unsubscribe")),
              const PermissionView(
                  permissions: ['view_content'],
                  child: Text("You can view Content 🚀")),
              const PermissionView(
                  permissions: ['view_exclusive_content'],
                  child: Text("You can view exclusive Content 🎩")),
              const Divider(),
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
