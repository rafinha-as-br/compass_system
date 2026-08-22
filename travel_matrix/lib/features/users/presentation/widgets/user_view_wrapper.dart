import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/view_user_page.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/features/users/data/user_client_data_source.dart';
import 'package:travel_matrix/features/users/data/user_repository_impl.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

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
  late Future<UserClientViewModel?> _userFuture;
  late final UsersController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.initialController == null;
    _controller = widget.initialController ?? UsersController();
    
    if (widget.initialUser != null) {
      _userFuture = Future.value(widget.initialUser);
    } else {
      _userFuture = _fetchUserById(widget.userId);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<UserClientViewModel?> _fetchUserById(String id) async {
    final useCases = UserUseCases(UserClientRepositoryImpl(UserClientDataSource()));
    final result = await useCases.getUser(id);
    if (result.isSuccess && result.data != null) {
      return UserClientViewModel.fromDomain(user: result.data!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: FutureBuilder<UserClientViewModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(title: Text(l10n.userNotFoundTitle)),
              body: Center(
                child: Text(l10n.userNotFoundMessage),
              ),
            );
          }
          
          return ViewUserPage(user: snapshot.data!);
        },
      ),
    );
  }
}
