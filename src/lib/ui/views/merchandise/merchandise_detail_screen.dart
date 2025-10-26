import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/merchandise_type_model.dart';
import 'package:api2025/data/models/merchandise_detail_response_model.dart';
import 'package:api2025/data/models/merchandise_entry_detail_model.dart';
import 'package:api2025/data/enums/merchandise_enums.dart';
import 'package:provider/provider.dart';
import 'package:api2025/core/providers/merchandise_type_provider.dart';
import 'package:intl/intl.dart';

class MerchandiseDetailScreen extends StatefulWidget {
  final MerchandiseTypeModel merchandise;

  const MerchandiseDetailScreen({
    super.key,
    required this.merchandise,
  });

  @override
  State<MerchandiseDetailScreen> createState() => _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMerchandiseDetails();
    });
  }

  Future<void> _loadMerchandiseDetails() async {
    if (widget.merchandise.id != null) {
      await context.read<MerchandiseTypeProvider>().loadMerchandiseDetails(widget.merchandise.id!);
    }
  }

  String _getGroupDisplayName(String? group) {
    if (group == null) return 'Sem Grupo';
    final merchandiseGroup = merchandiseGroupFromString(group);
    return merchandiseGroupDisplayName(merchandiseGroup);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMerchandiseHeader(MerchandiseTypeDetailModel merchandiseType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  merchandiseType.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getGroupDisplayName(merchandiseType.group),
                  style: const TextStyle(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Registro', merchandiseType.recordNumber)),
              Expanded(child: _buildInfoItem('Unidade', merchandiseType.unitOfMeasure)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Estoque Total', '${merchandiseType.quantityTotal}')),
              Expanded(child: _buildInfoItem('Estoque Mínimo', '${merchandiseType.minimumStock}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Almoxarifado', merchandiseType.stock.name)),
              Expanded(child: _buildInfoItem('Controlado', merchandiseType.controlled ? 'Sim' : 'Não')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMerchandiseEntry(MerchandiseEntryDetailModel entry) {
    final expirationDate = DateFormat('dd/MM/yyyy').format(entry.batch.expirationDate);
    final isExpired = entry.batch.expirationDate.isBefore(DateTime.now());
    final isNearExpiration = entry.batch.expirationDate.isBefore(DateTime.now().add(const Duration(days: 30)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? Colors.red.withOpacity(0.3)
              : isNearExpiration
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Cabeçalho simplificado (sem ID e sem status)
          const Text(
            'Entrada de Mercadoria',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Quantidade', '${entry.quantity}'),
              ),
              Expanded(
                child: _buildInfoItem('Validade', expirationDate),
              ),
            ],
          ),
          if (isExpired || isNearExpiration) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isExpired ? Colors.red : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpired ? Icons.error : Icons.warning,
                    color: isExpired ? Colors.red : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isExpired ? 'Produto vencido' : 'Produto próximo ao vencimento',
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(
            title: 'DETALHES DA MERCADORIA',
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
            sizeHeader: 450,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Consumer<MerchandiseTypeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingDetails) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
                    ),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar detalhes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadMerchandiseDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bluePrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.merchandiseDetails == null) {
                  return const Center(
                    child: Text(
                      'Nenhum detalhe encontrado',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final details = provider.merchandiseDetails!;
                return RefreshIndicator(
                  onRefresh: _loadMerchandiseDetails,
                  color: AppColors.bluePrimary,
                  child: ListView(
                    children: [
                      _buildMerchandiseHeader(details.merchandiseType),
                     Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2, color: AppColors.bluePrimary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Entradas de Mercadoria (${details.merchandises.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bluePrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (details.merchandises.isEmpty)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma entrada encontrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Esta mercadoria ainda não possui entradas registradas.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      else
                        ...details.merchandises.map(_buildMerchandiseEntry),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
