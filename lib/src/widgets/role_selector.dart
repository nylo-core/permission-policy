import 'package:flutter/material.dart';
import '../models/role.dart';
import '../permission_policy.dart';

/// Modern role selector widget with customizable UI
///
/// Example:
/// ```dart
/// RoleSelector(
///   onRoleChanged: (role) => print('Selected: ${role.name}'),
///   style: RoleSelectorStyle.chips(),
/// )
/// ```
class RoleSelector extends StatefulWidget {
  /// Callback when a role is selected/deselected
  final void Function(Role role, bool isSelected)? onRoleChanged;

  /// Callback when selection is complete
  final void Function(List<Role> selectedRoles)? onSelectionComplete;

  /// Whether to allow multiple role selection
  final bool multiSelect;

  /// Initially selected role IDs
  final List<String> initialSelectedRoleIds;

  /// Custom style for the role selector
  final RoleSelectorStyle style;

  /// Custom builder for role items
  final Widget Function(Role role, bool isSelected, VoidCallback onTap)?
      itemBuilder;

  /// Filter function to show only certain roles
  final bool Function(Role role)? roleFilter;

  /// Whether to show role descriptions
  final bool showDescriptions;

  /// Loading widget while roles are being fetched
  final Widget? loading;

  /// Widget to show when no roles are available
  final Widget? emptyWidget;

  const RoleSelector({
    super.key,
    this.onRoleChanged,
    this.onSelectionComplete,
    this.multiSelect = true,
    this.initialSelectedRoleIds = const [],
    this.style = const RoleSelectorStyle.list(),
    this.itemBuilder,
    this.roleFilter,
    this.showDescriptions = true,
    this.loading,
    this.emptyWidget,
  });

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  Set<String> selectedRoleIds = <String>{};
  late Future<List<Role>> _rolesFuture;

  @override
  void initState() {
    super.initState();
    selectedRoleIds.addAll(widget.initialSelectedRoleIds);
    _rolesFuture = _loadRoles();
  }

  @override
  void didUpdateWidget(RoleSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roleFilter != widget.roleFilter) {
      _rolesFuture = _loadRoles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Role>>(
      future: _rolesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ??
              const Center(child: CircularProgressIndicator());
        }

        final roles = snapshot.data ?? [];
        if (roles.isEmpty) {
          return widget.emptyWidget ??
              const Center(child: Text('No roles available'));
        }

        return _buildRoleSelector(roles);
      },
    );
  }

  Future<List<Role>> _loadRoles() async {
    final policy = PermissionPolicy.instance;
    final allRoles = await policy.getAssignableRoles();

    if (widget.roleFilter != null) {
      return allRoles.where(widget.roleFilter!).toList();
    }

    return allRoles;
  }

  Widget _buildRoleSelector(List<Role> roles) {
    switch (widget.style.type) {
      case RoleSelectorType.chips:
        return _buildChipSelector(roles);
      case RoleSelectorType.cards:
        return _buildCardSelector(roles);
      case RoleSelectorType.list:
        return _buildListSelector(roles);
    }
  }

  Widget _buildListSelector(List<Role> roles) {
    return ListView.builder(
      shrinkWrap: true,
      physics: widget.style.scrollPhysics,
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        final isSelected = selectedRoleIds.contains(role.id);

        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(
            role,
            isSelected,
            () => _toggleRole(role),
          );
        }

        return _buildDefaultListItem(role, isSelected);
      },
    );
  }

  Widget _buildChipSelector(List<Role> roles) {
    return Wrap(
      spacing: widget.style.spacing,
      runSpacing: widget.style.runSpacing,
      children: roles.map((role) {
        final isSelected = selectedRoleIds.contains(role.id);

        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(
            role,
            isSelected,
            () => _toggleRole(role),
          );
        }

        return _buildDefaultChip(role, isSelected);
      }).toList(),
    );
  }

  Widget _buildCardSelector(List<Role> roles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: widget.style.scrollPhysics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.style.crossAxisCount,
        crossAxisSpacing: widget.style.spacing,
        mainAxisSpacing: widget.style.spacing,
        childAspectRatio: widget.style.childAspectRatio,
      ),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        final isSelected = selectedRoleIds.contains(role.id);

        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(
            role,
            isSelected,
            () => _toggleRole(role),
          );
        }

        return _buildDefaultCard(role, isSelected);
      },
    );
  }

  Widget _buildDefaultListItem(Role role, bool isSelected) {
    return ListTile(
      title: Text(
        role.name,
        style: widget.style.titleStyle,
      ),
      subtitle: widget.showDescriptions && role.description != null
          ? Text(
              role.description!,
              style: widget.style.subtitleStyle,
            )
          : null,
      leading: widget.multiSelect
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleRole(role),
            )
          : Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
      onTap: () => _toggleRole(role),
      selected: isSelected,
      selectedTileColor: widget.style.selectedColor?.withValues(alpha: 0.1),
    );
  }

  Widget _buildDefaultChip(Role role, bool isSelected) {
    return FilterChip(
      label: Text(role.name),
      selected: isSelected,
      onSelected: (_) => _toggleRole(role),
      selectedColor: widget.style.selectedColor,
      backgroundColor: widget.style.backgroundColor,
      labelStyle: widget.style.titleStyle,
      tooltip: widget.showDescriptions ? role.description : null,
    );
  }

  Widget _buildDefaultCard(Role role, bool isSelected) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected
          ? widget.style.selectedColor ?? Theme.of(context).primaryColor
          : widget.style.backgroundColor,
      child: InkWell(
        onTap: () => _toggleRole(role),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                role.name,
                style: widget.style.titleStyle?.copyWith(
                  color: isSelected ? Colors.white : null,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.showDescriptions && role.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    role.description!,
                    style: widget.style.subtitleStyle?.copyWith(
                      color: isSelected ? Colors.white70 : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleRole(Role role) {
    setState(() {
      if (widget.multiSelect) {
        if (selectedRoleIds.contains(role.id)) {
          selectedRoleIds.remove(role.id);
          widget.onRoleChanged?.call(role, false);
        } else {
          selectedRoleIds.add(role.id);
          widget.onRoleChanged?.call(role, true);
        }
      } else {
        final wasSelected = selectedRoleIds.contains(role.id);
        selectedRoleIds.clear();
        if (!wasSelected) {
          selectedRoleIds.add(role.id);
          widget.onRoleChanged?.call(role, true);
        } else {
          widget.onRoleChanged?.call(role, false);
        }
      }
    });

    // Notify completion callback
    final allRoles = <Role>[];
    PermissionPolicy.instance.getAssignableRoles().then((roles) {
      allRoles.addAll(roles);
      final selectedRoles =
          allRoles.where((r) => selectedRoleIds.contains(r.id)).toList();
      widget.onSelectionComplete?.call(selectedRoles);
    });
  }
}

/// Style configuration for role selector
class RoleSelectorStyle {
  final RoleSelectorType type;
  final double spacing;
  final double runSpacing;
  final int crossAxisCount;
  final double childAspectRatio;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? selectedColor;
  final Color? backgroundColor;
  final ScrollPhysics? scrollPhysics;

  const RoleSelectorStyle({
    required this.type,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.titleStyle,
    this.subtitleStyle,
    this.selectedColor,
    this.backgroundColor,
    this.scrollPhysics,
  });

  const RoleSelectorStyle.list({
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.crossAxisCount = 1,
    this.childAspectRatio = 1.0,
    this.titleStyle,
    this.subtitleStyle,
    this.selectedColor,
    this.backgroundColor,
    this.scrollPhysics,
  }) : type = RoleSelectorType.list;

  const RoleSelectorStyle.chips({
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.crossAxisCount = 1,
    this.childAspectRatio = 1.0,
    this.titleStyle,
    this.subtitleStyle,
    this.selectedColor,
    this.backgroundColor,
    this.scrollPhysics,
  }) : type = RoleSelectorType.chips;

  const RoleSelectorStyle.cards({
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.titleStyle,
    this.subtitleStyle,
    this.selectedColor,
    this.backgroundColor,
    this.scrollPhysics,
  }) : type = RoleSelectorType.cards;
}

enum RoleSelectorType {
  list,
  chips,
  cards,
}
