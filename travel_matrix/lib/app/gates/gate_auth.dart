import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/features/auth/presentation/pages/login_page.dart';
import 'package:travel_matrix/features/home/presentation/pages/home_page.dart';

class GateAuth extends StatefulWidget {
  const GateAuth({super.key});

  @override
  State<GateAuth> createState() => _GateAuthState();
}

class _GateAuthState extends State<GateAuth> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await AuthService.instance.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAuthenticated) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
