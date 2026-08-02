# Permission Policy for Flutter

[![pub package](https://img.shields.io/pub/v/permission_policy.svg)](https://pub.dartlang.org/packages/permission_policy)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible permission management system for Flutter applications with device-level role-based access control (RBAC), hierarchical permissions, and customizable UI components.

## Features

- **Type-safe models** - `Permission` and `Role` with full serialization support
- **Hierarchical permissions** - Permissions can inherit from other permissions
- **Role inheritance** - Roles can inherit permissions from other roles
- **Device-level roles** - Assign roles directly to the device — no user identity required
- **Detailed results** - `PermissionResult` includes the reason, contributing roles, and permissions
- **Pluggable storage** - Implement `PermissionStorage` for any backend (default uses Nylo local storage)
- **Performance caching** - Resolved permissions are cached and automatically invalidated on changes
- **UI components** - `PermissionGuard`, `PermissionBuilder`, and `RoleSelector`

## Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  permission_policy: ^3.2.1
```

Or with the Dart CLI:

```bash
flutter pub add permission_policy
```

### Basic Setup

```dart
import 'package:permission_policy/permission_policy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize
  await PermissionPolicy.instance.initialize();

  // Define permissions and roles
  await PermissionPolicy.instance.configure(
    permissions: [
      Permission(id: 'read_posts', name: 'Read Posts'),
      Permission(id: 'write_posts', name: 'Write Posts'),
      Permission(id: 'delete_posts', name: 'Delete Posts'),
    ],
    roles: [
      Role(id: 'viewer', name: 'Viewer', permissions: ['read_posts']),
      Role(id: 'editor', name: 'Editor', permissions: ['read_posts', 'write_posts']),
      Role(id: 'admin', name: 'Admin', permissions: ['read_posts', 'write_posts', 'delete_posts']),
    ],
  );

  // Assign a role to the device
  await PermissionPolicy.instance.giveRole('editor');

  runApp(MyApp());
}
```

### Simple Configuration

For quick setups you can use a map of role names to permission IDs:

```dart
await PermissionPolicy.instance.configureSimple({
  'admin': ['read_posts', 'write_posts', 'delete_posts'],
  'editor': ['read_posts', 'write_posts'],
  'viewer': ['read_posts'],
});
```

## Core Concepts

### Permissions

A `Permission` represents a specific action or access right. Permissions can inherit from other permissions using `inheritsFrom` - granting a permission automatically includes its parents.

```dart
Permission(
  id: 'edit_profile',
  name: 'Edit Profile',
  description: 'Can edit user profile information',
  category: 'user',
  priority: 2,
  inheritsFrom: ['view_profile'], // Also grants view_profile
  metadata: {'icon': 'edit'},
)
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier (required) |
| `name` | `String` | Human-readable name (required) |
| `description` | `String?` | What this permission allows |
| `category` | `String?` | Grouping category |
| `priority` | `int` | Priority level (default `0`) |
| `inheritsFrom` | `List<String>` | Parent permission IDs to inherit |
| `metadata` | `Map<String, dynamic>` | Custom metadata |

### Roles

A `Role` groups permissions together and can inherit from other roles. Use `isAssignable` to control whether a role appears in selectors, and `isSystem` to mark roles that shouldn't be deleted.

```dart
Role(
  id: 'moderator',
  name: 'Moderator',
  description: 'Can moderate content',
  permissions: ['edit_posts', 'delete_posts'],
  inheritsFrom: ['editor'], // Inherits all editor permissions
  priority: 5,
  isAssignable: true,
  isSystem: false,
)
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier (required) |
| `name` | `String` | Human-readable name (required) |
| `description` | `String?` | Role description |
| `priority` | `int` | Priority level (default `0`) |
| `permissions` | `List<String>` | Directly assigned permission IDs |
| `inheritsFrom` | `List<String>` | Parent role IDs to inherit from |
| `isAssignable` | `bool` | Can be assigned (default `true`) |
| `isSystem` | `bool` | System role flag (default `false`) |
| `metadata` | `Map<String, dynamic>` | Custom metadata |

### Permission Resolution

Permissions are resolved purely through roles. The device has a list of role IDs, and the system resolves all permissions by walking the role and permission inheritance chains.

## API Reference

### Checking Permissions

```dart
final policy = PermissionPolicy.instance;

// Simple boolean check
bool canEdit = await policy.hasPermission('edit_posts');

// Check any of multiple permissions
bool canManage = await policy.hasAnyPermission(['edit_posts', 'delete_posts']);

// Check all permissions are granted
bool fullAccess = await policy.hasAllPermissions(['read_posts', 'write_posts', 'delete_posts']);
```

### Detailed Permission Results

Use `checkPermission` to get a `PermissionResult` with the reason and contributing factors:

```dart
PermissionResult result = await policy.checkPermission('edit_posts');

print(result.granted);                // true or false
print(result.reason);                 // e.g. 'Permission granted through roles'
print(result.contributingRoles);      // e.g. ['editor']
print(result.contributingPermissions); // e.g. ['edit_posts']

// Also available for multiple checks
PermissionResult anyResult = await policy.checkAnyPermission(['edit_posts', 'delete_posts']);
PermissionResult allResult = await policy.checkAllPermissions(['read_posts', 'write_posts']);
```

### Managing Roles

```dart
// Give a role to the device
await policy.giveRole('editor');

// Remove a role
await policy.removeRole('editor');

// Check roles
bool isAdmin = await policy.hasRole('admin');
bool hasEditAccess = await policy.hasAnyRole(['editor', 'admin']);
bool isSuperMod = await policy.hasAllRoles(['moderator', 'admin']);

// Get the device's roles
List<String> roleIds = await policy.getDeviceRoles();

// Get all available roles
List<Role> allRoles = await policy.getRoles();

// Get only assignable roles (isAssignable == true)
List<Role> assignable = await policy.getAssignableRoles();

// Get all resolved permissions for the device
Set<String> allPermissions = await policy.getDevicePermissions();

// Clear all device roles
await policy.clearRoles();

// Clear everything (permissions, roles, and device roles)
await policy.clearAll();
```

## Widgets

### PermissionGuard

Conditionally renders a widget based on permissions or roles. Shows the `child` when granted and the `fallback` when denied.

```dart
PermissionGuard(
  permissions: ['edit_posts'],
  child: ElevatedButton(
    onPressed: () => editPost(),
    child: Text('Edit Post'),
  ),
  fallback: Text('You cannot edit this post'),
)
```

Guard by roles:

```dart
PermissionGuard(
  roles: ['admin', 'moderator'],
  checkType: PermissionCheck.any, // Device needs ANY of these roles
  child: AdminPanel(),
)
```

| Property | Type | Description |
|----------|------|-------------|
| `permissions` | `List<String>?` | Permission IDs to check |
| `roles` | `List<String>?` | Role IDs to check |
| `checkType` | `PermissionCheck` | `.all` (default) or `.any` |
| `child` | `Widget` | Widget shown when granted (required) |
| `fallback` | `Widget?` | Widget shown when denied |
| `loading` | `Widget?` | Widget shown while checking |
| `onPermissionChecked` | `Function(PermissionResult)?` | Callback with result |
| `showDebugInfo` | `bool` | Show debug tooltip in debug mode (default `false`) |

### PermissionBuilder

A builder pattern that gives you full control over the widget tree based on permission state.

```dart
PermissionBuilder(
  permissions: ['delete_posts'],
  builder: (context, hasPermission, result) {
    return ElevatedButton(
      onPressed: hasPermission ? () => deletePost() : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: hasPermission ? Colors.red : Colors.grey,
      ),
      child: Text(hasPermission ? 'Delete' : 'Cannot Delete'),
    );
  },
)
```

| Property | Type | Description |
|----------|------|-------------|
| `permissions` | `List<String>?` | Permission IDs to check |
| `roles` | `List<String>?` | Role IDs to check |
| `checkType` | `PermissionCheck` | `.all` (default) or `.any` |
| `builder` | `Widget Function(BuildContext, bool, PermissionResult?)` | Builder function (required) |
| `loading` | `Widget?` | Widget shown while checking |

### RoleSelector

An interactive role selection widget with three display styles: **list**, **chips**, and **cards**.

```dart
// List style (default)
RoleSelector(
  style: const RoleSelectorStyle.list(),
  onRoleChanged: (role, isSelected) {
    if (isSelected) {
      PermissionPolicy.instance.giveRole(role.id);
    } else {
      PermissionPolicy.instance.removeRole(role.id);
    }
  },
)

// Chip style
RoleSelector(
  style: const RoleSelectorStyle.chips(),
  multiSelect: true,
  showDescriptions: true,
)

// Card grid style
RoleSelector(
  style: const RoleSelectorStyle.cards(
    crossAxisCount: 3,
    selectedColor: Colors.blue,
  ),
)
```

| Property | Type | Description |
|----------|------|-------------|
| `style` | `RoleSelectorStyle` | `.list()`, `.chips()`, or `.cards()` |
| `onRoleChanged` | `Function(Role, bool)?` | Called when a role is toggled |
| `onSelectionComplete` | `Function(List<Role>)?` | Called with all selected roles |
| `multiSelect` | `bool` | Allow multiple selection (default `true`) |
| `initialSelectedRoleIds` | `List<String>` | Pre-selected role IDs |
| `itemBuilder` | `Widget Function(Role, bool, VoidCallback)?` | Custom item builder |
| `roleFilter` | `bool Function(Role)?` | Filter which roles to display |
| `showDescriptions` | `bool` | Show role descriptions (default `true`) |
| `loading` | `Widget?` | Loading widget |
| `emptyWidget` | `Widget?` | Widget when no roles available |

`RoleSelectorStyle` supports customizing `spacing`, `selectedColor`, `backgroundColor`, `titleStyle`, `subtitleStyle`, `scrollPhysics`, and for cards: `crossAxisCount` and `childAspectRatio`.

## Advanced Usage

### Permission Inheritance

Build hierarchical permission structures where higher-level permissions automatically include lower-level ones:

```dart
await PermissionPolicy.instance.configure(
  permissions: [
    Permission(id: 'view_content', name: 'View Content'),
    Permission(
      id: 'edit_content',
      name: 'Edit Content',
      inheritsFrom: ['view_content'], // Includes view
    ),
    Permission(
      id: 'publish_content',
      name: 'Publish Content',
      inheritsFrom: ['edit_content'], // Includes edit AND view
    ),
  ],
  roles: [
    Role(id: 'author', name: 'Author', permissions: ['edit_content']),
    Role(
      id: 'publisher',
      name: 'Publisher',
      inheritsFrom: ['author'], // Inherits author's permissions
      permissions: ['publish_content'],
    ),
  ],
);
```

A device with the `publisher` role will have: `publish_content`, `edit_content`, and `view_content`.

### Custom Storage

Implement `PermissionStorage` to use any backend (database, API, shared preferences, etc.):

```dart
class ApiPermissionStorage implements PermissionStorage {
  @override
  Future<void> initialize() async {
    // Connect to your API
  }

  @override
  Future<void> storePermissions(List<Permission> permissions) async { ... }

  @override
  Future<List<Permission>> getPermissions() async { ... }

  @override
  Future<Permission?> getPermission(String id) async { ... }

  @override
  Future<void> storeRoles(List<Role> roles) async { ... }

  @override
  Future<List<Role>> getRoles() async { ... }

  @override
  Future<Role?> getRole(String id) async { ... }

  @override
  Future<void> storeDeviceRoles(List<String> roleIds) async { ... }

  @override
  Future<List<String>> getDeviceRoles() async { ... }

  @override
  Future<void> clearDeviceRoles() async { ... }

  @override
  Future<void> clear() async { ... }
}

// Use it
final policy = PermissionPolicy.createWithStorage(ApiPermissionStorage());
```

### Testing

Use `PermissionPolicy.reset()` in test setup to start fresh:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_policy/permission_policy.dart';

void main() {
  setUp(() async {
    PermissionPolicy.reset();
    await PermissionPolicy.instance.initialize();

    await PermissionPolicy.instance.configureSimple({
      'admin': ['read', 'write', 'delete'],
      'viewer': ['read'],
    });
  });

  test('editor can write', () async {
    await PermissionPolicy.instance.giveRole('admin');

    expect(await PermissionPolicy.instance.hasPermission('write'), isTrue);
  });

  testWidgets('guard shows content with permission', (tester) async {
    await PermissionPolicy.instance.giveRole('viewer');

    await tester.pumpWidget(
      MaterialApp(
        home: PermissionGuard(
          permissions: const ['read'],
          child: const Text('Content'),
          fallback: const Text('Denied'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Content'), findsOneWidget);
  });
}
```

## Changelog

Please see [CHANGELOG](https://github.com/nylo-core/permission-policy/blob/master/CHANGELOG.md) for more information on what has changed recently.

## Social

- [Twitter](https://twitter.com/nylo_dev)

## Licence

The MIT License (MIT). Please view the [License](https://github.com/nylo-core/permission-policy/blob/main/LICENSE) File for more information.
