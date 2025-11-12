// lib/ui/views/merchandise/merchandise_entries_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/merchandise_type_provider.dart';
import '../../../data/models/merchandise_entries_response_model.dart';
import '../../../data/models/merchandise_type_model.dart';
import '../../../data/models/merchandise_with_batch_model.dart';
import '../../../data/enums/merchandise_enums.dart';
import 'package:api2025/core/constants/app_colors.dart';

class MerchandiseEntriesScreen extends StatefulWidget {
  final MerchandiseTypeModel merchandiseType;

  const MerchandiseEntriesScreen({
    Key? key,
    required this.merchandiseType,
  }) : super(key: key);

  @override
  State<MerchandiseEntriesScreen> createState() => _MerchandiseEntriesScreenState();
}

class _MerchandiseEntriesScreenState extends State<MerchandiseEntriesScreen> {
  MerchandiseEntriesResponseModel? _entriesResponse;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  String _getGroupDisplayName(MerchandiseGroup? group) {
    if (group == null) return 'Sem Grupo';
    return merchandiseGroupDisplayName(group);
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final merchandiseTypeId = widget.merchandiseType.id;
      if (merchandiseTypeId == null) {
        throw Exception('ID do tipo de mercadoria não encontrado');
      }

      final provider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
      final response = await provider.fetchMerchandiseEntries(merchandiseTypeId);
      
      setState(() {
        _entriesResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.bluePrimary,
        title: Text(
          'ENTRADAS DO PRODUTO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.bluePrimary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEntries,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_entriesResponse == null || _entriesResponse!.data.merchandises.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.bluePrimary,
      onRefresh: _loadEntries,
      child: _buildEntriesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma entrada encontrada',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este produto ainda não possui entradas registradas.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProductInfo(),
        const SizedBox(height: 24),
        _buildEntriesHeader(),
        const SizedBox(height: 16),
        ..._entriesResponse!.data.merchandises.map((merchandise) => 
          _buildEntryCard(merchandise)
        ).toList(),
      ],
    );
  }

  Widget _buildProductInfo() {
    final merchandiseType = _entriesResponse!.data.merchandiseType;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
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
              Icon(
                Icons.inventory_2,
                color: AppColors.bluePrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  merchandiseType.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Código',
                  merchandiseType.recordNumber,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Unidade',
                  merchandiseType.unitOfMeasure,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Estoque Total',
                  '${merchandiseType.quantityTotal} ${merchandiseType.unitOfMeasure}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Grupo',
                  _getGroupDisplayName(merchandiseType.group),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEntriesHeader() {
    return Row(
      children: [
        Icon(
          Icons.list_alt,
          color: AppColors.bluePrimary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Entradas e Lotes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bluePrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_entriesResponse!.data.merchandises.length} entradas',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.bluePrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(MerchandiseWithBatchModel merchandise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIndicator(merchandise.status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lote ${merchandise.batch?.id?.substring(0, 8) ?? 'N/A'}...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              Text(
                '${merchandise.quantity} ${_entriesResponse!.data.merchandiseType.unitOfMeasure}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.gray,
              ),
              const SizedBox(width: 8),
              Text(
                'Validade: ${_formatDate(merchandise.batch?.expirationDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'AVAILABLE':
        statusColor = AppColors.greenPrimary;
        statusText = 'Disponível';
        break;
      case 'RESERVED':
        statusColor = AppColors.orange;
        statusText = 'Reservado';
        break;
      case 'OUT_OF_STOCK':
        statusColor = AppColors.red;
        statusText = 'Esgotado';
        break;
      default:
        statusColor = AppColors.gray;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}