// lib/ui/views/exam_types/exam_types_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/add_floating_button.dart';
import '../../widgets/custom_card.dart';
// Removido BottomNavBar conforme novo layout
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/exam_types_viewmodel.dart';
import 'widgets/exam_type_form_modal.dart';
import 'widgets/exam_type_detail_modal.dart';
import '../../widgets/bottom_nav_bar_widget.dart';

class ExamTypesScreen extends StatefulWidget {
  const ExamTypesScreen({super.key});

  @override
  State<ExamTypesScreen> createState() => _ExamTypesScreenState();
}

class _ExamTypesScreenState extends State<ExamTypesScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamTypesViewModel()..load(isActive: true),
      child: Consumer<ExamTypesViewModel>(
        builder: (context, vm, _) => Scaffold(
          floatingActionButton: AddFloatingButton(
            heroTag: 'addExamType',
            onPressed: () async {
              final created = await ExamTypeFormModal.show(context);
              if (created == true) {
                vm.load(isActive: true);
              }
            },
          ),
          body: Stack(
            children: [
              const Header(title: 'TIPOS DE EXAME'),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        children: [
                          // Campo de busca
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.bluePrimary.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por nome',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.bluePrimary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (txt) =>
                                  vm.load(query: txt.trim(), isActive: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => vm.load(isActive: true),
                        child:
                            !vm.isLoading &&
                                vm.error == null &&
                                vm.items.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.biotech,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum tipo de exame encontrado',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'com esse filtro',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  if (vm.isLoading)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  if (vm.error != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        vm.error!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ...vm.items.map(
                                    (e) => CustomCard(
                                      iconData: Icons.biotech,
                                      title: e.name,
                                      subtitle:
                                          e.description ?? 'Sem descrição',
                                      onTap: () async {
                                        await ExamTypeDetailModal.show(
                                          context,
                                          e,
                                        );
                                      },
                                      showArrow: false,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: AppColors.bluePrimary,
                                            ),
                                            tooltip: 'Editar tipo de exame',
                                            onPressed: () async {
                                              final updated =
                                                  await ExamTypeFormModal.show(
                                                    context,
                                                    initial: e,
                                                  );
                                              if (updated == true)
                                                vm.load(isActive: true);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.red,
                                            ),
                                            tooltip: 'Inativar tipo de exame',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text(
                                                    'Inativar tipo de exame?',
                                                  ),
                                                  content: const Text(
                                                    'Esta ação realiza um soft delete.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Confirmar',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true &&
                                                  e.id != null) {
                                                await vm.remove(e.id!);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavBarWidget(currentIndex: 1),
        ),
      ),
    );
  }
}
