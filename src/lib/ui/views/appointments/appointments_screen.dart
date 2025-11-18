// lib/ui/views/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
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
import '../../../data/models/exam_type_model.dart';
import 'widgets/appointment_form_modal.dart';
import 'widgets/appointment_detail_modal.dart';
import 'widgets/appointment_ui_helpers.dart';
import 'package:intl/intl.dart';

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
        // Apenas coordenadores precisam carregar a lista de pacientes
        if (!isPatient) {
          vm.loadPatients();
        }
        vm.load(patientId: patientId);
        return vm;
      },
      child: Consumer<AppointmentsViewModel>(
        builder: (context, vm, _) {
          final role =
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).apiUserData?.role.toUpperCase() ??
              '';
          final isCoordinator = role == 'COORDENADOR_AGENDA';
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
                const Header(title: 'AGENDAMENTOS'),
                Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Column(
                    children: [
                      // Filtros simples
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.bluePrimary.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: DropdownButton<AppointmentStatus?>(
                                    value: vm.filterStatus,
                                    hint: const Text('Filtrar por status'),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text('Todos'),
                                      ),
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
                                    onChanged: (v) => vm.load(status: v),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => vm.load(status: vm.filterStatus),
                          child:
                              !vm.isLoading &&
                                  vm.error == null &&
                                  vm.items.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhum agendamento encontrado',
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
                                    ...vm.items.map((a) {
                                      // Layout diferente para PACIENTE vs COORDENADOR
                                      final dateFormat = DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      );
                                      final formattedDate = dateFormat.format(
                                        a.dateTime.toLocal(),
                                      );

                                      if (isCoordinator) {
                                        // COORDENADOR: Paciente no title, Exame no subtitle
                                        // Data do agendamento e retirada como bottomWidget
                                        Widget? bottomContent;

                                        if (a.withdrawalDate != null) {
                                          final r = dateFormat.format(
                                            a.withdrawalDate!.toLocal(),
                                          );
                                          bottomContent = Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Retirada: $r',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.blue[300]!,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Agendado: $formattedDate',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.blue[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          bottomContent = Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue[300]!,
                                              ),
                                            ),
                                            child: Text(
                                              'Agendado: $formattedDate',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }

                                        return CustomCard(
                                          iconData: Icons.event,
                                          title:
                                              'Paciente: ${vm.patientNameById(a.patientId)}',
                                          subtitle:
                                              'Exame: ${vm.examTypeNameById(a.examTypeId)}',
                                          bottomWidget: bottomContent,
                                          onTap: () {
                                            AppointmentFormModal.show(
                                              context,
                                              initial: a,
                                            ).then((edited) {
                                              if (edited == true)
                                                vm.load(
                                                  status: vm.filterStatus,
                                                );
                                            });
                                          },
                                          showArrow: false,
                                          trailing: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppointmentUIHelpers.statusColor(
                                                        a.status,
                                                      ).withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        AppointmentUIHelpers.statusColor(
                                                          a.status,
                                                        ),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  AppointmentUIHelpers.statusLabel(
                                                    a.status,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppointmentUIHelpers.statusColor(
                                                          a.status,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 4,
                                                runSpacing: 4,
                                                children: [
                                                  Tooltip(
                                                    message:
                                                        'Cancelar agendamento',
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.cancel,
                                                        color: AppColors.red,
                                                      ),
                                                      onPressed: a.id == null
                                                          ? null
                                                          : () async {
                                                              final ok =
                                                                  await vm
                                                                      .cancel(
                                                                        a.id!,
                                                                      );
                                                              if (!ok &&
                                                                  vm.error !=
                                                                      null) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      vm.error!,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // PACIENTE: Data no title, Exame no subtitle
                                        final additionalInfo =
                                            a.withdrawalDate != null
                                            ? 'Retirada: ${dateFormat.format(a.withdrawalDate!.toLocal())}'
                                            : null;

                                        return CustomCard(
                                          iconData: Icons.event,
                                          title: formattedDate,
                                          subtitle: vm.examTypeNameById(
                                            a.examTypeId,
                                          ),
                                          additionalInfo: additionalInfo,
                                          onTap: () {
                                            final patientName = vm
                                                .patientNameById(a.patientId);
                                            final examTypeName = vm
                                                .examTypeNameById(a.examTypeId);
                                            ExamTypeModel? examType;
                                            try {
                                              examType = vm.examTypes
                                                  .firstWhere(
                                                    (e) => e.id == a.examTypeId,
                                                  );
                                            } catch (e) {
                                              examType = null;
                                            }
                                            AppointmentDetailModal.show(
                                              context,
                                              a,
                                              patientName: patientName,
                                              examTypeName: examTypeName,
                                              examType: examType,
                                            );
                                          },
                                          showArrow: true,
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppointmentUIHelpers.statusColor(
                                                    a.status,
                                                  ).withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    AppointmentUIHelpers.statusColor(
                                                      a.status,
                                                    ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              AppointmentUIHelpers.statusLabel(
                                                a.status,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppointmentUIHelpers.statusColor(
                                                      a.status,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }),
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
