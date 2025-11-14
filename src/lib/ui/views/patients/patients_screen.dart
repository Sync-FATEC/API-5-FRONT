// lib/ui/views/patients/patients_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../viewmodels/patients_viewmodel.dart';
import '../users/users_management_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showUserRegistrationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cadastro de Usuário'),
          content: const Text('Implementar formulário de cadastro aqui'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientsViewModel()..load(),
      child: Consumer<PatientsViewModel>(
        builder: (context, vm, _) => Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  const Header(title: 'Gerenciar Pacientes'),
                ],
              ),
              Positioned(
                top: 160, // Ajuste este valor para posicionar sobre o header
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Cards de ação
                    CustomCard(
                      iconData: Icons.person_add_alt_1_outlined,
                      title: 'Cadastro de pacientes',
                      subtitle: 'Cadastre novos pacientes no sistema',
                      onTap: () {
                        _showUserRegistrationModal(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      iconData: Icons.person_sharp,
                      title: 'Gerenciar pacientes',
                      subtitle: 'Visualize e gerencie pacientes cadastrados',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsersManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavBarWidget(currentIndex: 2),
        ),
      ),
    );
  }
}
