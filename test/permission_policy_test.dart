import 'package:flutter_test/flutter_test.dart';
import 'package:permission_policy/permission_policy.dart';

/// In-memory implementation of PermissionStorage for testing
class InMemoryPermissionStorage implements PermissionStorage {
  List<Permission> _permissions = [];
  List<Role> _roles = [];
  List<String> _deviceRoles = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> storePermissions(List<Permission> permissions) async {
    _permissions = List.from(permissions);
  }

  @override
  Future<List<Permission>> getPermissions() async {
    return List.from(_permissions);
  }

  @override
  Future<Permission?> getPermission(String id) async {
    return _permissions.where((p) => p.id == id).firstOrNull;
  }

  @override
  Future<void> storeRoles(List<Role> roles) async {
    _roles = List.from(roles);
  }

  @override
  Future<List<Role>> getRoles() async {
    return List.from(_roles);
  }

  @override
  Future<Role?> getRole(String id) async {
    return _roles.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<void> storeDeviceRoles(List<String> roleIds) async {
    _deviceRoles = List.from(roleIds);
  }

  @override
  Future<List<String>> getDeviceRoles() async {
    return List.from(_deviceRoles);
  }

  @override
  Future<void> clearDeviceRoles() async {
    _deviceRoles = [];
  }

  @override
  Future<void> clear() async {
    _permissions = [];
    _roles = [];
    _deviceRoles = [];
  }
}

void main() {
  // ─────────────────────────────────────────────
  // Model Tests
  // ─────────────────────────────────────────────

  group('Permission model', () {
    test('creates with required fields', () {
      final permission = Permission(id: 'read', name: 'Read');
      expect(permission.id, 'read');
      expect(permission.name, 'Read');
      expect(permission.description, isNull);
      expect(permission.category, isNull);
      expect(permission.priority, 0);
      expect(permission.inheritsFrom, isEmpty);
      expect(permission.metadata, isEmpty);
    });

    test('creates with all fields', () {
      final permission = Permission(
        id: 'write',
        name: 'Write',
        description: 'Can write data',
        category: 'content',
        priority: 5,
        inheritsFrom: ['read'],
        metadata: {'key': 'value'},
      );
      expect(permission.description, 'Can write data');
      expect(permission.category, 'content');
      expect(permission.priority, 5);
      expect(permission.inheritsFrom, ['read']);
      expect(permission.metadata, {'key': 'value'});
    });

    test('equality is based on id', () {
      final a = Permission(id: 'read', name: 'Read');
      final b = Permission(id: 'read', name: 'Different Name');
      final c = Permission(id: 'write', name: 'Read');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is based on id', () {
      final a = Permission(id: 'read', name: 'Read');
      final b = Permission(id: 'read', name: 'Other');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toMap and fromMap round-trip', () {
      final original = Permission(
        id: 'write',
        name: 'Write',
        description: 'Can write',
        category: 'content',
        priority: 3,
        inheritsFrom: ['read'],
        metadata: {'level': 2},
      );
      final map = original.toMap();
      final restored = Permission.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.category, original.category);
      expect(restored.priority, original.priority);
      expect(restored.inheritsFrom, original.inheritsFrom);
      expect(restored.metadata, original.metadata);
    });

    test('toJson and fromJson round-trip', () {
      final original = Permission(
        id: 'delete',
        name: 'Delete',
        inheritsFrom: ['write'],
      );
      final json = original.toJson();
      final restored = Permission.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.inheritsFrom, original.inheritsFrom);
    });

    test('fromMap handles missing optional fields', () {
      final permission = Permission.fromMap({'id': 'test', 'name': 'Test'});
      expect(permission.priority, 0);
      expect(permission.inheritsFrom, isEmpty);
      expect(permission.metadata, isEmpty);
    });

    test('copyWith creates modified copy', () {
      final original = Permission(id: 'read', name: 'Read', priority: 1);
      final copy = original.copyWith(name: 'Read All', priority: 5);
      expect(copy.id, 'read');
      expect(copy.name, 'Read All');
      expect(copy.priority, 5);
    });

    test('copyWith preserves unmodified fields', () {
      final original = Permission(
        id: 'read',
        name: 'Read',
        description: 'desc',
        category: 'cat',
      );
      final copy = original.copyWith(name: 'New');
      expect(copy.description, 'desc');
      expect(copy.category, 'cat');
    });

    test('toString includes id and name', () {
      final permission = Permission(id: 'read', name: 'Read');
      expect(permission.toString(), contains('read'));
      expect(permission.toString(), contains('Read'));
    });
  });

  group('Role model', () {
    test('creates with required fields', () {
      final role = Role(id: 'admin', name: 'Admin');
      expect(role.id, 'admin');
      expect(role.name, 'Admin');
      expect(role.permissions, isEmpty);
      expect(role.inheritsFrom, isEmpty);
      expect(role.isAssignable, true);
      expect(role.isSystem, false);
    });

    test('creates with all fields', () {
      final role = Role(
        id: 'admin',
        name: 'Admin',
        description: 'Administrator role',
        priority: 10,
        permissions: ['read', 'write', 'delete'],
        inheritsFrom: ['editor'],
        isAssignable: false,
        isSystem: true,
        metadata: {'level': 'top'},
      );
      expect(role.description, 'Administrator role');
      expect(role.priority, 10);
      expect(role.permissions, ['read', 'write', 'delete']);
      expect(role.inheritsFrom, ['editor']);
      expect(role.isAssignable, false);
      expect(role.isSystem, true);
    });

    test('equality is based on id', () {
      final a = Role(id: 'admin', name: 'Admin');
      final b = Role(id: 'admin', name: 'Super Admin');
      final c = Role(id: 'editor', name: 'Admin');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toMap and fromMap round-trip', () {
      final original = Role(
        id: 'editor',
        name: 'Editor',
        description: 'Can edit content',
        priority: 5,
        permissions: ['read', 'write'],
        inheritsFrom: ['viewer'],
        isAssignable: true,
        isSystem: false,
        metadata: {'scope': 'content'},
      );
      final map = original.toMap();
      final restored = Role.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.permissions, original.permissions);
      expect(restored.inheritsFrom, original.inheritsFrom);
      expect(restored.isAssignable, original.isAssignable);
      expect(restored.isSystem, original.isSystem);
    });

    test('fromMap handles missing optional fields', () {
      final role = Role.fromMap({'id': 'test', 'name': 'Test'});
      expect(role.priority, 0);
      expect(role.permissions, isEmpty);
      expect(role.inheritsFrom, isEmpty);
      expect(role.isAssignable, true);
      expect(role.isSystem, false);
    });

    test('copyWith creates modified copy', () {
      final original = Role(id: 'viewer', name: 'Viewer');
      final copy = original.copyWith(
        permissions: ['read'],
        isSystem: true,
      );
      expect(copy.id, 'viewer');
      expect(copy.permissions, ['read']);
      expect(copy.isSystem, true);
      expect(copy.name, 'Viewer');
    });
  });

  group('PermissionResult model', () {
    test('granted factory creates granted result', () {
      final result = PermissionResult.granted(reason: 'Direct permission');
      expect(result.granted, true);
      expect(result.reason, 'Direct permission');
    });

    test('denied factory creates denied result', () {
      final result = PermissionResult.denied(reason: 'No access');
      expect(result.granted, false);
      expect(result.reason, 'No access');
    });

    test('granted factory has default reason', () {
      final result = PermissionResult.granted();
      expect(result.reason, 'Permission granted');
    });

    test('denied factory has default reason', () {
      final result = PermissionResult.denied();
      expect(result.reason, 'Permission denied');
    });

    test('includes contributing roles and permissions', () {
      final result = PermissionResult.granted(
        contributingRoles: ['admin', 'editor'],
        contributingPermissions: ['read', 'write'],
      );
      expect(result.contributingRoles, ['admin', 'editor']);
      expect(result.contributingPermissions, ['read', 'write']);
    });

    test('copyWith creates modified copy', () {
      final original = PermissionResult.denied(reason: 'No user');
      final copy = original.copyWith(granted: true, reason: 'Overridden');
      expect(copy.granted, true);
      expect(copy.reason, 'Overridden');
    });
  });

  group('PermissionCheck enum', () {
    test('has any and all values', () {
      expect(PermissionCheck.values, contains(PermissionCheck.any));
      expect(PermissionCheck.values, contains(PermissionCheck.all));
    });
  });

  // ─────────────────────────────────────────────
  // InMemoryPermissionStorage Tests
  // ─────────────────────────────────────────────

  group('InMemoryPermissionStorage', () {
    late InMemoryPermissionStorage storage;

    setUp(() {
      storage = InMemoryPermissionStorage();
    });

    test('stores and retrieves permissions', () async {
      final permissions = [
        Permission(id: 'read', name: 'Read'),
        Permission(id: 'write', name: 'Write'),
      ];
      await storage.storePermissions(permissions);
      final result = await storage.getPermissions();
      expect(result.length, 2);
      expect(result[0].id, 'read');
    });

    test('stores and retrieves roles', () async {
      final roles = [
        Role(id: 'admin', name: 'Admin', permissions: ['read', 'write']),
      ];
      await storage.storeRoles(roles);
      final result = await storage.getRoles();
      expect(result.length, 1);
      expect(result[0].permissions, ['read', 'write']);
    });

    test('stores and retrieves device roles', () async {
      await storage.storeDeviceRoles(['admin', 'editor']);
      final result = await storage.getDeviceRoles();
      expect(result, ['admin', 'editor']);
    });

    test('getDeviceRoles returns empty list initially', () async {
      final result = await storage.getDeviceRoles();
      expect(result, isEmpty);
    });

    test('clearDeviceRoles clears device roles', () async {
      await storage.storeDeviceRoles(['admin']);
      await storage.clearDeviceRoles();
      final result = await storage.getDeviceRoles();
      expect(result, isEmpty);
    });

    test('clear removes all data', () async {
      await storage.storePermissions([Permission(id: 'r', name: 'R')]);
      await storage.storeRoles([Role(id: 'a', name: 'A')]);
      await storage.storeDeviceRoles(['a']);
      await storage.clear();
      expect(await storage.getPermissions(), isEmpty);
      expect(await storage.getRoles(), isEmpty);
      expect(await storage.getDeviceRoles(), isEmpty);
    });
  });

  // ─────────────────────────────────────────────
  // PermissionService Tests
  // ─────────────────────────────────────────────

  group('PermissionService', () {
    late InMemoryPermissionStorage storage;
    late PermissionService service;

    setUp(() async {
      storage = InMemoryPermissionStorage();
      service = PermissionService(storage);
      await service.initialize();
    });

    group('configuration', () {
      test('configure stores permissions and roles', () async {
        await service.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
          ],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
          ],
        );

        final permissions = await service.getPermissions();
        final roles = await service.getRoles();
        expect(permissions, hasLength(2));
        expect(roles, hasLength(1));
      });

      test('getAssignableRoles filters non-assignable roles', () async {
        await service.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
            Role(
              id: 'system_role',
              name: 'System',
              permissions: ['read'],
              isAssignable: false,
            ),
          ],
        );

        final assignable = await service.getAssignableRoles();
        expect(assignable, hasLength(1));
        expect(assignable.first.id, 'viewer');
      });
    });

    group('role management', () {
      test('giveRole adds role', () async {
        await service.giveRole('admin');
        final roles = await service.getDeviceRoles();
        expect(roles, contains('admin'));
      });

      test('giveRole does not duplicate roles', () async {
        await service.giveRole('admin');
        await service.giveRole('admin');
        final roles = await service.getDeviceRoles();
        expect(roles.where((r) => r == 'admin').length, 1);
      });

      test('removeRole removes role', () async {
        await service.giveRole('admin');
        await service.giveRole('editor');
        await service.removeRole('admin');
        final roles = await service.getDeviceRoles();
        expect(roles, ['editor']);
      });

      test('removeRole does nothing when role not present', () async {
        await service.giveRole('editor');
        await service.removeRole('admin');
        final roles = await service.getDeviceRoles();
        expect(roles, ['editor']);
      });

      test('clearRoles clears all device roles', () async {
        await service.giveRole('admin');
        await service.giveRole('editor');
        await service.clearRoles();
        final roles = await service.getDeviceRoles();
        expect(roles, isEmpty);
      });
    });

    group('role checks', () {
      test('hasRole returns true when device has role', () async {
        await service.giveRole('admin');
        expect(await service.hasRole('admin'), true);
      });

      test('hasRole returns false when device lacks role', () async {
        await service.giveRole('viewer');
        expect(await service.hasRole('admin'), false);
      });

      test('hasRole returns false when no roles', () async {
        expect(await service.hasRole('admin'), false);
      });

      test('hasAnyRole returns true when device has one of the roles',
          () async {
        await service.giveRole('editor');
        expect(await service.hasAnyRole(['admin', 'editor']), true);
      });

      test('hasAnyRole returns false when device has none', () async {
        await service.giveRole('viewer');
        expect(await service.hasAnyRole(['admin', 'editor']), false);
      });

      test('hasAllRoles returns true when device has all roles', () async {
        await service.giveRole('admin');
        await service.giveRole('editor');
        expect(await service.hasAllRoles(['admin', 'editor']), true);
      });

      test('hasAllRoles returns false when device is missing one', () async {
        await service.giveRole('admin');
        expect(await service.hasAllRoles(['admin', 'editor']), false);
      });
    });

    group('permission checks', () {
      setUp(() async {
        await service.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
            Permission(id: 'delete', name: 'Delete'),
          ],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
            Role(
              id: 'editor',
              name: 'Editor',
              permissions: ['read', 'write'],
            ),
            Role(
              id: 'admin',
              name: 'Admin',
              permissions: ['read', 'write', 'delete'],
            ),
          ],
        );
      });

      test('hasPermission returns denied when no roles', () async {
        final result = await service.hasPermission('read');
        expect(result.granted, false);
        expect(result.reason, 'Permission not found');
      });

      test('hasPermission granted via role', () async {
        await service.giveRole('viewer');
        final result = await service.hasPermission('read');
        expect(result.granted, true);
        expect(result.reason, 'Permission granted through roles');
        expect(result.contributingRoles, contains('viewer'));
      });

      test('hasPermission denied when role lacks permission', () async {
        await service.giveRole('viewer');
        final result = await service.hasPermission('write');
        expect(result.granted, false);
        expect(result.reason, 'Permission not found');
      });

      test('hasAnyPermission returns granted when one matches', () async {
        await service.giveRole('viewer');
        final result =
            await service.hasAnyPermission(['write', 'delete', 'read']);
        expect(result.granted, true);
      });

      test('hasAnyPermission returns denied when none match', () async {
        await service.giveRole('viewer');
        final result = await service.hasAnyPermission(['write', 'delete']);
        expect(result.granted, false);
        expect(result.reason, 'None of the required permissions found');
      });

      test('hasAllPermissions returns granted when all match', () async {
        await service.giveRole('editor');
        final result = await service.hasAllPermissions(['read', 'write']);
        expect(result.granted, true);
        expect(result.reason, 'All required permissions granted');
        expect(result.contributingPermissions, containsAll(['read', 'write']));
      });

      test('hasAllPermissions returns denied when one is missing', () async {
        await service.giveRole('viewer');
        final result = await service.hasAllPermissions(['read', 'write']);
        expect(result.granted, false);
      });

      test('getDevicePermissions resolves all permissions', () async {
        await service.giveRole('editor');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['read', 'write']));
      });

      test('getDevicePermissions returns empty when no roles', () async {
        final perms = await service.getDevicePermissions();
        expect(perms, isEmpty);
      });
    });

    group('role inheritance', () {
      test('child role inherits permissions from parent', () async {
        await service.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
            Permission(id: 'delete', name: 'Delete'),
          ],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
            Role(
              id: 'editor',
              name: 'Editor',
              permissions: ['write'],
              inheritsFrom: ['viewer'],
            ),
            Role(
              id: 'admin',
              name: 'Admin',
              permissions: ['delete'],
              inheritsFrom: ['editor'],
            ),
          ],
        );

        await service.giveRole('admin');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['read', 'write', 'delete']));
      });

      test('multi-level role inheritance chain', () async {
        await service.configure(
          permissions: [
            Permission(id: 'a', name: 'A'),
            Permission(id: 'b', name: 'B'),
            Permission(id: 'c', name: 'C'),
            Permission(id: 'd', name: 'D'),
          ],
          roles: [
            Role(id: 'r1', name: 'R1', permissions: ['a']),
            Role(
                id: 'r2',
                name: 'R2',
                permissions: ['b'],
                inheritsFrom: ['r1']),
            Role(
                id: 'r3',
                name: 'R3',
                permissions: ['c'],
                inheritsFrom: ['r2']),
            Role(
                id: 'r4',
                name: 'R4',
                permissions: ['d'],
                inheritsFrom: ['r3']),
          ],
        );

        await service.giveRole('r4');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['a', 'b', 'c', 'd']));
      });

      test('role inherits from multiple parents', () async {
        await service.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
            Permission(id: 'export', name: 'Export'),
          ],
          roles: [
            Role(id: 'reader', name: 'Reader', permissions: ['read']),
            Role(id: 'exporter', name: 'Exporter', permissions: ['export']),
            Role(
              id: 'analyst',
              name: 'Analyst',
              permissions: ['write'],
              inheritsFrom: ['reader', 'exporter'],
            ),
          ],
        );

        await service.giveRole('analyst');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['read', 'write', 'export']));
      });

      test('circular role inheritance does not cause infinite loop', () async {
        await service.configure(
          permissions: [
            Permission(id: 'a', name: 'A'),
            Permission(id: 'b', name: 'B'),
          ],
          roles: [
            Role(
                id: 'r1',
                name: 'R1',
                permissions: ['a'],
                inheritsFrom: ['r2']),
            Role(
                id: 'r2',
                name: 'R2',
                permissions: ['b'],
                inheritsFrom: ['r1']),
          ],
        );

        await service.giveRole('r1');

        // Should complete without hanging
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['a', 'b']));
      });
    });

    group('permission inheritance', () {
      test('permission inherits from parent permission', () async {
        await service.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(
              id: 'write',
              name: 'Write',
              inheritsFrom: ['read'],
            ),
          ],
          roles: [
            Role(id: 'editor', name: 'Editor', permissions: ['write']),
          ],
        );

        await service.giveRole('editor');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['read', 'write']));
      });

      test('multi-level permission inheritance', () async {
        await service.configure(
          permissions: [
            Permission(id: 'view', name: 'View'),
            Permission(id: 'read', name: 'Read', inheritsFrom: ['view']),
            Permission(id: 'write', name: 'Write', inheritsFrom: ['read']),
            Permission(id: 'admin', name: 'Admin', inheritsFrom: ['write']),
          ],
          roles: [
            Role(
                id: 'superadmin', name: 'Super Admin', permissions: ['admin']),
          ],
        );

        await service.giveRole('superadmin');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['view', 'read', 'write', 'admin']));
      });

      test('circular permission inheritance does not cause infinite loop',
          () async {
        await service.configure(
          permissions: [
            Permission(id: 'a', name: 'A', inheritsFrom: ['b']),
            Permission(id: 'b', name: 'B', inheritsFrom: ['a']),
          ],
          roles: [
            Role(id: 'r1', name: 'R1', permissions: ['a']),
          ],
        );

        await service.giveRole('r1');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['a', 'b']));
      });

      test('permission inherits from multiple parents', () async {
        await service.configure(
          permissions: [
            Permission(id: 'base_read', name: 'Base Read'),
            Permission(id: 'base_log', name: 'Base Log'),
            Permission(
              id: 'audit',
              name: 'Audit',
              inheritsFrom: ['base_read', 'base_log'],
            ),
          ],
          roles: [
            Role(id: 'auditor', name: 'Auditor', permissions: ['audit']),
          ],
        );

        await service.giveRole('auditor');
        final perms = await service.getDevicePermissions();
        expect(perms, containsAll(['base_read', 'base_log', 'audit']));
      });
    });

    group('combined role and permission inheritance', () {
      test('role inheritance + permission inheritance together', () async {
        await service.configure(
          permissions: [
            Permission(id: 'view', name: 'View'),
            Permission(id: 'edit', name: 'Edit', inheritsFrom: ['view']),
            Permission(id: 'publish', name: 'Publish'),
          ],
          roles: [
            Role(id: 'writer', name: 'Writer', permissions: ['edit']),
            Role(
              id: 'publisher',
              name: 'Publisher',
              permissions: ['publish'],
              inheritsFrom: ['writer'],
            ),
          ],
        );

        await service.giveRole('publisher');
        final perms = await service.getDevicePermissions();
        // publisher -> inherits writer -> edit -> inherits view, plus publish
        expect(perms, containsAll(['view', 'edit', 'publish']));
      });
    });

    group('clear operations', () {
      test('clearRoles clears device roles', () async {
        await service.giveRole('admin');
        await service.giveRole('editor');
        await service.clearRoles();
        final roles = await service.getDeviceRoles();
        expect(roles, isEmpty);
      });

      test('clear removes all data', () async {
        await service.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [Role(id: 'viewer', name: 'Viewer')],
        );
        await service.giveRole('viewer');
        await service.clear();
        expect(await service.getPermissions(), isEmpty);
        expect(await service.getRoles(), isEmpty);
        expect(await service.getDeviceRoles(), isEmpty);
      });
    });

    group('caching', () {
      test('repeated permission checks use cache', () async {
        await service.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [Role(id: 'viewer', name: 'Viewer', permissions: ['read'])],
        );
        await service.giveRole('viewer');

        // First call resolves and caches
        final result1 = await service.hasPermission('read');
        // Second call should use cache
        final result2 = await service.hasPermission('read');
        expect(result1.granted, true);
        expect(result2.granted, true);
      });

      test('cache invalidates when roles change', () async {
        await service.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
          ],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
            Role(
                id: 'editor',
                name: 'Editor',
                permissions: ['read', 'write']),
          ],
        );

        await service.giveRole('viewer');
        expect((await service.hasPermission('write')).granted, false);

        // Add editor role
        await service.giveRole('editor');
        expect((await service.hasPermission('write')).granted, true);
      });

      test('cache invalidates when configuration changes', () async {
        await service.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [Role(id: 'viewer', name: 'Viewer', permissions: ['read'])],
        );
        await service.giveRole('viewer');

        expect((await service.hasPermission('read')).granted, true);

        // Reconfigure with different permissions for the role
        await service.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [Role(id: 'viewer', name: 'Viewer', permissions: [])],
        );

        expect((await service.hasPermission('read')).granted, false);
      });

      test('cache invalidates when role is added', () async {
        await service.configure(
          permissions: [Permission(id: 'write', name: 'Write')],
          roles: [
            Role(id: 'editor', name: 'Editor', permissions: ['write']),
          ],
        );

        expect((await service.hasPermission('write')).granted, false);

        await service.giveRole('editor');
        expect((await service.hasPermission('write')).granted, true);
      });
    });
  });

  // ─────────────────────────────────────────────
  // PermissionPolicy (Facade) Tests
  // ─────────────────────────────────────────────

  group('PermissionPolicy', () {
    late PermissionPolicy policy;

    setUp(() async {
      PermissionPolicy.reset();
      policy = PermissionPolicy.createWithStorage(InMemoryPermissionStorage());
      await policy.initialize();
    });

    test('createWithStorage creates instance with custom storage', () {
      expect(policy, isNotNull);
    });

    group('configure and configureSimple', () {
      test('configure sets up permissions and roles', () async {
        await policy.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
          ],
          roles: [
            Role(id: 'editor', name: 'Editor', permissions: ['read', 'write']),
          ],
        );

        final permissions = await policy.getPermissions();
        final roles = await policy.getRoles();
        expect(permissions, hasLength(2));
        expect(roles, hasLength(1));
      });

      test('configureSimple creates permissions and roles from map', () async {
        await policy.configureSimple({
          'admin': ['read', 'write', 'delete'],
          'viewer': ['read'],
        });

        final permissions = await policy.getPermissions();
        final roles = await policy.getRoles();
        expect(permissions, hasLength(3));
        expect(roles, hasLength(2));
      });

      test('configureSimple deduplicates permission ids', () async {
        await policy.configureSimple({
          'admin': ['read', 'write'],
          'viewer': ['read'],
        });

        final permissions = await policy.getPermissions();
        // 'read' should only appear once
        expect(permissions, hasLength(2));
      });
    });

    group('role operations', () {
      test('giveRole adds role to device', () async {
        await policy.giveRole('admin');
        final roles = await policy.getDeviceRoles();
        expect(roles, contains('admin'));
      });

      test('removeRole removes role from device', () async {
        await policy.giveRole('admin');
        await policy.giveRole('editor');
        await policy.removeRole('admin');
        final roles = await policy.getDeviceRoles();
        expect(roles, ['editor']);
      });

      test('getDeviceRoles returns empty when no roles', () async {
        final roles = await policy.getDeviceRoles();
        expect(roles, isEmpty);
      });
    });

    group('permission checks (boolean)', () {
      setUp(() async {
        await policy.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
            Permission(id: 'delete', name: 'Delete'),
          ],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
            Role(
                id: 'editor',
                name: 'Editor',
                permissions: ['read', 'write']),
            Role(
              id: 'admin',
              name: 'Admin',
              permissions: ['read', 'write', 'delete'],
            ),
          ],
        );
      });

      test('hasPermission returns true when granted', () async {
        await policy.giveRole('editor');
        expect(await policy.hasPermission('read'), true);
        expect(await policy.hasPermission('write'), true);
      });

      test('hasPermission returns false when denied', () async {
        await policy.giveRole('viewer');
        expect(await policy.hasPermission('write'), false);
      });

      test('hasAnyPermission returns true when any matches', () async {
        await policy.giveRole('viewer');
        expect(await policy.hasAnyPermission(['write', 'read']), true);
      });

      test('hasAnyPermission returns false when none match', () async {
        await policy.giveRole('viewer');
        expect(await policy.hasAnyPermission(['write', 'delete']), false);
      });

      test('hasAllPermissions returns true when all match', () async {
        await policy.giveRole('admin');
        expect(
          await policy.hasAllPermissions(['read', 'write', 'delete']),
          true,
        );
      });

      test('hasAllPermissions returns false when any missing', () async {
        await policy.giveRole('editor');
        expect(
          await policy.hasAllPermissions(['read', 'write', 'delete']),
          false,
        );
      });

      test('hasRole returns true for assigned role', () async {
        await policy.giveRole('admin');
        expect(await policy.hasRole('admin'), true);
      });

      test('hasRole returns false for unassigned role', () async {
        await policy.giveRole('viewer');
        expect(await policy.hasRole('admin'), false);
      });

      test('hasAnyRole checks correctly', () async {
        await policy.giveRole('editor');
        expect(await policy.hasAnyRole(['admin', 'editor']), true);
        expect(await policy.hasAnyRole(['admin', 'viewer']), false);
      });

      test('hasAllRoles checks correctly', () async {
        await policy.giveRole('admin');
        await policy.giveRole('editor');
        expect(await policy.hasAllRoles(['admin', 'editor']), true);
        expect(await policy.hasAllRoles(['admin', 'editor', 'viewer']), false);
      });
    });

    group('detailed permission checks', () {
      setUp(() async {
        await policy.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
          ],
          roles: [
            Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
          ],
        );
        await policy.giveRole('viewer');
      });

      test('checkPermission returns PermissionResult', () async {
        final result = await policy.checkPermission('read');
        expect(result, isA<PermissionResult>());
        expect(result.granted, true);
      });

      test('checkAnyPermission returns PermissionResult', () async {
        final result = await policy.checkAnyPermission(['read', 'write']);
        expect(result.granted, true);
      });

      test('checkAllPermissions returns PermissionResult', () async {
        final result = await policy.checkAllPermissions(['read', 'write']);
        expect(result.granted, false);
      });
    });

    group('getDevicePermissions', () {
      test('returns all resolved permissions', () async {
        await policy.configure(
          permissions: [
            Permission(id: 'read', name: 'Read'),
            Permission(id: 'write', name: 'Write'),
          ],
          roles: [
            Role(
                id: 'editor',
                name: 'Editor',
                permissions: ['read', 'write']),
          ],
        );
        await policy.giveRole('editor');

        final perms = await policy.getDevicePermissions();
        expect(perms, containsAll(['read', 'write']));
      });
    });

    group('getAssignableRoles', () {
      test('returns only assignable roles', () async {
        await policy.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [
            Role(id: 'user', name: 'User', isAssignable: true),
            Role(id: 'system', name: 'System', isAssignable: false),
          ],
        );

        final roles = await policy.getAssignableRoles();
        expect(roles, hasLength(1));
        expect(roles.first.id, 'user');
      });
    });

    group('clear operations', () {
      test('clearRoles clears device roles', () async {
        await policy.giveRole('admin');
        await policy.clearRoles();
        final roles = await policy.getDeviceRoles();
        expect(roles, isEmpty);
      });

      test('clearAll removes everything', () async {
        await policy.configure(
          permissions: [Permission(id: 'read', name: 'Read')],
          roles: [Role(id: 'viewer', name: 'Viewer')],
        );
        await policy.giveRole('viewer');
        await policy.clearAll();

        expect(await policy.getPermissions(), isEmpty);
        expect(await policy.getRoles(), isEmpty);
        expect(await policy.getDeviceRoles(), isEmpty);
      });
    });
  });

  // ─────────────────────────────────────────────
  // Edge Cases & Integration Tests
  // ─────────────────────────────────────────────

  group('edge cases', () {
    late PermissionPolicy policy;

    setUp(() async {
      PermissionPolicy.reset();
      policy = PermissionPolicy.createWithStorage(InMemoryPermissionStorage());
      await policy.initialize();
    });

    test('empty configuration works', () async {
      await policy.configure(permissions: [], roles: []);
      expect(await policy.getPermissions(), isEmpty);
      expect(await policy.getRoles(), isEmpty);
    });

    test('device with no roles', () async {
      await policy.configure(
        permissions: [Permission(id: 'read', name: 'Read')],
        roles: [Role(id: 'viewer', name: 'Viewer', permissions: ['read'])],
      );
      expect(await policy.hasPermission('read'), false);
      expect(await policy.getDevicePermissions(), isEmpty);
    });

    test('device with non-existent role id', () async {
      await policy.configure(
        permissions: [Permission(id: 'read', name: 'Read')],
        roles: [Role(id: 'viewer', name: 'Viewer', permissions: ['read'])],
      );
      await policy.giveRole('nonexistent');
      expect(await policy.hasPermission('read'), false);
    });

    test('role references non-existent role in inheritsFrom', () async {
      final storage = InMemoryPermissionStorage();
      final svc = PermissionService(storage);
      await svc.initialize();
      await svc.configure(
        permissions: [
          Permission(id: 'read', name: 'Read'),
        ],
        roles: [
          Role(
            id: 'viewer',
            name: 'Viewer',
            permissions: ['read'],
            inheritsFrom: ['nonexistent_role'],
          ),
        ],
      );
      await svc.giveRole('viewer');
      final perms = await svc.getDevicePermissions();
      expect(perms, contains('read'));
    });

    test('permission references non-existent parent in inheritsFrom',
        () async {
      await policy.configure(
        permissions: [
          Permission(
            id: 'write',
            name: 'Write',
            inheritsFrom: ['nonexistent_permission'],
          ),
        ],
        roles: [
          Role(id: 'editor', name: 'Editor', permissions: ['write']),
        ],
      );
      await policy.giveRole('editor');
      // Should not crash, just resolve what's available
      final perms = await policy.getDevicePermissions();
      expect(perms, contains('write'));
    });

    test('switching roles clears cache properly', () async {
      await policy.configure(
        permissions: [
          Permission(id: 'read', name: 'Read'),
          Permission(id: 'write', name: 'Write'),
        ],
        roles: [
          Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
          Role(id: 'editor', name: 'Editor', permissions: ['read', 'write']),
        ],
      );

      await policy.giveRole('viewer');
      expect(await policy.hasPermission('write'), false);

      await policy.giveRole('editor');
      expect(await policy.hasPermission('write'), true);

      // Remove editor
      await policy.removeRole('editor');
      expect(await policy.hasPermission('write'), false);
    });

    test('reconfiguring clears previous data', () async {
      await policy.configure(
        permissions: [Permission(id: 'old', name: 'Old')],
        roles: [Role(id: 'old_role', name: 'Old Role', permissions: ['old'])],
      );
      await policy.giveRole('old_role');
      expect(await policy.hasPermission('old'), true);

      // Reconfigure without the old permission
      await policy.configure(
        permissions: [Permission(id: 'new', name: 'New')],
        roles: [Role(id: 'old_role', name: 'Old Role', permissions: ['new'])],
      );
      expect(await policy.hasPermission('old'), false);
      expect(await policy.hasPermission('new'), true);
    });
  });

  // ─────────────────────────────────────────────
  // resolveRolePermissions (public method) Tests
  // ─────────────────────────────────────────────

  group('PermissionService.resolveRolePermissions', () {
    late PermissionService service;

    setUp(() async {
      final storage = InMemoryPermissionStorage();
      service = PermissionService(storage);
      await service.initialize();
    });

    test('resolves direct role permissions', () async {
      await service.configure(
        permissions: [
          Permission(id: 'read', name: 'Read'),
          Permission(id: 'write', name: 'Write'),
        ],
        roles: [
          Role(id: 'editor', name: 'Editor', permissions: ['read', 'write']),
        ],
      );

      final roles = await service.getRoles();
      final perms = await service.resolveRolePermissions(roles.first, roles);
      expect(perms, containsAll(['read', 'write']));
    });

    test('resolves inherited role permissions', () async {
      await service.configure(
        permissions: [
          Permission(id: 'read', name: 'Read'),
          Permission(id: 'write', name: 'Write'),
        ],
        roles: [
          Role(id: 'viewer', name: 'Viewer', permissions: ['read']),
          Role(
            id: 'editor',
            name: 'Editor',
            permissions: ['write'],
            inheritsFrom: ['viewer'],
          ),
        ],
      );

      final roles = await service.getRoles();
      final editor = roles.firstWhere((r) => r.id == 'editor');
      final perms = await service.resolveRolePermissions(editor, roles);
      expect(perms, containsAll(['read', 'write']));
    });
  });
}
