## [3.2.1] - 2026-08-02

### Changed

* Upgraded `nylo_support` dependency to `^7.27.4` (was `^7.24.2`).
* Upgraded `flutter_lints` dev dependency to `^6.0.0` (was `^5.0.0`).
* Refreshed the example app's lockfile to match the updated dependencies.

No public API changes.

## [3.2.0] - 2026-05-12

### Added

* **`PermissionPolicy.instance.getPermissionsForRole(roleId)`** — returns the permissions granted by a given role id, without needing to assign the role to the device. By default, role and permission inheritance are fully resolved; pass `includeInherited: false` to get only the directly declared permissions on the role. Returns an empty set if the role does not exist.

  ```dart
  // Effective permissions for the 'admin' role, inheritance resolved
  final Set<String> effective =
      await PermissionPolicy.instance.getPermissionsForRole('admin');

  // Just the declared permissions on the role (no inheritance)
  final Set<String> declared = await PermissionPolicy.instance
      .getPermissionsForRole('admin', includeInherited: false);
  ```

## [3.1.0] - 2026-05-12

### Changed

* Upgraded `nylo_support` dependency to `^7.24.2` (was `^6.28.5`). Consumers must now use `nylo_support` v7 or later.
* Updated the internal storage layer's import path to match the new `nylo_support` v7 module layout (`local_storage/ny_local_storage.dart`). No public API change.

## [3.0.0] - 2026-04-30

### Major Release — Complete Rewrite

The v2 API has been removed and replaced with a typed, async, hierarchical permission system. There is no automatic migration: existing v2 users must reconfigure their permissions and roles and update widget call sites.

### New Features

* **Typed models** — `Permission` and `Role` replace plain strings, with `toMap`/`fromMap` and (for `Permission`) `toJson`/`fromJson` serialization
* **Permission inheritance** — permissions can inherit from other permissions via `inheritsFrom`
* **Role inheritance** — roles can inherit permissions from other roles via `inheritsFrom`
* **Cycle detection** — both inheritance walks detect cycles and stop safely
* **Detailed results** — `PermissionResult` returns `granted`, `reason`, `contributingRoles`, and `contributingPermissions`
* **`PermissionCheck` enum** — pick `all` (default) or `any` semantics when checking multiple permissions or roles
* **Pluggable storage** — implement `PermissionStorage` to back the package with any storage layer. Default uses `nylo_support`'s `NyStorage`.
* **Permission caching** — resolved permissions are cached per device and invalidated automatically on `configure`, `giveRole`, `removeRole`, `clearRoles`, and `clearAll`
* **New widgets:**
  * `PermissionGuard` — conditionally render a child based on permissions or roles, with optional `fallback` and `loading` widgets
  * `PermissionBuilder` — builder-pattern widget that exposes the granted state and full `PermissionResult`
  * `RoleSelector` — interactive role selector with `list`, `chips`, and `cards` styles via `RoleSelectorStyle`
* **Testing helper** — `PermissionPolicy.reset()` clears the singleton for clean test setup

### Public API

```dart
// Configure
await PermissionPolicy.instance.configure(
  permissions: [Permission(id: 'read', name: 'Read')],
  roles: [Role(id: 'user', name: 'User', permissions: ['read'])],
);

// Or simple map form (auto-creates Permission objects)
await PermissionPolicy.instance.configureSimple({
  'admin': ['read', 'write', 'delete'],
});

// Assign roles to the device
await PermissionPolicy.instance.giveRole('admin');

// Check permissions
final hasRead = await PermissionPolicy.instance.hasPermission('read');
final result = await PermissionPolicy.instance.checkPermission('read');
print(result.granted); // bool
print(result.reason);  // explanation

// Custom storage (replaces the singleton)
PermissionPolicy.createWithStorage(MyCustomStorage());
```

### Breaking Changes

* **Device-level only** — there is no user model. Roles are assigned to the device, not to individual users. If you need per-user permissions, manage user identity in your app and call `clearRoles()` / `giveRole()` when the user changes.
* **All storage operations are now `async`** — every public method returns a `Future`.
* **Removed APIs:**
  * `RoleAndPermissions` typedef
  * `PermissionPolicy.addRoles(Map)` — use `configure(...)` or `configureSimple(...)`
  * Static call sites such as `PermissionPolicy.giveRole(...)` — call via `PermissionPolicy.instance.giveRole(...)`
  * `PermissionView` widget — replaced by `PermissionGuard`
  * `RoleView` widget — use `PermissionGuard(roles: [...])`
  * `RoleSelector` (v2 string-based) — replaced by a new typed `RoleSelector` with a different API surface
  * `UserRoles` widget — call `getDeviceRoles()` and render your own UI
  * `UserPermissions` widget — call `getDevicePermissions()` and render your own UI
* **Storage keys changed** — v3 uses different storage keys, so existing v2 role assignments will not be visible to v3. Reconfigure roles on first launch after upgrading.

### Migration from v2

**Before (v2):**
```dart
PermissionPolicy.instance.addRoles({
  'admin': ['read', 'write', 'delete'],
  'user': ['read'],
});

await PermissionPolicy.giveRole('user');
bool hasPermission = await PermissionPolicy.hasPermission('read');
```

**After (v3):**
```dart
await PermissionPolicy.instance.configureSimple({
  'admin': ['read', 'write', 'delete'],
  'user': ['read'],
});

await PermissionPolicy.instance.giveRole('user');
bool hasPermission = await PermissionPolicy.instance.hasPermission('read');
```

**Widget migration:**
```dart
// v2
PermissionView(child: Text('Subscribe'), permissions: ['can_subscribe'])

// v3
PermissionGuard(
  permissions: ['can_subscribe'],
  child: Text('Subscribe'),
  fallback: SizedBox.shrink(),
)
```

### Notes

* Requires Flutter SDK 3.1.4+ and Dart SDK `>=3.1.4 <4.0.0`
* Continues to depend on `nylo_support: ^6.28.5`
* Permission widgets resolve once when mounted; trigger a rebuild (e.g. via `setState` or a fresh `Key`) after `giveRole` / `removeRole` if the same widget should reflect the new state
* See README for the full API reference, custom-storage example, and testing patterns

## [2.0.8] - 2025-05-23

* Update pubspec.yaml

## [2.0.7] - 2025-04-09

* Update pubspec.yaml

## [2.0.6] - 2025-02-23

* Update GitHub workflows
* Update pubspec.yaml

## [2.0.5] - 2025-02-07

* Update pubspec.yaml

## [2.0.4] - 2024-12-31

* Update copyright year
* Update pubspec.yaml

## [2.0.3] - 2024-12-16

* Update pubspec.yaml

## [2.0.2] - 2024-11-25

* Update pubspec.yaml

## [2.0.1] - 2024-11-23

* Update pubspec.yaml

## [2.0.0] - 2024-11-06

* Update package to use nylo_support v6
* Update pubspec.yaml

## [1.2.5] - 2024-08-18

* Update pubspec.yaml
 
## [1.2.4] - 2024-07-19

* Update pubspec.yaml

## [1.2.3] - 2024-07-08

* Update pubspec.yaml

## [1.2.2] - 2024-07-06

* Update pubspec.yaml

## [1.2.1] - 2024-06-15

* Update pubspec.yaml

## [1.2.0] - 2024-06-13

* Update parameter position in `PermissionView`

## [1.1.27] - 2024-06-13

* Update pubspec.yaml

## [1.1.26] - 2024-06-06

* Update pubspec.yaml

## [1.1.25] - 2024-05-16

* Update pubspec.yaml

## [1.1.24] - 2024-05-12

* Update pubspec.yaml

## [1.1.23] - 2024-05-05

* Update pubspec.yaml

## [1.1.22] - 2024-05-02

* Update pubspec.yaml

## [1.1.21] - 2024-04-30

* Update pubspec.yaml

## [1.1.20] - 2024-04-26

* Update pubspec.yaml

## [1.1.19] - 2024-04-23

* Update pubspec.yaml

## [1.1.18] - 2024-04-10

* Update pubspec.yaml

## [1.1.17] - 2024-04-02

* Update pubspec.yaml

## [1.1.16] - 2024-03-28

* Update pubspec.yaml

## [1.1.15] - 2024-03-21

* Update pubspec.yaml

## [1.1.14] - 2024-03-19

* Update pubspec.yaml

## [1.1.13] - 2024-03-13

* Update pubspec.yaml

## [1.1.12] - 2024-03-07

* Update pubspec.yaml

## [1.1.11] - 2024-02-28

* Update workflow

## [1.1.10] - 2024-02-28

* Update pubspec.yaml

## [1.1.9] - 2024-02-20

* Update pubspec.yaml

## [1.1.8] - 2024-02-08

* Update pubspec.yaml

## [1.1.7] - 2024-01-31

* Update pubspec.yaml

## [1.1.6] - 2024-01-26

* Update pubspec.yaml

## [1.1.5] - 2024-01-19

* Update pubspec.yaml

## [1.1.4] - 2024-01-15

* Update pubspec.yaml

## [1.1.3] - 2024-01-02

* Add FUNDING.yml

## [1.1.2] - 2024-01-01

* Update license date
* Update pubspec.yaml
* Add GitHub actions
* Fix dart analysis issues

## [1.1.1] - 2023-12-10 

* Update pubspec.yaml

## [1.1.0] - 2023-11-22

* Ability to give users multiple roles
* Refactor `RoleViews` widget
* New `clearRoles` helper added to the `PermissionPolicy` class
* Update example directory
* Update Readme
* Update pubspec.yaml

## [1.0.2] - 2023-11-07

* Update Readme

## [1.0.1] - 2023-11-07

* Update Readme

## [1.0.0] - 2023-11-07

* Update Example
* Update README.md to include more information
* New hasRole method added to `PermissionPolicy` class
* Initialize Nylo in the `addRoles` method

## [0.1.0] - 2023-11-04

* Initial release

## [0.0.1] - 2023-11-04

* wip
