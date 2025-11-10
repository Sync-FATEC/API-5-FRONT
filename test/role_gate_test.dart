import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:api2025/ui/widgets/role_gate.dart';
import 'package:api2025/core/providers/user_provider.dart';

void main() {
  group('RoleGate', () {
    Widget _wrapWithProviders(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('permite acesso quando role está na lista permitida', (tester) async {
      final allowed = ['PACIENTE', 'COORDENADOR_AGENDA'];
      final gate = RoleGate(
        allowedRoles: allowed,
        roleOverride: 'PACIENTE',
        child: const Text('Conteúdo permitido'),
      );

      await tester.pumpWidget(_wrapWithProviders(gate));
      expect(find.text('Conteúdo permitido'), findsOneWidget);
      expect(find.text('Acesso não autorizado'), findsNothing);
    });

    testWidgets('bloqueia acesso quando role NÃO está na lista permitida', (tester) async {
      final allowed = ['COORDENADOR_AGENDA'];
      final gate = RoleGate(
        allowedRoles: allowed,
        roleOverride: 'PACIENTE',
        child: const Text('Admin only'),
      );

      await tester.pumpWidget(_wrapWithProviders(gate));
      expect(find.text('Admin only'), findsNothing);
      expect(find.text('Acesso não autorizado'), findsOneWidget);
    });
  });
}