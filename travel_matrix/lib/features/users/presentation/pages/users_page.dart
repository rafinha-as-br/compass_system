import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service.dart';

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
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (state.errorMessage != null)
              Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Card(
                      child: ListView.separated(
                        itemCount: state.users.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(user.role == UserRole.travelAgent ? Icons.support_agent : Icons.person),
                            ),
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${user.email} • ${user.role.name.toUpperCase()}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => controller.deleteUser(user.id),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
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
          title: const Text('Add Mock User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: pwdCtrl, decoration: const InputDecoration(labelText: 'Initial Password')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
