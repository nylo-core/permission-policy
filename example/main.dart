import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:permission_policy/permission_policy.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Policy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Permission Policy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
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

              RoleSelector(onUpdate: () {
                setState(() {

                });
              }),

              RoleView(widgetMap: () => {
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
                  setState(() {
                  });
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
