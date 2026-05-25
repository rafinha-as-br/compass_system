import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/edit_user_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/delete_user_dialog.dart';

/// Displays all data of a selected user with edit/delete actions.
class ViewUserPage extends StatelessWidget {
  final Client user;

  const ViewUserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<UsersController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit User',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: controller,
                    child: EditUserPage(user: user),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error),
            tooltip: 'Delete User',
            onPressed: () async {
              final confirmed = await showDeleteUserDialog(context, user.name);
              if (confirmed == true) {
                final success = await controller.deleteUser(user.id);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar and name header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 32,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? const Color(0xFF2E7D5B)
                                  .withValues(alpha: 0.1)
                              : const Color(0xFFB23A3A)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: user.isActive
                                ? const Color(0xFF2E7D5B)
                                : const Color(0xFFB23A3A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                // User details
                _buildDetailRow(
                    theme, Icons.badge, 'CPF', user.cpf),
                _buildDetailRow(
                    theme, Icons.email, 'Email', user.email),
                _buildDetailRow(
                    theme, Icons.phone, 'Phone', user.phoneNumber),
                _buildDetailRow(
                  theme,
                  Icons.cake,
                  'Birth Date',
                  '${user.birthDate.day}/${user.birthDate.month}/${user.birthDate.year}',
                ),
                _buildDetailRow(
                    theme, Icons.person, 'Sex', user.sex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
