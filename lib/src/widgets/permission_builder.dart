import 'package:flutter/material.dart';
import '../models/permission_result.dart';
import '../permission_policy.dart';
import '../types/permission_check.dart';

/// Builder widget that provides permission information to its child
///
/// Example:
/// ```dart
/// PermissionBuilder(
///   permissions: ['edit_posts'],
///   builder: (context, hasPermission, result) {
///     return ElevatedButton(
///       onPressed: hasPermission ? () => editPost() : null,
///       child: Text(hasPermission ? 'Edit' : 'No Permission'),
///     );
///   },
/// )
/// ```
class PermissionBuilder extends StatefulWidget {
  /// The permissions to check
  final List<String>? permissions;

  /// The roles to check
  final List<String>? roles;

  /// Whether to check for ANY or ALL permissions/roles
  final PermissionCheck checkType;

  /// Builder function that receives permission state
  final Widget Function(
    BuildContext context,
    bool hasPermission,
    PermissionResult? result,
  ) builder;

  /// Loading widget while checking permissions
  final Widget? loading;

  const PermissionBuilder({
    super.key,
    this.permissions,
    this.roles,
    this.checkType = PermissionCheck.all,
    required this.builder,
    this.loading,
  }) : assert(permissions != null || roles != null,
            'Either permissions or roles must be provided');

  @override
  State<PermissionBuilder> createState() => _PermissionBuilderState();
}

class _PermissionBuilderState extends State<PermissionBuilder> {
  late Future<PermissionResult> _permissionFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _checkPermissions();
  }

  @override
  void didUpdateWidget(PermissionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permissions != widget.permissions ||
        oldWidget.roles != widget.roles ||
        oldWidget.checkType != widget.checkType) {
      _permissionFuture = _checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionResult>(
      future: _permissionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ??
              const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data;
        return widget.builder(
          context,
          result?.granted ?? false,
          result,
        );
      },
    );
  }

  Future<PermissionResult> _checkPermissions() async {
    final policy = PermissionPolicy.instance;

    // Check roles first if provided
    if (widget.roles != null && widget.roles!.isNotEmpty) {
      bool roleResult;
      if (widget.checkType == PermissionCheck.any) {
        roleResult = await policy.hasAnyRole(widget.roles!);
      } else {
        roleResult = await policy.hasAllRoles(widget.roles!);
      }

      if (!roleResult) {
        return PermissionResult.denied(
          reason: 'Required roles not found',
          contributingRoles: widget.roles!,
        );
      }
    }

    // Check permissions if provided
    if (widget.permissions != null && widget.permissions!.isNotEmpty) {
      if (widget.checkType == PermissionCheck.any) {
        return await policy.checkAnyPermission(widget.permissions!);
      } else {
        return await policy.checkAllPermissions(widget.permissions!);
      }
    }

    // If only roles were checked and passed
    return PermissionResult.granted(
      reason: 'Required roles found',
      contributingRoles: widget.roles ?? [],
    );
  }
}
