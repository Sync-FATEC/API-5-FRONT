// lib/ui/views/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/background_header.dart';
import '../../widgets/add_floating_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/appointments_viewmodel.dart';
import '../../../data/enums/appointment_enums.dart';
import 'widgets/appointment_form_modal.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppointmentsViewModel()..initialize()..load(),
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
                          IconButton(
                            onPressed: () => vm.load(),
                            icon: const Icon(Icons.refresh),
                          ),
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
                                  title: 'Paciente: ${a.patientId}',
                                  subtitle:
                                      'Exame: ${a.examTypeId} • ${a.dateTime.toLocal().toString()}',
                                  onTap: () {
                                    if (isCoordinator) {
                                      AppointmentFormModal.show(context, initial: a).then((edited) {
                                        if (edited == true) vm.load(status: vm.filterStatus);
                                      });
                                    }
                                  },
                                  showArrow: isCoordinator,
                                  trailing: isCoordinator
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
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
                                            IconButton(
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
                                          ],
                                        )
                                      : null,
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
          bottomNavigationBar: const BottomNavBarWidget(currentIndex: 3),
        );
        },
      ),
    );
  }
}