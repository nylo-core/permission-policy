import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:permission_policy/permission_policy.dart';

void main() {
  // Add roles and permissions to the permission policy
  RoleAndPermissions roleAndPermissions = {
    "Admin": ['admin'],
    "Subscriber": ['can_unsubscribe', 'view_exclusive_content'],
    "User": ['can_subcribe', 'view_content'],
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
                  UserRole(), // This widget will show the users current role

                  Text("Your Permissions").fontWeightBold(),
                  UserPermissions(), // This widget will show the users current permissions
                ],
              ),
              Expanded(
                child: RoleSelector(onUpdate: () {
                  setState(() {});
                }),
              ),
              RoleView(
                  widgetMap: () => {
                        "Admin": Text("The Admin UI"),
                        "Subscriber": Text("The Subscriber UI"),
                        "User": Text("The User UI")
                      }),
              PermissionView(
                  child: Text("Join the Pro plan"),
                  permissions: ['can_subscribe']),
              PermissionView(
                  child: Text("Unsubscribe from the Pro plan"),
                  permissions: ['can_unsubscribe']),
              MaterialButton(
                onPressed: () async {
                  await PermissionPolicy.removeRole();
                  setState(() {});
                },
                child: Text("Clear Roles"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
