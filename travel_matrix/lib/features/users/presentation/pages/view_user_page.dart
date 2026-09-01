import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/confirmation_dialog.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

import '../view_models/client_status_view_model.dart';

class ViewUserPage extends StatelessWidget {
  final UserClientViewModel user;

  const ViewUserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<UsersController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l10n.backToUsersButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
                context.go(AppRoutes.users);
              } else {
                context.go(AppRoutes.users);
              }
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: Text(l10n.editUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.go(
                  '${AppRoutes.users}/${user.localId}/${AppRoutes.userEdit}',
                  extra: {'user': user, 'controller': controller},
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: _buildSidebar(theme, l10n),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildMainContent(theme, controller, context, l10n),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSidebar(theme, l10n),
                  const SizedBox(height: 24),
                  _buildMainContent(theme, controller, context, l10n),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme, AppLocalizations l10n) {
    final isActive = user.status.status is ActiveStatusViewModel;
    final onSurfaceMuted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final statusColor = isActive ? theme.semanticColors.success : theme.colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 40,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            user.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              color: onSurfaceMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle_outline : Icons.highlight_off,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? l10n.activeStatusLabel : l10n.inactiveStatusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildInfoItem(theme, l10n.phoneLabel.toUpperCase(), user.phoneNumber),
          const SizedBox(height: 16),
          _buildInfoItem(theme, l10n.cpfLabel, user.cpf),
          const SizedBox(height: 16),
          _buildInfoItem(
            theme,
            l10n.sexFieldLabel.toUpperCase(),
            user.sex == 'M'
                ? l10n.maleGenderLabel
                : user.sex == 'F'
                    ? l10n.femaleGenderLabel
                    : l10n.otherOptionLabel,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(ThemeData theme, UsersController controller, BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTravelHistory(theme, l10n),
        const SizedBox(height: 24),
        _buildSecurityActions(theme, controller, context, l10n),
        const SizedBox(height: 24),
        _buildTravelStats(theme, l10n),
      ],
    );
  }

  Widget _buildTravelHistory(ThemeData theme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.travelHistoryTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          if (user.travels.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(l10n.noTravelsForUserMessage),
              ),
            )
          else
            DataTable(
              headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
              columns: [
                DataColumn(label: Text(l10n.travelNameColumn.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                DataColumn(label: Text(l10n.destinationLabel.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                DataColumn(label: Text(l10n.statusColumn.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                DataColumn(label: Text(l10n.startDateLabel.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
              ],
              rows: user.travels.map((travel) {
                return DataRow(
                  cells: [
                    DataCell(Text(travel.travelName, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(travel.destination, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                    DataCell(_buildStatusBadge(theme, travel.status)),
                    DataCell(Text('${travel.startDate.month}/${travel.startDate.day}/${travel.startDate.year}', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'completed':
        color = theme.semanticColors.success;
        break;
      case 'upcoming':
        color = theme.colorScheme.primary;
        break;
      case 'cancelled':
        color = theme.colorScheme.error;
        break;
      default:
        color = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSecurityActions(ThemeData theme, UsersController controller, BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.securityActionsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  theme: theme,
                  title: l10n.resetPasswordActionTitle,
                  description: l10n.resetPasswordActionDescription,
                  icon: Icons.key_outlined,
                  iconColor: theme.colorScheme.primary,
                  onTap: () async {
                    final success = await controller.resetPassword(user.localId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? l10n.resetPasswordSuccessMessage : l10n.resetPasswordFailureMessage)),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  theme: theme,
                  title: l10n.forceLogoutActionTitle,
                  description: l10n.forceLogoutActionDescription,
                  icon: Icons.power_settings_new,
                  iconColor: theme.colorScheme.error,
                  onTap: () async {
                    final confirmed = await showConfirmationDialog(
                      context,
                      title: l10n.forceLogoutConfirmTitle,
                      message: l10n.forceLogoutConfirmMessage,
                      confirmLabel: l10n.confirmActionButton,
                      cancelLabel: l10n.cancelActionButton,
                    );
                    if (confirmed != true || !context.mounted) return;

                    final success = await controller.forceLogout(user.localId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? l10n.forceLogoutSuccessMessage : l10n.forceLogoutFailureMessage)),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required ThemeData theme,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelStats(ThemeData theme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.travelStatsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(theme, l10n.totalTravels.toUpperCase(), user.stats.totalTravels),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(theme, l10n.uniqueDestinationsStatLabel, user.stats.uniqueDestinationsCount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
