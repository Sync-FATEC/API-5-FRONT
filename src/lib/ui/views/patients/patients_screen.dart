// lib/ui/views/patients/patients_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_modal.dart';
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

  void _showPatientRegistrationModal(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Controllers para os campos do formulário
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    CustomModal.show(
      context: context,
      title: 'Cadastro de Paciente',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomModalTextField(
              label: 'Nome',
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomModalTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O paciente receberá um email para definir sua senha',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomModalButton(
              text: 'Cadastrar Paciente',
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await userProvider.createUser(
                      nameController.text,
                      emailController.text,
                      'PACIENTE', // Role fixada como PACIENTE
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paciente cadastrado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao cadastrar paciente: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
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
              Column(children: [const Header(title: 'Gerenciar Pacientes')]),
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
                        _showPatientRegistrationModal(context);
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
