import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/view_user_page.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Resolves the user to show in [ViewUserPage] from the shared
/// [UsersController]'s reactive state (by [userId]) instead of a one-shot
/// fetch — a `Future` cached in `initState` would stay frozen with the
/// pre-edit user when go_router reuses this widget's State navigating back
/// from [EditUserPage], showing stale data even after the controller's list
/// was refreshed post-save.
class UserViewWrapper extends StatefulWidget {
  final String userId;
  final UserClientViewModel? initialUser;
  final UsersController? initialController;

  const UserViewWrapper({
    super.key,
    required this.userId,
    this.initialUser,
    this.initialController,
  });

  @override
  State<UserViewWrapper> createState() => _UserViewWrapperState();
}

class _UserViewWrapperState extends State<UserViewWrapper> {
  late final UsersController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.initialController == null;
    _controller = widget.initialController ?? UsersController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  UserClientViewModel? _findUser(List<UserClientViewModel> users) {
    for (final user in users) {
      if (user.backEndId == widget.userId) return user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<UsersController>(
        builder: (context, controller, _) {
          final state = controller.state;
          final user = _findUser(state.users) ??
              (state.isLoading ? widget.initialUser : null);

          if (user != null) {
            return ViewUserPage(user: user);
          }

          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: Text(l10n.userNotFoundTitle)),
            body: Center(
              child: Text(l10n.userNotFoundMessage),
            ),
          );
        },
      ),
    );
  }
}
