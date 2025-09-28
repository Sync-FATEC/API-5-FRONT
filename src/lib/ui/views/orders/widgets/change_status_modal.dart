// lib/ui/views/orders/widgets/change_status_modal.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChangeStatusModal extends StatefulWidget {
  final String currentStatus;
  
  const ChangeStatusModal({
    Key? key,
    required this.currentStatus,
  }) : super(key: key);

  static Future<String?> show(BuildContext context, String currentStatus) {
    return showDialog<String>(
      context: context,
      builder: (context) => ChangeStatusModal(currentStatus: currentStatus),
    );
  }

  @override
  State<ChangeStatusModal> createState() => _ChangeStatusModalState();
}

class _ChangeStatusModalState extends State<ChangeStatusModal> {
  String? _selectedStatus;
  
  final List<Map<String, String>> _statusOptions = [
    {'value': 'PENDING', 'label': 'Pendente'},
    {'value': 'PROCESSING', 'label': 'Em Processamento'},
    {'value': 'READY', 'label': 'Pronto'},
    {'value': 'DELIVERED', 'label': 'Entregue'},
    {'value': 'COMPLETED', 'label': 'Finalizado'},
    {'value': 'CANCELLED', 'label': 'Cancelado'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  String _getStatusLabel(String status) {
    final option = _statusOptions.firstWhere(
      (option) => option['value'] == status,
      orElse: () => {'value': status, 'label': status},
    );
    return option['label']!;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'READY':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: AppColors.bluePrimary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alterar Status do Pedido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Status atual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Text(
                    'Status atual: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(widget.currentStatus),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(widget.currentStatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(widget.currentStatus),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Seleção de novo status
            const Text(
              'Selecione o novo status:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Lista de opções de status
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: _statusOptions.map((option) {
                    final isSelected = _selectedStatus == option['value'];
                    final isCurrentStatus = widget.currentStatus == option['value'];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isCurrentStatus ? null : () {
                            setState(() {
                              _selectedStatus = option['value'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? AppColors.bluePrimary.withOpacity(0.1)
                                : isCurrentStatus
                                  ? Colors.grey.shade100
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                  ? AppColors.bluePrimary
                                  : isCurrentStatus
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: option['value']!,
                                  groupValue: _selectedStatus,
                                  onChanged: isCurrentStatus ? null : (value) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  },
                                  activeColor: AppColors.bluePrimary,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(option['value']!).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(option['value']!),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    option['label']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(option['value']!),
                                    ),
                                  ),
                                ),
                                if (isCurrentStatus) ...[
                                  const Spacer(),
                                  Text(
                                    '(atual)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedStatus != null && _selectedStatus != widget.currentStatus
                    ? () => Navigator.of(context).pop(_selectedStatus)
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Alterar Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}