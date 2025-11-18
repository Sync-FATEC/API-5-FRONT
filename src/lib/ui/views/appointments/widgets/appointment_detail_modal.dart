import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';
import '../../../../data/models/exam_type_model.dart';
import 'appointment_ui_helpers.dart';

class AppointmentDetailModal extends StatelessWidget {
  final AppointmentModel appointment;
  final ExamTypeModel? examType;
  final String patientName;
  final String examTypeName;

  const AppointmentDetailModal({
    Key? key,
    required this.appointment,
    this.examType,
    required this.patientName,
    required this.examTypeName,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    AppointmentModel appointment, {
    ExamTypeModel? examType,
    String patientName = 'Paciente',
    String examTypeName = 'Exame',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AppointmentDetailModal(
        appointment: appointment,
        examType: examType,
        patientName: patientName,
        examTypeName: examTypeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalhes do Agendamento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppointmentUIHelpers.statusColor(
                      appointment.status,
                    ).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppointmentUIHelpers.statusColor(
                        appointment.status,
                      ),
                    ),
                  ),
                  child: Text(
                    AppointmentUIHelpers.statusLabel(appointment.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppointmentUIHelpers.statusColor(
                        appointment.status,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Informações principais
            _buildInfoSection(
              label: 'Data e Hora',
              value: DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(appointment.dateTime.toLocal()),
            ),
            const SizedBox(height: 16),

            _buildInfoSection(label: 'Tipo de Exame', value: examTypeName),
            const SizedBox(height: 16),

            if (appointment.withdrawalDate != null) ...[
              _buildInfoSection(
                label: 'Data de Retirada',
                value: DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(appointment.withdrawalDate!.toLocal()),
              ),
              const SizedBox(height: 16),
            ],

            // Preparo necessário (se houver)
            if (examType != null &&
                examType!.requiredPreparation != null &&
                examType!.requiredPreparation!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Preparo Necessário',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          examType!.requiredPreparation!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Observações (se houver)
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              _buildInfoSection(
                label: 'Observações',
                value: appointment.notes!,
              ),
              const SizedBox(height: 16),
            ],

            // Botão fechar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
