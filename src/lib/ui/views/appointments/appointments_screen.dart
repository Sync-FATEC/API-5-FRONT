// lib/ui/views/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/add_floating_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
// Removido BottomNavBar conforme novo layout
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/appointments_viewmodel.dart';
import '../../../data/enums/appointment_enums.dart';
import 'widgets/appointment_form_modal.dart';
import 'widgets/appointment_ui_helpers.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/exam_types_viewmodel.dart';
import '../exam_types/widgets/exam_type_form_modal.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) {
        final userProvider = Provider.of<UserProvider>(ctx, listen: false);
        final role = userProvider.apiUserData?.role.toUpperCase() ?? '';
        final isPatient = role == 'PACIENTE';
        final patientId = isPatient ? userProvider.apiUserData?.id : null;

        final vm = AppointmentsViewModel();
        vm.initialize();
        vm.loadPatients();
        vm.load(patientId: patientId);
        return vm;
      },
      child: Consumer<AppointmentsViewModel>(
        builder: (context, vm, _) {
          final role = Provider.of<UserProvider>(context, listen: false).apiUserData?.role.toUpperCase() ?? '';
          final isCoordinator = role == 'COORDENADOR_AGENDA';
          final isPatient = role == 'PACIENTE';
          return Scaffold(
          floatingActionButton: isCoordinator
              ? AddFloatingButton(
                  heroTag: 'addAppointment',
                  onPressed: () async {
                    final created = await AppointmentFormModal.show(context);
                    if (created == true) vm.load();
                  },
                )
              : null,
          body: Stack(
            children: [
              const Header(title: 'AGENDAMENTOS', subtitle: 'CLÍNICA'),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  children: [
                    // Filtros simples
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButton<AppointmentStatus?>(
                              value: vm.filterStatus,
                              hint: const Text('Status'),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Todos')),
                                DropdownMenuItem(value: AppointmentStatus.agendado, child: Text('Agendado')),
                                DropdownMenuItem(value: AppointmentStatus.realizado, child: Text('Realizado')),
                                DropdownMenuItem(value: AppointmentStatus.cancelado, child: Text('Cancelado')),
                              ],
                              onChanged: (v) => vm.load(status: v),
                            ),
                          ),
                          Tooltip(
                            message: 'Atualizar lista',
                            child: IconButton(
                              onPressed: () => vm.load(status: vm.filterStatus),
                              icon: const Icon(Icons.refresh),
                            ),
                          ),
                          // Removido botão de ações de exame do topo conforme novo requisito
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => vm.load(status: vm.filterStatus),
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
                            ...vm.items.map((a) => CustomCard(
                                  iconData: Icons.event,
                                  title: 'Paciente: ${vm.patientNameById(a.patientId)}',
                                  subtitle:
                                      () {
                                        final base = 'Exame: ${vm.examTypeNameById(a.examTypeId)} • ${DateFormat('dd/MM/yyyy HH:mm').format(a.dateTime.toLocal())}';
                                        if (a.withdrawalDate != null) {
                                          final r = DateFormat('dd/MM/yyyy HH:mm').format(a.withdrawalDate!.toLocal());
                                          return '$base • Retirada: $r';
                                        }
                                        return base;
                                      }(),
                                  onTap: () {
                                    if (isCoordinator) {
                                      AppointmentFormModal.show(context, initial: a).then((edited) {
                                        if (edited == true) vm.load(status: vm.filterStatus);
                                      });
                                    }
                                  },
                                  showArrow: !isCoordinator,
                                  trailing: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppointmentUIHelpers.statusColor(a.status).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppointmentUIHelpers.statusColor(a.status),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          AppointmentUIHelpers.statusLabel(a.status),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppointmentUIHelpers.statusColor(a.status),
                                          ),
                                        ),
                                      ),
                                      if (isCoordinator) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: [
                                            Tooltip(
                                              message: 'Baixar recibo (PDF)',
                                              child: IconButton(
                                                icon: const Icon(Icons.picture_as_pdf, color: AppColors.bluePrimary),
                                                onPressed: () async {
                                                  final tempPath = '${Directory.systemTemp.path}/recibo_${a.id ?? 'novo'}.pdf';
                                                  final err = await vm.downloadReceipt(a.id!, tempPath);
                                                  // ignore: use_build_context_synchronously
                                                  if (err == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Recibo baixado em: $tempPath')),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Falha ao baixar recibo: $err')),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Tooltip(
                                              message: 'Cancelar agendamento',
                                              child: IconButton(
                                                icon: const Icon(Icons.cancel, color: AppColors.red),
                                                onPressed: a.id == null
                                                    ? null
                                                    : () async {
                                                        final ok = await vm.cancel(a.id!);
                                                        if (!ok && vm.error != null) {
                                                          // ignore: use_build_context_synchronously
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text(vm.error!)),
                                                          );
                                                        }
                                                      },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
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
          // Barra de navegação inferior removida
          bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
        );
        },
      ),
    );
  }
}