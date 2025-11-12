import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarWidget({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Papel do usuário
        final role = userProvider.apiUserData?.role.toUpperCase() ?? '';

        // Configuração específica para COORDENADOR_AGENDA (Gerente de Agendamentos)
        if (role == 'COORDENADOR_AGENDA') {
          final routes = <String>[
            '/appointments',
            '/exam-types',
            '/patients',
            '/profile',
          ];

          final items = const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'AGENDAMENTOS'),
            BottomNavigationBarItem(icon: Icon(Icons.biotech), label: 'EXAMES'),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'PACIENTES'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'CONTA'),
          ];

          return BottomNavigationBar(
            currentIndex: currentIndex.clamp(0, items.length - 1),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              if (index != currentIndex) {
                Navigator.pushReplacementNamed(context, routes[index]);
              }
            },
            items: items,
          );
        }

        // Comportamento padrão existente (HOME/PEDIDOS/ALERTAS/GESTÃO/[USUÁRIOS]/PERFIL)
        final userRole = role.toLowerCase();
        final showUsersTab = userRole == 'admin' || userRole == 'supervisor';

        final routes = showUsersTab
            ? [
                '/home',
                '/orders',
                '/alerts',
                '/management',
                '/users',
                '/profile',
              ]
            : ['/home', '/orders', '/alerts', '/management', '/profile'];

        int adjustedIndex = currentIndex;
        if (!showUsersTab && currentIndex >= 4) {
          adjustedIndex = currentIndex - 1;
        }

        final items = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'PEDIDOS',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            label: 'ALERTAS',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'GESTÃO',
          ),
          if (showUsersTab)
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1),
              label: 'USUÁRIOS',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'PERFIL',
          ),
        ];

        return BottomNavigationBar(
          currentIndex: adjustedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index != adjustedIndex) {
              Navigator.pushReplacementNamed(context, routes[index]);
            }
          },
          items: items,
        );
      },
    );
  }
}
