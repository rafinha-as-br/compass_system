import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/shared/widgets/breadcrumb_bar.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/view_user_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/create_user_page.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

/// Users Dashboard Tab — lists all Client users with status indicators.
class UsersDashboardPage extends StatelessWidget {
  const UsersDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersController(),
      child: const _UsersDashboardView(),
    );
  }
}

class _UsersDashboardView extends StatelessWidget {
  const _UsersDashboardView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsersController>();
    final state = controller.state;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BreadcrumbBar(items: ['Users Dashboard']),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Client Users',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: controller,
                              child: const CreateUserPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Create User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      state.errorMessage!,
                      style:
                          TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                // Users Table
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.users.isEmpty
                          ? Center(
                              child: Text(
                                'No client users found.',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            )
                          : Card(
                              child: _buildUsersTable(
                                  context, state.users, controller),
                            ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTable(
    BuildContext context,
    List<Client> users,
    UsersController controller,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: users.map((user) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => _navigateToUser(context, user, controller),
              ),
              DataCell(Text(user.email)),
              DataCell(Text(user.phoneNumber)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? TravelAppColors.success.withValues(alpha: 0.1)
                        : TravelAppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: user.isActive
                          ? TravelAppColors.success
                          : TravelAppColors.error,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  tooltip: 'View User',
                  onPressed: () =>
                      _navigateToUser(context, user, controller),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _navigateToUser(
    BuildContext context,
    Client user,
    UsersController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: ViewUserPage(user: user),
        ),
      ),
    );
  }
}
