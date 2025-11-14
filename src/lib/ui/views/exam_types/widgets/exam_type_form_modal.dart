// lib/ui/views/exam_types/widgets/exam_type_form_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_modal.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/exam_type_model.dart';
import '../../../viewmodels/exam_types_viewmodel.dart';

class ExamTypeFormModal extends StatefulWidget {
  final ExamTypeModel? initial;
  const ExamTypeFormModal({super.key, this.initial});

  static Future<bool?> show(BuildContext context, {ExamTypeModel? initial}) {
    // Garante acesso ao ExamTypesViewModel dentro do modal
    final vm = Provider.of<ExamTypesViewModel>(context, listen: false);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: ExamTypeFormModal(initial: initial),
      ),
    );
  }

  @override
  State<ExamTypeFormModal> createState() => _ExamTypeFormModalState();
}

class _ExamTypeFormModalState extends State<ExamTypeFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _nameCtrl.text = i.name;
      _descCtrl.text = i.description ?? '';
      _durationCtrl.text = i.estimatedDuration.toString();
      _prepCtrl.text = i.requiredPreparation ?? '';
      _isActive = i.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _prepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ExamTypesViewModel>(context, listen: false);
    return CustomModal(
      title: widget.initial == null ? 'Novo Tipo de Exame' : 'Editar Tipo de Exame',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationCtrl,
              decoration: const InputDecoration(labelText: 'Duração estimada (min)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Informe um valor válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prepCtrl,
              decoration: const InputDecoration(labelText: 'Preparo necessário'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isActive,
              title: const Text('Ativo'),
              activeColor: AppColors.bluePrimary,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _isSubmitting = true);
                          try {
                            final duration = int.tryParse(_durationCtrl.text.trim()) ?? 0;
                            final model = ExamTypeModel(
                              id: widget.initial?.id,
                              name: _nameCtrl.text.trim(),
                              description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
                              estimatedDuration: duration,
                              requiredPreparation: _prepCtrl.text.trim().isEmpty ? null : _prepCtrl.text.trim(),
                              isActive: _isActive,
                            );

                            bool ok = false;
                            if (widget.initial == null) {
                              ok = await vm.create(model);
                            } else {
                              final id = widget.initial?.id;
                              if (id == null || id.isEmpty) {
                                vm.select(null);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ID do tipo de exame inválido para edição')),
                                );
                              } else {
                                // Enviar apenas campos atualizáveis (sem id/isActive)
                                final fields = {
                                  'nome': model.name,
                                  'descricao': model.description,
                                  'duracaoEstimada': model.estimatedDuration,
                                  'preparoNecessario': model.requiredPreparation,
                                };
                                ok = await vm.update(id, fields);
                              }
                            }

                            if (ok) {
                              if (!mounted) return;
                              Navigator.of(context).pop(true);
                            } else if (vm.error != null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.error!)),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao salvar: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _isSubmitting = false);
                          }
                        },
                  child: Text(_isSubmitting ? 'Salvando...' : 'Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}