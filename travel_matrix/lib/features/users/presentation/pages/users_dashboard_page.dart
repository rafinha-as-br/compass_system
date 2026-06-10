import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/users/presentation/pages/delete_user_dialog.dart';

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

class _UsersDashboardView extends StatefulWidget {
  const _UsersDashboardView();

  @override
  State<_UsersDashboardView> createState() => _UsersDashboardViewState();
}

class _UsersDashboardViewState extends State<_UsersDashboardView> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsersController>();
    final state = controller.state;
    final theme = Theme.of(context);

    // Apply filters
    var filteredUsers = state.users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesStatus = true;
      if (_statusFilter == 'Active') {
        matchesStatus = user.isActive;
      } else if (_statusFilter == 'Inactive') {
        matchesStatus = !user.isActive;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row 1
          Text(
            'Client Users',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Header Row 2: Filters and Create Button
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TravelAppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TravelAppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Status Filter
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: TravelAppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Status'),
                      value: _statusFilter,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Status')),
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Spacer
              const Spacer(flex: 2),

              // Create Button
              ElevatedButton.icon(
                onPressed: () {
                  context.go(
                    '${AppRoutes.users}/${AppRoutes.userCreate}',
                    extra: {'controller': controller},
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          // Users Table
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
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
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: TravelAppColors.border),
                        ),
                        child: _buildUsersTable(context, filteredUsers, controller),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(
    BuildContext context,
    List<Client> users,
    UsersController controller,
  ) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                TravelAppColors.background,
              ),
              dataRowMaxHeight: 64,
              dataRowMinHeight: 64,
              columns: [
                DataColumn(label: Text('Name', style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Email', style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Phone', style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Status', style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Actions', style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(user.email, style: TextStyle(color: TravelAppColors.textSecondary))),
                    DataCell(Text(user.phoneNumber, style: TextStyle(color: TravelAppColors.textSecondary))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? TravelAppColors.success.withValues(alpha: 0.1)
                              : TravelAppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.isActive ? Icons.check_circle_outline : Icons.highlight_off,
                              size: 14,
                              color: user.isActive ? TravelAppColors.success : TravelAppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.isActive
                                    ? TravelAppColors.success
                                    : TravelAppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: TravelAppColors.textSecondary,
                            tooltip: 'Edit User',
                            onPressed: () {
                              context.go(
                                '${AppRoutes.users}/${user.id}/${AppRoutes.userEdit}',
                                extra: {'user': user, 'controller': controller},
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outlined, size: 20),
                            color: TravelAppColors.textSecondary,
                            tooltip: 'Delete User',
                            onPressed: () async {
                              showDeleteUserDialog(context, user.name).then((confirmed) {
                                if (confirmed == true) {
                                  controller.deleteUser(user.id);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.account_circle_outlined, size: 20),
                            color: TravelAppColors.textSecondary,
                            tooltip: 'View User',
                            onPressed: () => _navigateToUser(context, user, controller),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _navigateToUser(
    BuildContext context,
    Client user,
    UsersController controller,
  ) {
    context.go(
      '${AppRoutes.users}/${user.id}',
      extra: {'user': user, 'controller': controller},
    );
  }
}

