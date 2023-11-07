# Role and Permissions for Flutter

[![pub package](https://img.shields.io/pub/v/permission_policy.svg)](https://pub.dartlang.org/packages/permission_policy)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Permission policy helps you manage role and permissions in your Flutter application.
It works on Android, iOS, macOS, linux, windows and web.

## Usage

### Simple to use

``` dart
// Add roles and permissions to the permission policy
RoleAndPermissions roleAndPermissions = {
      "Admin": ['admin'],
      "Sales Manager": ['view_revenue', 'view_apps'],
      "Developer Manager": ['view_apps'],
      "Marketing": ['view_media'],
      "Project Manager": ["edit_projects"]
};
PermissionPolicy.instance.addRoles(roleAndPermissions);
```

``` dart
// Get the users current role
await PermissionPolicy.getRole();
```

``` dart
// Check if a user has a role
await PermissionPolicy.hasRole('Admin');
```

``` dart
// Check if a user has a permission
await PermissionPolicy.hasPermission('view_revenue');
```

``` dart
// Give the user a role
await PermissionPolicy.giveRole("Admin");
```

``` dart
// Remove a role from the user
await PermissionPolicy.removeRole();
```

### Widgets

``` dart
// [UserRole] This widget will show the users current role
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(title: Text("Permission Policy")),
      body: SafeArea(
        child: UserRole() // This widget will show the users current role
      )
  );
}
```

``` dart
// [UserPermissions] This widget will show the users current permissions
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(title: Text("Permission Policy")),
      body: SafeArea(
        child: UserPermissions() // This widget will show the users current permissions
      )
  );
}
```

``` dart
// [UserPermissions] This widget will show the users current permissions
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(title: Text("Permission Policy")),
      body: SafeArea(
        child: RoleSelector(onUpdate: () {
          // onUpdate is called after the user selects a role
        }),
      )
  );
}
```

``` dart
// [RoleView] This widget will display a widget based on the users current role
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(title: Text("Permission Policy")),
      body: SafeArea(
        child: RoleView(
          widgetMap: () => {
            "Admin": Text("The Admin UI"),
            "Subscriber": Text("The Subscriber UI"),
            "User": Text("The User UI")
          }, 
          defaultView: () => Text("The default UI")), // if the user does not have a role, the defaultView will be shown
      )
  );
}
```

``` dart
// [PermissionView] This widget will show a widget if the user has the correct permissions
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(title: Text("Permission Policy")),
      body: SafeArea(
        child: PermissionView(
          child: Text("Join the Pro plan"),
          permissions: ['can_subscribe']
        ),
      )
  );
}
```

## Features

- [x] Add roles and permissions to your Flutter application
- [x] Check if a user has a role
- [x] Check if a user has a permission
- [x] Give a user a role
- [x] Remove a role from a user
- [x] Widgets to show a users current role and permissions

## Getting started

### Installation

Add the following to your `pubspec.yaml` file:

``` yaml

dependencies:
  permission_policy: ^0.1.0

```

or with Dart:

``` bash
dart pub add permission_policy
```

## How to use

The package is very simple to use. You can add roles and permissions to the permission policy and then check if a user has a role or permission.

### Add roles and permissions

``` dart

// Add roles and permissions to the permission policy
RoleAndPermissions roleAndPermissions = {
      "Admin": ['admin'],
      "Subscriber": ['can_unsubscribe', 'view_exclusive_content'],
      "User": ['can_subcribe', 'view_content'],
};
PermissionPolicy.instance.addRoles(roleAndPermissions);

```

You can then check if a user has a role or permission.

``` dart
// Check if a user has a role in your Widget
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:permission_policy/permission_policy.dart';

// Check if a user has a role in your Widget

class PermissionPage extends NyPage {

  static String path = '/permission';

  @override
  Widget build(BuildContext context) {
    print('object');
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
                refreshPage(); // Refresh the page when the user selects a role
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
                  refreshPage();
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
```

If the user has the role of **Admin**, they will be able to see any PermissionView widgets.

Try the [example](/example) app to see how it works.

## Changelog
Please see [CHANGELOG](https://github.com/nylo-core/permission-policy/blob/master/CHANGELOG.md) for more information what has changed recently.

## Social
* [Twitter](https://twitter.com/nylo_dev)

## Licence

The MIT License (MIT). Please view the [License](https://github.com/nylo-core/nylo/blob/5.x/LICENSE) File for more information.
