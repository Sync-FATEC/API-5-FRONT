// lib/ui/views/appointments/widgets/appointment_form_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_modal.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';
import '../../../../data/enums/appointment_enums.dart';
import '../../../viewmodels/appointments_viewmodel.dart';

class AppointmentFormModal extends StatefulWidget {
  final AppointmentModel? initial;
  const AppointmentFormModal({super.key, this.initial});

  static Future<bool?> show(BuildContext context, {AppointmentModel? initial}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppointmentFormModal(initial: initial),
    );
  }

  @override
  State<AppointmentFormModal> createState() => _AppointmentFormModalState();
}

class _AppointmentFormModalState extends State<AppointmentFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _patientCtrl = TextEditingController();
  final _examTypeCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  AppointmentStatus _status = AppointmentStatus.agendado;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _patientCtrl.text = i.patientId;
      _examTypeCtrl.text = i.examTypeId;
      final dt = i.dateTime.toLocal();
      _dateCtrl.text = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      _timeCtrl.text = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      _notesCtrl.text = i.notes ?? '';
      _status = i.status;
    }
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    _examTypeCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _notesCtrl.dispose();
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
      _dateCtrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      _timeCtrl.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
            TextFormField(
              controller: _patientCtrl,
              decoration: const InputDecoration(labelText: 'Paciente (UUID)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o paciente' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _examTypeCtrl,
              decoration: const InputDecoration(labelText: 'Tipo de Exame (UUID)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o tipo de exame' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(context),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a data' : null,
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
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a hora' : null,
                  ),
                ),
              ],
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
                DropdownMenuItem(value: AppointmentStatus.agendado, child: Text('Agendado')),
                DropdownMenuItem(value: AppointmentStatus.realizado, child: Text('Realizado')),
                DropdownMenuItem(value: AppointmentStatus.cancelado, child: Text('Cancelado')),
              ],
              onChanged: (v) => setState(() => _status = v ?? AppointmentStatus.agendado),
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
                    try {
                      final dateParts = _dateCtrl.text.trim().split('-');
                      final timeParts = _timeCtrl.text.trim().split(':');
                      final localDate = DateTime(
                        int.parse(dateParts[0]),
                        int.parse(dateParts[1]),
                        int.parse(dateParts[2]),
                        int.parse(timeParts[0]),
                        int.parse(timeParts[1]),
                      );
                      final model = AppointmentModel(
                        id: widget.initial?.id,
                        patientId: _patientCtrl.text.trim(),
                        examTypeId: _examTypeCtrl.text.trim(),
                        dateTime: localDate.toUtc(),
                        status: _status,
                        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                      );
                      bool ok;
                      if (widget.initial == null) {
                        ok = await vm.create(model);
                      } else {
                        ok = await vm.update(widget.initial!.id!, model.toJson());
                      }
                      if (ok) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vm.error ?? 'Falha ao salvar agendamento')),
                        );
                      }
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $e')),
                      );
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