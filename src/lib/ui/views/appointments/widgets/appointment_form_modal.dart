// lib/ui/views/appointments/widgets/appointment_form_modal.dart

import 'package:flutter/material.dart';
import 'package:api2025/core/utils/string_utils.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_modal.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';
import '../../../../data/enums/appointment_enums.dart';
import '../../../viewmodels/appointments_viewmodel.dart';

// Opção de Autocomplete (top-level)
class _Option {
  final String id;
  final String label;
  const _Option(this.id, this.label);
}

class AppointmentFormModal extends StatefulWidget {
  final AppointmentModel? initial;
  const AppointmentFormModal({super.key, this.initial});

  static Future<bool?> show(BuildContext context, {AppointmentModel? initial}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Ensure the dialog has access to the same AppointmentsViewModel instance
        // that is provided in the calling context. showDialog creates a new
        // route and its BuildContext may not be a descendant of the provider
        // defined in the page, so we explicitly pass the VM into the dialog.
        final vm = Provider.of<AppointmentsViewModel>(context, listen: false);
        return ChangeNotifierProvider<AppointmentsViewModel>.value(
          value: vm,
          child: AppointmentFormModal(initial: initial),
        );
      },
    );
  }

  @override
  State<AppointmentFormModal> createState() => _AppointmentFormModalState();
}

class _AppointmentFormModalState extends State<AppointmentFormModal> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  String? _selectedExamTypeId;
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _retiradaDateCtrl = TextEditingController();
  final _retiradaTimeCtrl = TextEditingController();
  bool _retiradaCleared = false;
  AppointmentStatus _status = AppointmentStatus.agendado;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _selectedPatientId = i.patientId;
      _selectedExamTypeId = i.examTypeId;
      final dt = i.dateTime.toLocal();
      _dateCtrl.text =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      _timeCtrl.text =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      _notesCtrl.text = i.notes ?? '';
      _status = i.status;
      if (i.withdrawalDate != null) {
        final rd = i.withdrawalDate!.toLocal();
        _retiradaDateCtrl.text =
            '${rd.day.toString().padLeft(2, '0')}/${rd.month.toString().padLeft(2, '0')}/${rd.year}';
        _retiradaTimeCtrl.text =
            '${rd.hour.toString().padLeft(2, '0')}:${rd.minute.toString().padLeft(2, '0')}';
      }
    }
    // Carrega pacientes para o dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AppointmentsViewModel>(context, listen: false);
      vm.loadPatients();
    });
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _notesCtrl.dispose();
    _retiradaDateCtrl.dispose();
    _retiradaTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      _dateCtrl.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      _timeCtrl.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickRetiradaDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 0));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      _retiradaDateCtrl.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      _retiradaCleared = false;
      setState(() {});
    }
  }

  Future<void> _pickRetiradaTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      _retiradaTimeCtrl.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _retiradaCleared = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppointmentsViewModel>(context, listen: false);
    return CustomModal(
      title: widget.initial == null ? 'Novo Agendamento' : 'Editar Agendamento',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AppointmentsViewModel>(
              builder: (context, vm, _) {
                final options =
                    vm.patients
                        .map(
                          (p) => _Option(
                            (p['id'] ?? '').toString(),
                            (p['name'] ?? p['nome'] ?? 'Sem nome').toString(),
                          ),
                        )
                        .toList()
                      ..sort(
                        (a, b) => a.label.toLowerCase().compareTo(
                          b.label.toLowerCase(),
                        ),
                      );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Autocomplete<_Option>(
                      displayStringForOption: (o) => o.label,
                      optionsBuilder: (te) {
                        return StringUtils.filterByQuery<_Option>(
                          options,
                          te.text,
                          (o) => o.label,
                        );
                      },
                      fieldViewBuilder:
                          (context, textController, focusNode, onSubmitted) {
                            // Preenche campo com o nome atual ao editar
                            if (_selectedPatientId != null &&
                                textController.text.isEmpty) {
                              final current = options.firstWhere(
                                (o) => o.id == _selectedPatientId,
                                orElse: () => const _Option('', ''),
                              );
                              if (current.id.isNotEmpty)
                                textController.text = current.label;
                            }
                            return TextFormField(
                              controller: textController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Paciente',
                              ),
                            );
                          },
                      onSelected: (o) =>
                          setState(() => _selectedPatientId = o.id),
                    ),
                    // Validação extra baseada na seleção
                    Builder(
                      builder: (context) {
                        return Visibility(
                          visible: false,
                          child: TextFormField(
                            validator: (_) =>
                                (_selectedPatientId == null ||
                                    _selectedPatientId!.isEmpty)
                                ? 'Informe o paciente'
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<AppointmentsViewModel>(
              builder: (context, vm, _) {
                final options =
                    vm.examTypes
                        .map(
                          (e) => _Option(
                            (e.id ?? '').toString(),
                            (e.name ?? 'Sem nome').toString(),
                          ),
                        )
                        .toList()
                      ..sort(
                        (a, b) => a.label.toLowerCase().compareTo(
                          b.label.toLowerCase(),
                        ),
                      );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Autocomplete<_Option>(
                      displayStringForOption: (o) => o.label,
                      optionsBuilder: (te) {
                        return StringUtils.filterByQuery<_Option>(
                          options,
                          te.text,
                          (o) => o.label,
                        );
                      },
                      fieldViewBuilder:
                          (context, textController, focusNode, onSubmitted) {
                            if (_selectedExamTypeId != null &&
                                textController.text.isEmpty) {
                              final current = options.firstWhere(
                                (o) => o.id == _selectedExamTypeId,
                                orElse: () => const _Option('', ''),
                              );
                              if (current.id.isNotEmpty)
                                textController.text = current.label;
                            }
                            return TextFormField(
                              controller: textController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de Exame',
                              ),
                            );
                          },
                      onSelected: (o) =>
                          setState(() => _selectedExamTypeId = o.id),
                    ),
                    Builder(
                      builder: (context) {
                        return Visibility(
                          visible: false,
                          child: TextFormField(
                            validator: (_) =>
                                (_selectedExamTypeId == null ||
                                    _selectedExamTypeId!.isEmpty)
                                ? 'Informe o tipo de exame'
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(context),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe a data'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _timeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Hora',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.watch_later),
                        onPressed: () => _pickTime(context),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe a hora'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Campo opcional de retirada de material
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _retiradaDateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Data de Retirada (opcional)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickRetiradaDate(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _retiradaTimeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Hora de Retirada (opcional)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.watch_later),
                        onPressed: () => _pickRetiradaTime(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _retiradaDateCtrl.clear();
                  _retiradaTimeCtrl.clear();
                  _retiradaCleared = true;
                  setState(() {});
                },
                child: const Text('Remover retirada'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Observações'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppointmentStatus>(
              value: _status,
              items: const [
                DropdownMenuItem(
                  value: AppointmentStatus.agendado,
                  child: Text('Agendado'),
                ),
                DropdownMenuItem(
                  value: AppointmentStatus.realizado,
                  child: Text('Realizado'),
                ),
                DropdownMenuItem(
                  value: AppointmentStatus.cancelado,
                  child: Text('Cancelado'),
                ),
              ],
              onChanged: (v) =>
                  setState(() => _status = v ?? AppointmentStatus.agendado),
              decoration: const InputDecoration(labelText: 'Status'),
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
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (_selectedPatientId == null ||
                        _selectedPatientId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Informe o paciente')),
                      );
                      return;
                    }
                    if (_selectedExamTypeId == null ||
                        _selectedExamTypeId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Informe o tipo de exame'),
                        ),
                      );
                      return;
                    }
                    try {
                      final dateParts = _dateCtrl.text.trim().split('/');
                      final timeParts = _timeCtrl.text.trim().split(':');
                      final localDate = DateTime(
                        int.parse(dateParts[2]), // ano
                        int.parse(dateParts[1]), // mês
                        int.parse(dateParts[0]), // dia
                        int.parse(timeParts[0]),
                        int.parse(timeParts[1]),
                      );
                      DateTime? retiradaLocal;
                      if (_retiradaDateCtrl.text.trim().isNotEmpty &&
                          _retiradaTimeCtrl.text.trim().isNotEmpty) {
                        final rDateParts = _retiradaDateCtrl.text.trim().split(
                          '/',
                        );
                        final rTimeParts = _retiradaTimeCtrl.text.trim().split(
                          ':',
                        );
                        retiradaLocal = DateTime(
                          int.parse(rDateParts[2]), // ano
                          int.parse(rDateParts[1]), // mês
                          int.parse(rDateParts[0]), // dia
                          int.parse(rTimeParts[0]),
                          int.parse(rTimeParts[1]),
                        );
                      }
                      final model = AppointmentModel(
                        id: widget.initial?.id,
                        patientId: _selectedPatientId!,
                        examTypeId: _selectedExamTypeId!,
                        dateTime: localDate.toUtc(),
                        status: _status,
                        notes: _notesCtrl.text.trim().isEmpty
                            ? null
                            : _notesCtrl.text.trim(),
                        withdrawalDate: retiradaLocal?.toUtc(),
                      );
                      bool ok;
                      if (widget.initial == null) {
                        ok = await vm.create(model);
                      } else {
                        final fields = model.toJson();
                        if (_retiradaCleared) {
                          fields['dataRetirada'] = null;
                        }
                        ok = await vm.update(widget.initial!.id!, fields);
                      }
                      if (ok) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              vm.error ?? 'Falha ao salvar agendamento',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
