import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class RoleGate extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final String? roleOverride; // usado em testes

  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.roleOverride,
  });

  bool _isAllowed(String? role) {
    if (role == null || role.isEmpty) return false;
    final r = role.toUpperCase();
    return allowedRoles.map((e) => e.toUpperCase()).contains(r);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final role = roleOverride ?? userProvider.apiUserData?.role;
        if (_isAllowed(role)) {
          return child;
        }
        return const _UnauthorizedScreen();
      },
    );
  }
}

class _UnauthorizedScreen extends StatelessWidget {
  const _UnauthorizedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Acesso não autorizado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você não possui permissão para acessar esta funcionalidade.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}