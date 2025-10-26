import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/merchandise_type_model.dart';
import 'package:api2025/data/enums/merchandise_enums.dart';
import 'package:provider/provider.dart';
import 'package:api2025/core/providers/merchandise_type_provider.dart';
import 'package:api2025/core/providers/user_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:api2025/ui/views/merchandise/merchandise_history_screen.dart';
import 'package:api2025/ui/views/merchandise/widgets/edit_merchandise_type_modal.dart';
import '../inventory/inventory_history_screen.dart';

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
  final ScreenshotController _qrScreenshotController = ScreenshotController();

  String _getGroupDisplayName(MerchandiseGroup? group) {
    if (group == null) return 'Sem Grupo';
    return merchandiseGroupDisplayName(group);
  }

  Future<void> _showQrCodeDialog() async {
    final recordNumber = widget.merchandise.recordNumber;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('QR Code do Produto'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ficha: $recordNumber',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Screenshot(
                    controller: _qrScreenshotController,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: QrImageView(
                            data: recordNumber,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    recordNumber,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _saveQrToGallery(recordNumber),
              icon: const Icon(Icons.save_alt),
              label: const Text('Salvar na galeria'),
            ),
            TextButton.icon(
              onPressed: () => _printQr(recordNumber),
              icon: const Icon(Icons.print),
              label: const Text('Imprimir'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveQrToGallery(String recordNumber) async {
    try {
      final Uint8List? bytes = await _qrScreenshotController.capture();
      if (bytes == null) {
        throw Exception('Não foi possível capturar o QR Code');
      }

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'qr_${recordNumber.replaceAll(RegExp(r"[^0-9A-Za-z]"), '_')}',
        quality: 100,
      );

      if (!mounted) return;

      bool success = false;
      if (result is Map) {
        success = result['isSuccess'] == true || result['success'] == true;
      } else if (result is bool) {
        success = result;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code salvo na galeria com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Falha ao salvar imagem na galeria.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printQr(String recordNumber) async {
    try {
      final Uint8List? bytes = await _qrScreenshotController.capture();
      if (bytes == null) {
        throw Exception('Não foi possível capturar o QR Code');
      }

      final pdf = pw.Document();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('Ficha: $recordNumber', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Image(image, width: 200, height: 200),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao imprimir QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editMerchandise() async {
    final result = await EditMerchandiseTypeModal.show(context, widget.merchandise);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Volta para a tela anterior (listagem)
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteMerchandise() async {
    // Mostrar diálogo de confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Produto'),
          content: Text('Tem certeza que deseja excluir "${widget.merchandise.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final merchandiseProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
        
        if (widget.merchandise.id != null) {
          final success = await merchandiseProvider.deleteMerchandiseType(widget.merchandise.id!);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produto excluído com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // Volta para a tela anterior (listagem)
            Navigator.of(context).pop(true);
          } else {
            // Verificar se é erro específico de produto em uso
            String errorMessage = merchandiseProvider.errorMessage ?? 'Erro ao excluir produto';
            Color backgroundColor = Colors.red;
            
            if (errorMessage.toLowerCase().contains('pedido')) {
              backgroundColor = Colors.orange;
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: backgroundColor,
                duration: const Duration(seconds: 4), // Mais tempo para ler a mensagem
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID do produto não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir produto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editQuantityTotal() async {
    final TextEditingController quantityController = TextEditingController(
      text: widget.merchandise.quantityTotal.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Quantidade Total'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Digite a nova quantidade total:'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Total',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity >= 0) {
                  Navigator.of(context).pop(quantity);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Digite uma quantidade válida (número positivo)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      try {
        final merchandiseProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
        
        if (widget.merchandise.id != null) {
          final success = await merchandiseProvider.updateQuantityTotal(widget.merchandise.id!, result);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quantidade total atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // Volta para a tela anterior (listagem) para atualizar a lista
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(merchandiseProvider.errorMessage ?? 'Erro ao atualizar quantidade total'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID do produto não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar quantidade total: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(
            title: 'VOLTAR',
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
            sizeHeader: 450,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card principal com informações do produto
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final isAdmin = userProvider.isAdmin;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome do produto
                                _buildDetailField('Nome do produto', widget.merchandise.name),
                                const SizedBox(height: 16),
                                
                                // Número da ficha
                                _buildDetailField('Número da ficha:', widget.merchandise.recordNumber),
                                const SizedBox(height: 16),
                                
                                // Data da criação (placeholder - não temos esse campo no modelo)
                                _buildDetailField('Data da criação:', 'N/A'),
                                const SizedBox(height: 16),
                                
                                // Unidade de medida
                                _buildDetailField('Unidade de medida:', widget.merchandise.unitOfMeasure),
                                const SizedBox(height: 16),
                                
                                // Quantidade
                                _buildQuantityField(isAdmin),
                                const SizedBox(height: 16),
                                
                                // Estoque mínimo
                                _buildDetailField('Estoque mínimo:', widget.merchandise.minimumStock.toString()),
                                const SizedBox(height: 16),
                                
                                // Grupo
                                _buildDetailField('Grupo:', _getGroupDisplayName(widget.merchandise.group)),
                                const SizedBox(height: 20),
                                
                                // Seções adicionais
                                _buildSectionItem(
                                  icon: Icons.history,
                                  title: 'Histórico de alterações',
                                  onTap: () {
                                    if (widget.merchandise.id != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MerchandiseHistoryScreen(
                                            merchandiseTypeId: widget.merchandise.id!,
                                            merchandiseName: widget.merchandise.name,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('ID do produto não encontrado'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                
                                _buildSectionItem(
                                  icon: Icons.inventory,
                                  title: 'Histórico de inventário',
                                  onTap: () {
                                    if (widget.merchandise.id != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InventoryHistoryScreen(
                                            productId: widget.merchandise.id!,
                                            productName: widget.merchandise.name,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('ID do produto não encontrado'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                
                                _buildSectionItem(
                                  icon: Icons.qr_code,
                                  title: 'Visualizar QR Code',
                                  onTap: _showQrCodeDialog,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _editMerchandise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'EDITAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _deleteMerchandise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'EXCLUIR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.bluePrimary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.bluePrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.bluePrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityField(bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantidade:',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.merchandise.quantityTotal.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isAdmin)
                IconButton(
                  onPressed: _editQuantityTotal,
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 20,
                  ),
                  tooltip: 'Editar quantidade total',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Classe para o modal de edição (extensão do modal existente)