import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class UsersState {
  final bool isLoading;
  final List<User> users;
  final String? errorMessage;

  const UsersState({
    this.isLoading = true,
    this.users = const [],
    this.errorMessage,
  });
}

class UsersController extends ChangeNotifier {
  UsersState _state = const UsersState();
  UsersState get state => _state;

  UsersController() {
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _state = const UsersState(isLoading: true);
    notifyListeners();

    try {
      final users = await CompassService.instance.getUsers();
      _state = UsersState(isLoading: false, users: users);
      notifyListeners();
    } catch (e) {
      _state = UsersState(isLoading: false, errorMessage: 'Failed to fetch users: $e');
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _state = const UsersState(isLoading: true, users: []); // Show loading
    notifyListeners();

    try {
      await CompassService.instance.deleteUser(id);
      await _fetchUsers();
    } catch (e) {
      _state = UsersState(isLoading: false, errorMessage: 'Failed to delete user: $e');
      notifyListeners();
    }
  }

  Future<void> addUser(User user) async {
    _state = const UsersState(isLoading: true, users: []);
    notifyListeners();

    try {
      await CompassService.instance.registerUser(user);
      await _fetchUsers();
    } catch (e) {
      _state = UsersState(isLoading: false, errorMessage: 'Failed to add user: $e');
      notifyListeners();
    }
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersController(),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsersController>();
    final state = controller.state;

    return Scaffold(
      backgroundColor: TravelAppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('General > Users Dashboard', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('User Management', style: TextStyle(color: TravelAppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: TravelAppColors.primary,
                    foregroundColor: TravelAppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showAddUserDialog(context, controller),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add New User', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: TravelAppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(state.errorMessage!, style: const TextStyle(color: TravelAppColors.error, fontWeight: FontWeight.bold)),
              ),

            // Table Container
            Container(
              decoration: BoxDecoration(
                color: TravelAppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TravelAppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter & Search Row
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Manage team members and their account permissions here.', style: TextStyle(color: TravelAppColors.textSecondary)),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search users...',
                                  prefixIcon: const Icon(Icons.search, color: TravelAppColors.textSecondary, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.filter_list, size: 18, color: TravelAppColors.textSecondary),
                              label: const Text('Filters', style: TextStyle(color: TravelAppColors.textPrimary)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: TravelAppColors.border),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: TravelAppColors.divider),
                  
                  // DataTable
                  state.isLoading
                  ? const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
                  : state.users.isEmpty 
                    ? const Padding(padding: EdgeInsets.all(48), child: Center(child: Text('No users found.')))
                    : Theme(
                        data: Theme.of(context).copyWith(dividerColor: TravelAppColors.divider),
                        child: DataTable(
                          headingTextStyle: const TextStyle(color: TravelAppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
                          columnSpacing: 48,
                          horizontalMargin: 24,
                          columns: const [
                            DataColumn(label: Text('USER NAME')),
                            DataColumn(label: Text('ROLE')),
                            DataColumn(label: Text('EMAIL ADDRESS')),
                            DataColumn(label: Text('STATUS / ID')),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          rows: state.users.map((user) => _buildTableRow(context, user, controller)).toList(),
                        ),
                      ),
                  
                  // Pagination Footer
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Showing 1-${state.users.length} of ${state.users.length} users', style: const TextStyle(color: TravelAppColors.textSecondary, fontSize: 13)),
                        Row(
                          children: [
                            const IconButton(icon: Icon(Icons.chevron_left, size: 20), onPressed: null),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: TravelAppColors.primary, borderRadius: BorderRadius.circular(4)),
                              child: const Text('1', style: TextStyle(color: TravelAppColors.surface, fontWeight: FontWeight.bold)),
                            ),
                            const IconButton(icon: Icon(Icons.chevron_right, size: 20), onPressed: null),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildTableRow(BuildContext context, User user, UsersController controller) {
    String roleName = 'Client';
    Color roleColor = TravelAppColors.info;
    
    if (user.role == UserRole.travelAgent) {
      roleName = 'Travel Agent';
      roleColor = TravelAppColors.accentGoldDark;
    }

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: TravelAppColors.primaryLight,
                child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12, color: TravelAppColors.surface, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: TravelAppColors.primary)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(roleName, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ),
        DataCell(Text(user.email, style: const TextStyle(color: TravelAppColors.textSecondary))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, color: TravelAppColors.success, size: 8),
                  SizedBox(width: 6),
                  Text('Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
              Text('ID: ${user.id.substring(0, user.id.length > 6 ? 6 : user.id.length)}', style: const TextStyle(color: TravelAppColors.textSecondary, fontSize: 11)),
            ],
          )
        ),
        DataCell(
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: TravelAppColors.textSecondary, size: 20)),
              IconButton(
                onPressed: () => controller.deleteUser(user.id), 
                icon: const Icon(Icons.delete_outline, color: TravelAppColors.error, size: 20),
              ),
            ],
          )
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context, UsersController controller) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Mock User', style: TextStyle(color: TravelAppColors.primary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: pwdCtrl, decoration: const InputDecoration(labelText: 'Initial Password')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel', style: TextStyle(color: TravelAppColors.textSecondary))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TravelAppColors.primary, foregroundColor: TravelAppColors.surface),
              onPressed: () {
                final newUser = Client(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                  password: pwdCtrl.text,
                );
                controller.addUser(newUser);
                Navigator.pop(context);
              },
              child: const Text('Save User'),
            ),
          ],
        );
      },
    );
  }
}
