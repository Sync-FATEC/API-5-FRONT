import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/merchandise_type_model.dart';
import 'package:api2025/data/enums/merchandise_enums.dart';
import 'package:api2025/core/providers/merchandise_type_provider.dart';

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
  late MerchandiseGroup? _selectedGroup;
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

  String _getGroupDisplayName(MerchandiseGroup? group) {
    if (group == null) return 'Sem Grupo';
    return merchandiseGroupDisplayName(group);
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
                        child: DropdownButton<MerchandiseGroup?>(
                          value: _selectedGroup,
                          isExpanded: true,
                          menuMaxHeight: 300,
                          items: [
                            const DropdownMenuItem<MerchandiseGroup?>(
                              value: null,
                              child: Text('Sem Grupo'),
                            ),
                            ...MerchandiseGroup.values.map((group) {
                              return DropdownMenuItem<MerchandiseGroup?>(
                                value: group,
                                child: Text(_getGroupDisplayName(group)),
                              );
                            }).toList(),
                          ],
                          onChanged: (MerchandiseGroup? newValue) {
                            setState(() {
                              _selectedGroup = newValue;
                            });
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