import 'package:flutter/material.dart';

class FiltersSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? stockId;
  final Function(bool isStartDate) onSelectDate;
  final VoidCallback onUpdateData;
  final VoidCallback onDownloadPDF;
  final VoidCallback onDownloadExcel;
  final VoidCallback onShowForecast;

  const FiltersSection({
    super.key,
    this.startDate,
    this.endDate,
    this.stockId,
    required this.onSelectDate,
    required this.onUpdateData,
    required this.onDownloadPDF,
    required this.onDownloadExcel,
    required this.onShowForecast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Grid responsivo para dispositivos móveis e desktop
          LayoutBuilder(
            builder: (context, constraints) {
              // Para telas pequenas (mobile), use coluna
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    DateInputsWidget(
                      startDate: startDate,
                      endDate: endDate,
                      onSelectDate: onSelectDate,
                    ),
                    const SizedBox(height: 16),
                    ActionButtonsWidget(
                      onUpdateData: onUpdateData,
                      onDownloadPDF: onDownloadPDF,
                      onDownloadExcel: onDownloadExcel,
                      onShowForecast: onShowForecast,
                    ),
                  ],
                );
              }
              // Para telas grandes (tablet/desktop), use linha
              else {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DateInputsWidget(
                        startDate: startDate,
                        endDate: endDate,
                        onSelectDate: onSelectDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: ActionButtonsWidget(
                        onUpdateData: onUpdateData,
                        onDownloadPDF: onDownloadPDF,
                        onDownloadExcel: onDownloadExcel,
                        onShowForecast: onShowForecast,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          // Mostrar ID do estoque se disponível
          if (stockId != null && stockId!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Estoque ID: $stockId',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DateInputsWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(bool isStartDate) onSelectDate;

  const DateInputsWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Início',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => onSelectDate(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startDate != null
                            ? '${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}'
                            : 'Selecionar data',
                        style: TextStyle(
                          fontSize: 14,
                          color: startDate != null
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fim',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => onSelectDate(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endDate != null
                            ? '${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}'
                            : 'Selecionar data',
                        style: TextStyle(
                          fontSize: 14,
                          color: endDate != null
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onUpdateData;
  final VoidCallback onDownloadPDF;
  final VoidCallback onDownloadExcel;
  final VoidCallback onShowForecast;

  const ActionButtonsWidget({
    super.key,
    required this.onUpdateData,
    required this.onDownloadPDF,
    required this.onDownloadExcel,
    required this.onShowForecast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildButton(
                'Atualizar',
                Colors.blue,
                onUpdateData,
                Icons.refresh,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                'PDF',
                Colors.red,
                onDownloadPDF,
                Icons.picture_as_pdf,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                'Excel',
                Colors.green,
                onDownloadExcel,
                Icons.table_chart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                'Previsão',
                Colors.deepPurple,
                onShowForecast,
                Icons.show_chart,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    Color color,
    VoidCallback onPressed,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }
}
