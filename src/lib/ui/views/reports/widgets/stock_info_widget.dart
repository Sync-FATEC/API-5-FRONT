import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';

class StockInfoWidget extends StatelessWidget {
  final String? stockName;
  final String? stockLocation;

  const StockInfoWidget({
    super.key,
    this.stockName,
    this.stockLocation,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações do Estoque',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Para telas pequenas, usar coluna
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildInfoCard(
                      'Nome',
                      stockName ?? 'N/A',
                      AppColors.bluePrimary,
                      Icons.store_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Local',
                      stockLocation ?? 'N/A',
                      Colors.green,
                      Icons.location_on_outlined,
                    ),
                  ],
                );
              }
              // Para telas maiores, usar linha
              else {
                return Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Nome',
                        stockName ?? 'N/A',
                        AppColors.bluePrimary,
                        Icons.store_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        'Local',
                        stockLocation ?? 'N/A',
                        Colors.green,
                        Icons.location_on_outlined,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}