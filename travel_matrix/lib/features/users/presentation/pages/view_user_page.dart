import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

import '../view_models/client_status_view_model.dart';

class ViewUserPage extends StatelessWidget {
  final UserClientViewModel user;

  const ViewUserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<UsersController>();

    return Scaffold(
      backgroundColor: TravelAppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to Users'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TravelAppColors.textPrimary,
              side: BorderSide(color: TravelAppColors.border),
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
              label: const Text('Edit User'),
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
                    child: _buildSidebar(theme),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildMainContent(theme, controller, context),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSidebar(theme),
                  const SizedBox(height: 24),
                  _buildMainContent(theme, controller, context),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    final isActive = user.status.status is ActiveStatusViewModel;

    return Container(
      decoration: BoxDecoration(
        color: TravelAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: TravelAppColors.border)),
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
              color: TravelAppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              color: TravelAppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? TravelAppColors.success.withValues(alpha: 0.1)
                  : TravelAppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle_outline : Icons.highlight_off,
                  size: 14,
                  color: isActive ? TravelAppColors.success : TravelAppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? TravelAppColors.success : TravelAppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildInfoItem('PHONE', user.phoneNumber),
          const SizedBox(height: 16),
          _buildInfoItem('CPF', user.cpf),
          const SizedBox(height: 16),
          _buildInfoItem('SEX', user.sex == 'M' ? 'Male' : user.sex == 'F' ? 'Female' : 'Other'),
          const SizedBox(height: 16),
          _buildInfoItem('LOCAL ID', user.localId),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TravelAppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: TravelAppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(ThemeData theme, UsersController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTravelHistory(theme),
        const SizedBox(height: 24),
        _buildSecurityActions(theme, controller, context),
        const SizedBox(height: 24),
        _buildTravelStats(theme),
      ],
    );
  }

  Widget _buildTravelHistory(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: TravelAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: TravelAppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Travel History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          if (user.travels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No travels found for this user.'),
              ),
            )
          else
            DataTable(
              headingRowColor: WidgetStateProperty.all(TravelAppColors.background),
              columns: const [
                DataColumn(label: Text('TRAVEL NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TravelAppColors.textSecondary))),
                DataColumn(label: Text('DESTINATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TravelAppColors.textSecondary))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TravelAppColors.textSecondary))),
                DataColumn(label: Text('START DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TravelAppColors.textSecondary))),
              ],
              rows: user.travels.map((travel) {
                return DataRow(
                  cells: [
                    DataCell(Text(travel.travelName, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(travel.destination, style: const TextStyle(color: TravelAppColors.textSecondary))),
                    DataCell(_buildStatusBadge(travel.status)),
                    DataCell(Text('${travel.startDate.month}/${travel.startDate.day}/${travel.startDate.year}', style: const TextStyle(color: TravelAppColors.textSecondary))),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    
    switch (status.toLowerCase()) {
      case 'completed':
        color = TravelAppColors.success;
        bgColor = TravelAppColors.success.withValues(alpha: 0.1);
        break;
      case 'upcoming':
        color = TravelAppColors.primary;
        bgColor = TravelAppColors.primary.withValues(alpha: 0.1);
        break;
      case 'cancelled':
        color = TravelAppColors.error;
        bgColor = TravelAppColors.error.withValues(alpha: 0.1);
        break;
      default:
        color = TravelAppColors.textSecondary;
        bgColor = TravelAppColors.textSecondary.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
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

  Widget _buildSecurityActions(ThemeData theme, UsersController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TravelAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: TravelAppColors.border)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Reset Password',
                  description: 'Send a link to the user\'s email to securely reset their password.',
                  icon: Icons.key_outlined,
                  iconColor: TravelAppColors.primary,
                  onTap: () async {
                    final success = await controller.resetPassword(user.localId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Password reset link sent' : 'Failed to send reset link')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Force Logout',
                  description: 'Immediately terminate all active sessions for this user.',
                  icon: Icons.power_settings_new,
                  iconColor: TravelAppColors.error,
                  onTap: () async {
                    final success = await controller.forceLogout(user.localId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'User sessions terminated' : 'Failed to terminate sessions')),
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
          border: Border.all(color: TravelAppColors.border),
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
              style: const TextStyle(color: TravelAppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelStats(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: TravelAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.fromBorderSide(BorderSide(color: TravelAppColors.border)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel Stats',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('TOTAL TRAVELS', user.stats.totalTravels),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('UNIQUE DESTINATIONS', user.stats.uniqueDestinationsCount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: TravelAppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TravelAppColors.textSecondary,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: TravelAppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
