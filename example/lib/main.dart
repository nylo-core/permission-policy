import 'package:flutter/material.dart';
import 'package:permission_policy/permission_policy.dart';

void main() async {
  // Initialize the permission system
  await initializePermissions();

  runApp(const MyApp());
}

Future<void> initializePermissions() async {
  final policy = PermissionPolicy.instance;

  // Initialize the permission system
  await policy.initialize();

  // Configure with detailed permissions and roles
  await policy.configure(
    permissions: const [
      Permission(
        id: 'view_content',
        name: 'View Content',
        description: 'Can view regular content',
        category: 'content',
      ),
      Permission(
        id: 'view_exclusive_content',
        name: 'View Exclusive Content',
        description: 'Can view premium exclusive content',
        category: 'content',
        priority: 1,
      ),
      Permission(
        id: 'create_content',
        name: 'Create Content',
        description: 'Can create new content',
        category: 'content',
        priority: 2,
      ),
      Permission(
        id: 'edit_content',
        name: 'Edit Content',
        description: 'Can edit existing content',
        category: 'content',
        priority: 2,
        inheritsFrom: ['create_content'], // Inherits create permission
      ),
      Permission(
        id: 'delete_content',
        name: 'Delete Content',
        description: 'Can delete content',
        category: 'content',
        priority: 3,
      ),
      Permission(
        id: 'manage_users',
        name: 'Manage Users',
        description: 'Can manage user accounts',
        category: 'admin',
        priority: 4,
      ),
      Permission(
        id: 'system_admin',
        name: 'System Administration',
        description: 'Full system access',
        category: 'admin',
        priority: 5,
      ),
    ],
    roles: const [
      Role(
        id: 'guest',
        name: 'Guest',
        description: 'Basic guest access',
        permissions: ['view_content'],
        priority: 1,
      ),
      Role(
        id: 'user',
        name: 'User',
        description: 'Regular user with basic permissions',
        permissions: ['view_content'],
        priority: 2,
      ),
      Role(
        id: 'subscriber',
        name: 'Subscriber',
        description: 'Premium subscriber with exclusive content access',
        permissions: ['view_content', 'view_exclusive_content'],
        priority: 3,
        inheritsFrom: ['user'], // Inherits from user role
      ),
      Role(
        id: 'content_creator',
        name: 'Content Creator',
        description: 'Can create and manage content',
        permissions: ['view_content', 'create_content', 'edit_content'],
        priority: 4,
      ),
      Role(
        id: 'moderator',
        name: 'Moderator',
        description: 'Can moderate content and basic user management',
        permissions: [
          'view_content',
          'view_exclusive_content',
          'edit_content',
          'delete_content'
        ],
        priority: 5,
        inheritsFrom: ['subscriber', 'content_creator'],
      ),
      Role(
        id: 'admin',
        name: 'Administrator',
        description: 'Full administrative access',
        permissions: ['system_admin', 'manage_users'],
        priority: 10,
        inheritsFrom: ['moderator'], // Inherits all moderator permissions
      ),
    ],
  );

  // Set up the device with a default guest role
  await policy.giveRole('guest');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Policy Demo',
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
      appBar: AppBar(
        title: const Text("Permission Policy Demo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Role selector section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Roles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: RoleSelector(
                          style: const RoleSelectorStyle.list(),
                          onRoleChanged: (role, isSelected) {
                            if (isSelected) {
                              PermissionPolicy.instance.giveRole(role.id);
                            } else {
                              PermissionPolicy.instance.removeRole(role.id);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Permission-based UI examples
              Text(
                'Permission-Based UI Examples',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Basic content viewing
              PermissionGuard(
                permissions: const ['view_content'],
                fallback: Card(
                  color: Colors.red.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.visibility_off, color: Colors.red),
                    title: Text('Basic Content'),
                    subtitle: Text('No permission to view content'),
                  ),
                ),
                child: Card(
                  color: Colors.green.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.visibility, color: Colors.green),
                    title: Text('Basic Content'),
                    subtitle: Text('You can view regular content'),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Exclusive content
              PermissionGuard(
                permissions: const ['view_exclusive_content'],
                fallback: Card(
                  color: Colors.grey.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.star_border, color: Colors.grey),
                    title: Text('Exclusive Content'),
                    subtitle: Text('Subscribe to access premium content'),
                  ),
                ),
                child: Card(
                  color: Colors.purple.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.star, color: Colors.purple),
                    title: Text('Exclusive Content'),
                    subtitle: Text('You have access to premium content!'),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Content creation
              PermissionGuard(
                permissions: const ['create_content'],
                fallback: const SizedBox.shrink(),
                child: Card(
                  color: Colors.blue.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.add, color: Colors.blue),
                    title: Text('Create Content'),
                    subtitle: Text('You can create new content'),
                  ),
                ),
              ),

              // Content editing (uses permission inheritance)
              PermissionGuard(
                permissions: const ['edit_content'],
                fallback: const SizedBox.shrink(),
                child: Card(
                  color: Colors.orange.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.edit, color: Colors.orange),
                    title: Text('Edit Content'),
                    subtitle: Text(
                        'You can edit content (includes create permission)'),
                  ),
                ),
              ),

              // Admin functions
              PermissionGuard(
                permissions: const ['manage_users'],
                fallback: const SizedBox.shrink(),
                child: Card(
                  color: Colors.red.shade50,
                  child: const ListTile(
                    leading:
                        Icon(Icons.admin_panel_settings, color: Colors.red),
                    title: Text('User Management'),
                    subtitle: Text('You can manage user accounts'),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Permission builder example
              PermissionBuilder(
                permissions: const ['system_admin'],
                builder: (context, hasPermission, result) {
                  return ElevatedButton.icon(
                    onPressed: hasPermission
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('System admin action performed!'),
                              ),
                            );
                          }
                        : null,
                    icon: Icon(hasPermission
                        ? Icons.admin_panel_settings
                        : Icons.lock),
                    label: Text(
                        hasPermission ? 'System Admin Panel' : 'Access Denied'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPermission ? Colors.red : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await PermissionPolicy.instance.clearRoles();
                        setState(() {});
                      },
                      child: const Text('Clear All Roles'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await PermissionPolicy.instance.giveRole('admin');
                        setState(() {});
                      },
                      child: const Text('Make Admin'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
