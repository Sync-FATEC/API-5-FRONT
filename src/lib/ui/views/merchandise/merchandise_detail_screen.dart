import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/merchandise_type_model.dart';
import 'package:api2025/data/enums/merchandise_enums.dart';
import 'package:provider/provider.dart';
import 'package:api2025/core/providers/merchandise_type_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  String _getGroupDisplayName(MerchandiseGroup group) {
    switch (group) {
      case MerchandiseGroup.medical:
        return 'Médico';
      case MerchandiseGroup.almox:
        return 'Almoxarifado';
    }
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
                        child: Column(
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
                            _buildDetailField('Quantidade:', widget.merchandise.quantityTotal.toString()),
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
                                // TODO: Implementar histórico de alterações
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Funcionalidade em desenvolvimento'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            _buildSectionItem(
                              icon: Icons.inventory,
                              title: 'Histórico de inventário',
                              onTap: () {
                                // TODO: Implementar histórico de inventário
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Funcionalidade em desenvolvimento'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            _buildSectionItem(
                              icon: Icons.qr_code,
                              title: 'Visualizar QR Code',
                              onTap: _showQrCodeDialog,
                            ),
                          ],
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
}

// Classe para o modal de edição (extensão do modal existente)
class EditMerchandiseTypeModal {
  static Future<bool?> show(BuildContext context, MerchandiseTypeModel merchandise) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _EditMerchandiseTypeForm(merchandise: merchandise),
          ),
        );
      },
    );
  }
}

class _EditMerchandiseTypeForm extends StatefulWidget {
  final MerchandiseTypeModel merchandise;

  const _EditMerchandiseTypeForm({
    required this.merchandise,
  });

  @override
  _EditMerchandiseTypeFormState createState() => _EditMerchandiseTypeFormState();
}

class _EditMerchandiseTypeFormState extends State<_EditMerchandiseTypeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _recordNumberController;
  late TextEditingController _unitOfMeasureController;
  late TextEditingController _minimumStockController;
  
  late bool _controlled;
  late MerchandiseGroup _selectedGroup;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preencher os campos com os dados existentes
    _nameController = TextEditingController(text: widget.merchandise.name);
    _recordNumberController = TextEditingController(text: widget.merchandise.recordNumber);
    _unitOfMeasureController = TextEditingController(text: widget.merchandise.unitOfMeasure);
    _minimumStockController = TextEditingController(text: widget.merchandise.minimumStock.toString());
    _controlled = widget.merchandise.controlled;
    _selectedGroup = widget.merchandise.group;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recordNumberController.dispose();
    _unitOfMeasureController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  Future<void> _updateMerchandiseType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final merchandiseProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);

      final updatedType = MerchandiseTypeModel(
        id: widget.merchandise.id,
        name: _nameController.text.trim(),
        recordNumber: _recordNumberController.text.trim(),
        unitOfMeasure: _unitOfMeasureController.text.trim(),
        quantityTotal: widget.merchandise.quantityTotal, // Manter quantidade atual
        controlled: _controlled,
        group: _selectedGroup,
        minimumStock: int.parse(_minimumStockController.text.trim()),
      );

      final success = await merchandiseProvider.updateMerchandiseType(updatedType);
      
      if (!success) {
        throw Exception('Falha ao atualizar tipo de mercadoria');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar produto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getGroupDisplayName(MerchandiseGroup group) {
    switch (group) {
      case MerchandiseGroup.medical:
        return 'Medical';
      case MerchandiseGroup.almox:
        return 'Almox';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Row(
            children: [
              const Icon(
                Icons.edit,
                color: AppColors.bluePrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Editar Produto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bluePrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Formulário
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  label: 'Nome do produto:',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome do produto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: 'Número de registro:',
                  controller: _recordNumberController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o número de registro';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: 'Unidade de medida:',
                  controller: _unitOfMeasureController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira a unidade de medida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: 'Estoque mínimo:',
                  controller: _minimumStockController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o estoque mínimo';
                    }
                    final intValue = int.tryParse(value.trim());
                    if (intValue == null || intValue < 0) {
                      return 'Por favor, insira um número válido maior ou igual a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Dropdown de grupo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grupo:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MerchandiseGroup>(
                          value: _selectedGroup,
                          isExpanded: true,
                          items: MerchandiseGroup.values.map((group) {
                            return DropdownMenuItem<MerchandiseGroup>(
                              value: group,
                              child: Text(_getGroupDisplayName(group)),
                            );
                          }).toList(),
                          onChanged: (MerchandiseGroup? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedGroup = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Checkbox de controlado
                Row(
                  children: [
                    Checkbox(
                      value: _controlled,
                      onChanged: (bool? value) {
                        setState(() {
                          _controlled = value ?? false;
                        });
                      },
                      activeColor: AppColors.bluePrimary,
                    ),
                    const Expanded(
                      child: Text(
                        'Produto controlado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'CANCELAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateMerchandiseType,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bluePrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'SALVAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.bluePrimary),
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
          ),
        ),
      ],
    );
  }
}