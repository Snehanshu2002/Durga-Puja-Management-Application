import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/user_management_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isUserOnline(AppUser user) {
    if (!user.isOnline || user.lastActiveAt == null) return false;
    return DateTime.now().difference(user.lastActiveAt!) <= AppConstants.activeUserThreshold;
  }

  String _formatLastActive(DateTime? lastActiveAt) {
    if (lastActiveAt == null) return 'Never';
    final diff = DateTime.now().difference(lastActiveAt);
    if (diff.inSeconds < 30) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds} seconds ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return DateFormat('dd MMM, HH:mm').format(lastActiveAt);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final searchQuery = ref.watch(userManagementSearchQueryProvider);
    final roleFilter = ref.watch(userManagementRoleFilterProvider);
    final permissionService = PermissionService();

    final canManageUsers = currentUser != null &&
        permissionService.hasPermission(currentUser.role, Permission.manageUsers);

    final isAdmin = currentUser != null && currentUser.role == AppRole.superAdmin;

    if (!canManageUsers) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        body: const Center(
          child: Text('You do not have permission to manage users.'),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    Widget buildCurrentLoggedInHeader() {
      final roleColor = _getRoleBadgeColor(currentUser.role);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF4EE),
          border: Border(bottom: BorderSide(color: const Color(0xFF7B1E2B).withValues(alpha: 0.15))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: roleColor.withValues(alpha: 0.15),
              child: Text(
                currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: roleColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Logged in as: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: currentUser.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B1E2B)),
                    ),
                    TextSpan(
                      text: ' (${currentUser.role.displayName})',
                      style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' • ${currentUser.email}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: isAdmin
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Members', icon: Icon(Icons.people_outline, size: 20)),
                  Tab(text: 'Live Active Users', icon: Icon(Icons.sensors, size: 20)),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          buildCurrentLoggedInHeader(),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final activeUsersList = users.where((u) => _isUserOnline(u)).toList();

                final filteredAllUsers = users.where((u) {
                  final matchesSearch = searchQuery.isEmpty ||
                      u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      u.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      (u.mobile != null && u.mobile!.contains(searchQuery));
                  final matchesRole = roleFilter == null || u.role == roleFilter;
                  return matchesSearch && matchesRole;
                }).toList();

                final filteredActiveUsers = activeUsersList.where((u) {
                  final matchesSearch = searchQuery.isEmpty ||
                      u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      u.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      (u.mobile != null && u.mobile!.contains(searchQuery));
                  final matchesRole = roleFilter == null || u.role == roleFilter;
                  return matchesSearch && matchesRole;
                }).toList();

                Widget buildSearchHeader() {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search user by name, email or mobile...',
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF7B1E2B)),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(userManagementSearchQueryProvider.notifier).state = '';
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF7B1E2B), width: 1.5),
                              ),
                            ),
                            onChanged: (val) {
                              ref.read(userManagementSearchQueryProvider.notifier).state = val.trim();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<AppRole?>(
                              value: roleFilter,
                              hint: const Text('All Roles', style: TextStyle(fontSize: 13)),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('All Roles', style: TextStyle(fontSize: 13))),
                                ...AppRole.values.map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r.displayName, style: TextStyle(fontSize: 13, color: _getRoleBadgeColor(r))),
                                    )),
                              ],
                              onChanged: (role) {
                                ref.read(userManagementRoleFilterProvider.notifier).state = role;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

          Widget buildUserList(List<AppUser> userList) {
            if (userList.isEmpty) {
              return const Center(child: Text('No users found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final u = userList[index];
                final isActive = u.status.toUpperCase() == 'ACTIVE';
                final isOnline = _isUserOnline(u);
                final roleColor = _getRoleBadgeColor(u.role);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: roleColor.withValues(alpha: 0.12),
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isOnline ? const Color(0xFF2E8B57) : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            u.role.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.email),
                        if (u.mobile != null) Text('Mobile: ${u.mobile}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Joined: ${dateFormat.format(u.createdAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF2E8B57).withValues(alpha: 0.1)
                                    : const Color(0xFFC94C4C).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                u.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? const Color(0xFF2E8B57)
                                      : const Color(0xFFC94C4C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isOnline ? Icons.circle : Icons.circle_outlined,
                              size: 10,
                              color: isOnline ? const Color(0xFF2E8B57) : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOnline ? '● Active' : '● Offline',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isOnline ? const Color(0xFF2E8B57) : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Last active: ${_formatLastActive(u.lastActiveAt)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            if (u.lastPlatform != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '| Platform: ${u.lastPlatform}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: isAdmin
                        ? PopupMenuButton<String>(
                            onSelected: (val) async {
                              if (val == 'change_role') {
                                _showChangeRoleDialog(context, ref, u, currentUser);
                              } else if (val == 'deactivate') {
                                if (isActive) {
                                  _confirmDeactivateUser(context, ref, u, currentUser);
                                } else {
                                  _confirmActivateUser(context, ref, u, currentUser);
                                }
                              } else if (val == 'remove_association') {
                                _confirmRemoveAssociation(context, ref, u, currentUser);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'change_role',
                                child: Row(
                                  children: [
                                    Icon(Icons.manage_accounts, size: 18),
                                    SizedBox(width: 8),
                                    Text('Change Role'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'deactivate',
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive ? Icons.block : Icons.check_circle_outline,
                                      size: 18,
                                      color: isActive ? Colors.orange : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isActive ? 'Deactivate User' : 'Activate User'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'remove_association',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_remove, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Remove Association', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            );
          }

          if (!isAdmin) {
            return Column(
              children: [
                buildSearchHeader(),
                Expanded(child: buildUserList(filteredAllUsers)),
              ],
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: All Members
              Column(
                children: [
                  buildSearchHeader(),
                  Expanded(child: buildUserList(filteredAllUsers)),
                ],
              ),
              // Tab 2: Live Active Users
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSearchHeader(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: const Color(0xFF2E8B57).withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors, color: Color(0xFF2E8B57), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Live Active Users (${filteredActiveUsers.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: buildUserList(filteredActiveUsers)),
                ],
              ),
            ],
          );
        },
        loading: () => const LoadingView(message: 'Loading users...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(allUsersProvider),
        ),
      ),
    ),
  ],
),
floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddUserDialog(context, ref, currentUser),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Add Member',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF7B1E2B),
            )
          : null,
    );
  }

  void _confirmActivateUser(
    BuildContext context,
    WidgetRef ref,
    AppUser targetUser,
    AppUser currentUser,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activate User'),
        content: Text('Re-activate this member\'s account? (${targetUser.name})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57)),
            onPressed: () async {
              try {
                await ref.read(userManagementControllerProvider).toggleUserStatus(
                      targetUser: targetUser,
                      currentUser: currentUser,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User account activated successfully.')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Activate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateUser(
    BuildContext context,
    WidgetRef ref,
    AppUser targetUser,
    AppUser currentUser,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Deactivate this member\'s account? (${targetUser.name})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              try {
                await ref.read(userManagementControllerProvider).deactivateUser(
                      targetUser: targetUser,
                      currentUser: currentUser,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User account deactivated successfully.')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveAssociation(
    BuildContext context,
    WidgetRef ref,
    AppUser targetUser,
    AppUser currentUser,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member Association'),
        content: Text('Remove this member\'s association? (${targetUser.name})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(userManagementControllerProvider).removeUserAssociation(
                      targetUser: targetUser,
                      currentUser: currentUser,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member association removed successfully.')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(
    BuildContext context,
    WidgetRef ref,
    AppUser targetUser,
    AppUser currentUser,
  ) {
    AppRole selectedRole = targetUser.role;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Role: ${targetUser.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Role: ${targetUser.role.displayName}'),
                  const SizedBox(height: 12),
                  const Text('Select New Role:'),
                  DropdownButton<AppRole>(
                    isExpanded: true,
                    value: selectedRole,
                    items: AppRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      );
                    }).toList(),
                    onChanged: (r) {
                      if (r != null) setState(() => selectedRole = r);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(userManagementControllerProvider)
                          .updateUserRole(
                            targetUser: targetUser,
                            newRole: selectedRole,
                            currentUser: currentUser,
                          );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User role updated successfully.')),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddUserDialog(
    BuildContext context,
    WidgetRef ref,
    AppUser currentUser,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final mobileController = TextEditingController();
    AppRole selectedRole = AppRole.collectionMember;
    bool obscurePassword = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Committee Member'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          hintText: 'e.g. Rahul Sharma',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'member@durgapuja.org',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email is required';
                          if (!val.contains('@') || !val.contains('.')) return 'Invalid email format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Set Password *',
                          hintText: 'Minimum 6 characters',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Password is required';
                          if (val.trim().length < 6) return 'Minimum 6 characters required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password *',
                          hintText: 'Re-enter password',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please confirm password';
                          if (val.trim() != passwordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number (Optional)',
                          hintText: '+91 9876543210',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Select Role:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<AppRole>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        items: AppRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.displayName),
                          );
                        }).toList(),
                        onChanged: (r) {
                          if (r != null) setState(() => selectedRole = r);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B1E2B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isLoading = true);
                          try {
                            await ref
                                .read(userManagementControllerProvider)
                                .addNewUser(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  mobile: mobileController.text,
                                  role: selectedRole,
                                  currentUser: currentUser,
                                );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('New committee member added successfully!'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add Member'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getRoleBadgeColor(AppRole role) {
    switch (role) {
      case AppRole.superAdmin:
        return const Color(0xFF7E57C2);
      case AppRole.president:
        return const Color(0xFFD4A72C);
      case AppRole.treasurer:
        return const Color(0xFF2E8B57);
      case AppRole.manager:
        return const Color(0xFF7B1E2B);
      case AppRole.collectionMember:
        return const Color(0xFF26A69A);
      case AppRole.viewer:
        return const Color(0xFF78909C);
    }
  }
}
