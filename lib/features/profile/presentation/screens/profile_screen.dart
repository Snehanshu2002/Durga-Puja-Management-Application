import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:durgapuja_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _mobileController = TextEditingController(text: user?.mobile ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('User profile not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildReadOnlyRow('Role', user.role.displayName),
                    _buildReadOnlyRow('Status', user.status),
                    _buildReadOnlyRow('Email', user.email),
                    _buildReadOnlyRow('UID', user.uid),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _mobileController,
              labelText: 'Mobile Number',
              hintText: 'Enter mobile number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Update Profile',
              isLoading: _isLoading,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                setState(() => _isLoading = true);
                try {
                  final updated = user.copyWith(
                    name: _nameController.text.trim(),
                    mobile: _mobileController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(userRepositoryProvider).updateUser(updated);
                  ref.invalidate(currentUserProvider);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out / Logout'),
              onPressed: () => _confirmSignOut(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Pop profile screen
              ref.read(authControllerProvider).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
