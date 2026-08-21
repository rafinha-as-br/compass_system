import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/users/presentation/pages/deactivate_user_dialog.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

import '../view_models/client_status_view_model.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final activeLabel = l10n.activeStatusLabel;
    final inactiveLabel = l10n.inactiveStatusLabel;

    // Apply filters
    var filteredUsers = state.users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = true;
      if (_statusFilter == activeLabel) {
        matchesStatus = user.status.status is ActiveStatusViewModel;
      } else if (_statusFilter == inactiveLabel) {
        matchesStatus = user.status.status is! ActiveStatusViewModel;
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
            l10n.clientUsersTitle,
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
                    hintText: l10n.searchUsersHint,
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
                      hint: Text(l10n.statusColumn),
                      value: _statusFilter,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.allStatus)),
                        DropdownMenuItem(value: activeLabel, child: Text(activeLabel)),
                        DropdownMenuItem(value: inactiveLabel, child: Text(inactiveLabel)),
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
                label: Text(l10n.createUser),
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
                          l10n.noClientUsersFoundMessage,
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
    List<UserClientViewModel> users,
    UsersController controller,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
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
                DataColumn(label: Text(l10n.clientNameColumn, style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text(l10n.loginEmailLabel, style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text(l10n.phoneLabel, style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text(l10n.statusColumn, style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
                DataColumn(label: Text(l10n.actionsColumn, style: TextStyle(color: TravelAppColors.textPrimary, fontWeight: FontWeight.w600))),
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
                          color: user.status.status is ActiveStatusViewModel
                              ? TravelAppColors.success.withValues(alpha: 0.1)
                              : TravelAppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.status.status is ActiveStatusViewModel ? Icons.check_circle_outline : Icons.highlight_off,
                              size: 14,
                              color: user.status.status is ActiveStatusViewModel ? TravelAppColors.success : TravelAppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.status.status is ActiveStatusViewModel ? l10n.activeStatusLabel : l10n.inactiveStatusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.status.status is ActiveStatusViewModel
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
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                            color: TravelAppColors.textSecondary,
                            tooltip: l10n.viewUser,
                            onPressed: () => _navigateToUser(context, user, controller),
                          ),
                          IconButton(
                            icon: const Icon(Icons.block, size: 20),
                            color: TravelAppColors.textSecondary,
                            tooltip: l10n.deactivateUserDialogTitle,
                            onPressed: () async {
                              final reason = await showDeactivateUserDialog(context, user.name);
                              if (reason != null) {
                                controller.deactivateUser(user.localId, reason);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
    );
  }

  void _navigateToUser(
    BuildContext context,
    UserClientViewModel user,
    UsersController controller,
  ) {
    context.go(
      '${AppRoutes.users}/${user.localId}',
      extra: {'user': user, 'controller': controller},
    );
  }
}

