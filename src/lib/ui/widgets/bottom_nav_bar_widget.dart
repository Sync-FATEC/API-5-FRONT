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
        // Verificar se o usuário é admin ou supervisor
        final userRole = userProvider.apiUserData?.role.toLowerCase() ?? '';
        final showUsersTab = userRole == 'admin' || userRole == 'supervisor';

        // Lista de rotas baseada na permissão
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

        // Ajustar currentIndex se o usuário não tem permissão para "users"
        int adjustedIndex = currentIndex;
        if (!showUsersTab && currentIndex >= 4) {
          adjustedIndex = currentIndex - 1;
        }

        // Lista de itens da barra de navegação
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
          // Só adiciona o item "USUÁRIOS" se for admin ou supervisor
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
