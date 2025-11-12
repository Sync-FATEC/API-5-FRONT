// lib/ui/views/patients/patients_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../viewmodels/patients_viewmodel.dart';

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientsViewModel()..load(),
      child: Consumer<PatientsViewModel>(
        builder: (context, vm, _) => Scaffold(
          body: Stack(
            children: [
              const Header(title: 'PACIENTES', subtitle: 'CLÍNICA'),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por nome ou e-mail',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onSubmitted: (txt) => vm.load(query: txt.trim()),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Buscar',
                            icon: const Icon(Icons.search),
                            onPressed: () => vm.load(query: _searchCtrl.text.trim()),
                          ),
                          IconButton(
                            tooltip: 'Atualizar',
                            icon: const Icon(Icons.refresh),
                            onPressed: () => vm.load(query: vm.query),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => vm.load(query: vm.query),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (vm.isLoading)
                              const Center(child: CircularProgressIndicator()),
                            if (vm.error != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
                              ),
                            ...vm.items.map((p) => CustomCard(
                                  iconData: Icons.person,
                                  title: (p['name'] ?? p['nome'] ?? 'Sem nome').toString(),
                                  subtitle: (p['email'] ?? 'Sem e-mail').toString(),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Detalhes do Paciente'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('ID: ${(p['id'] ?? '').toString()}'),
                                            Text('Nome: ${(p['name'] ?? p['nome'] ?? '').toString()}'),
                                            Text('E-mail: ${(p['email'] ?? '').toString()}'),
                                            if ((p['phone'] ?? '').toString().isNotEmpty)
                                              Text('Telefone: ${(p['phone'] ?? '').toString()}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Fechar'),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ),
                      ),
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

