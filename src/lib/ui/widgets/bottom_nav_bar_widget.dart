import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarWidget({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  static const List<String> _routes = [
    '/home',
    '/orders',
    '/alerts',
    '/management',
    '/users',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index != currentIndex) {
          Navigator.pushReplacementNamed(context, _routes[index]);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'HOME',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'PEDIDOS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning_amber_outlined),
          label: 'ALERTAS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'GESTÃO',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_1),
          label: 'USUÁRIOS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'PERFIL',
        ),
      ],
    );
  }
}
}
