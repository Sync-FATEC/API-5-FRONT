// lib/ui/views/exam_types/exam_types_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/add_floating_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/exam_types_viewmodel.dart';
import 'widgets/exam_type_form_modal.dart';

class ExamTypesScreen extends StatefulWidget {
  const ExamTypesScreen({super.key});

  @override
  State<ExamTypesScreen> createState() => _ExamTypesScreenState();
}

class _ExamTypesScreenState extends State<ExamTypesScreen> {
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
              const Header(title: 'TIPOS DE EXAME', subtitle: 'GERENCIAMENTO'),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: RefreshIndicator(
                  onRefresh: () => vm.load(isActive: true),
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
                      ...vm.items.map(
                        (e) => CustomCard(
                          iconData: Icons.biotech,
                          title: e.name,
                          subtitle: e.description ?? 'Sem descrição',
                          onTap: () async {
                            final updated = await ExamTypeFormModal.show(context, initial: e);
                            if (updated == true) vm.load(isActive: true);
                          },
                          showArrow: false,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.bluePrimary),
                                onPressed: () async {
                                  final updated = await ExamTypeFormModal.show(context, initial: e);
                                  if (updated == true) vm.load(isActive: true);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Inativar tipo de exame?'),
                                      content: const Text('Esta ação realiza um soft delete.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && e.id != null) {
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
          bottomNavigationBar: const BottomNavBarWidget(currentIndex: 3),
        ),
      ),
    );
  }
}