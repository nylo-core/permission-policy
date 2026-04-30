import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/permission_result.dart';
import '../permission_policy.dart';
import '../types/permission_check.dart';

/// Widget that conditionally shows content based on permissions
///
/// Example:
/// ```dart
/// PermissionGuard(
///   permissions: ['edit_posts'],
///   child: EditButton(),
///   fallback: Text('Not authorized'),
/// )
/// ```
class PermissionGuard extends StatefulWidget {
  /// The permissions required to show the child
  final List<String>? permissions;

  /// The roles required to show the child
  final List<String>? roles;

  /// Whether to check for ANY or ALL permissions/roles
  final PermissionCheck checkType;

  /// The widget to show when permission is granted
  final Widget child;

  /// The widget to show when permission is denied
  final Widget? fallback;

  /// Custom loading widget while checking permissions
  final Widget? loading;

  /// Callback when permission check completes
  final void Function(PermissionResult result)? onPermissionChecked;

  /// Whether to show debug information in debug mode
  final bool showDebugInfo;

  const PermissionGuard({
    super.key,
    this.permissions,
    this.roles,
    this.checkType = PermissionCheck.all,
    required this.child,
    this.fallback,
    this.loading,
    this.onPermissionChecked,
    this.showDebugInfo = false,
  }) : assert(permissions != null || roles != null,
            'Either permissions or roles must be provided');

  @override
  State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  late Future<PermissionResult> _permissionFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _checkPermissions();
  }

  @override
  void didUpdateWidget(PermissionGuard oldWidget) {
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
        if (result == null) {
          return widget.fallback ?? const SizedBox.shrink();
        }

        widget.onPermissionChecked?.call(result);

        if (result.granted) {
          return _wrapWithDebugInfo(widget.child, result);
        }

        return _wrapWithDebugInfo(
          widget.fallback ?? const SizedBox.shrink(),
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

  Widget _wrapWithDebugInfo(Widget child, PermissionResult result) {
    if (!widget.showDebugInfo || !kDebugMode) {
      return child;
    }

    return Tooltip(
      message: 'Permission: ${result.granted ? "GRANTED" : "DENIED"}\n'
          'Reason: ${result.reason ?? "N/A"}\n'
          'Roles: ${result.contributingRoles.join(", ")}\n'
          'Permissions: ${result.contributingPermissions.join(", ")}',
      child: child,
    );
  }
}
