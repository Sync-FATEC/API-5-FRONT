import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/merchandise_log_model.dart';
import 'package:api2025/core/services/merchandise_log_service.dart';

class MerchandiseHistoryScreen extends StatefulWidget {
  final String merchandiseTypeId;
  final String merchandiseName;

  const MerchandiseHistoryScreen({
    super.key,
    required this.merchandiseTypeId,
    required this.merchandiseName,
  });

  @override
  State<MerchandiseHistoryScreen> createState() => _MerchandiseHistoryScreenState();
}

class _MerchandiseHistoryScreenState extends State<MerchandiseHistoryScreen> {
  final MerchandiseLogService _logService = MerchandiseLogService();
  List<GroupedLog> _groupedLogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final logs = await _logService.getMerchandiseLogs(widget.merchandiseTypeId);
      final grouped = _logService.groupLogsByDateAndUser(logs);
      setState(() {
        _groupedLogs = grouped;
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.bluePrimary,
        title: const Text(
          'HISTÓRICO DE ALTERAÇÕES',
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
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.bluePrimary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar histórico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadLogs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_groupedLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.gray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma alteração registrada',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      color: AppColors.bluePrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _groupedLogs.length,
        itemBuilder: (context, index) {
          return _buildGroupedLogCard(_groupedLogs[index]);
        },
      ),
    );
  }

  Widget _buildGroupedLogCard(GroupedLog group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.bluePrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${group.formattedDate} - ${group.formattedTime}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Editado por: ${group.user.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.bluePrimary.withOpacity(0.1),
              child: Text(
                group.user.name.isNotEmpty ? group.user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.bluePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          ...group.logs.map((log) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.label, color: AppColors.gray, size: 18),
                    const SizedBox(width: 8),
                    Text(log.fieldDisplayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Produto: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(widget.merchandiseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_circle_outline, size: 16, color: AppColors.red),
                      const SizedBox(width: 6),
                      Text('Valor anterior: ${log.formatValue(log.oldValue)}', style: const TextStyle(fontSize: 13, color: AppColors.red, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 16, color: AppColors.greenPrimary),
                      const SizedBox(width: 6),
                      Text('Valor novo: ${log.formatValue(log.newValue)}', style: TextStyle(fontSize: 13, color: AppColors.greenPrimary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (log.justification != null && log.justification!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bluePrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.bluePrimary),
                        const SizedBox(width: 6),
                        Text('Justificativa: ', style: TextStyle(fontSize: 12, color: AppColors.bluePrimary, fontWeight: FontWeight.w600)),
                        Expanded(child: Text(log.justification!, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildLogItem(MerchandiseLog log, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.gray.withOpacity(0.1),
                  width: 1,
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.fieldDisplayName,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Valor antigo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.remove_circle_outline,
                      size: 16,
                      color: AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Valor anterior: ${log.formatValue(log.oldValue)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Valor novo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greenPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: AppColors.greenPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Valor novo: ${log.formatValue(log.newValue)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greenPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Justificativa (se houver)
          if (log.justification != null && log.justification!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bluePrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.bluePrimary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Justificativa:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.bluePrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.justification!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
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
}
