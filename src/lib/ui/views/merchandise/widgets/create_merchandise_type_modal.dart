// lib/ui/views/merchandise/widgets/create_merchandise_type_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/merchandise_type_provider.dart';
import '../../../../core/providers/stock_provider.dart';
import '../../../../data/enums/merchandise_enums.dart';
import '../../../../data/models/merchandise_type_model.dart';
import '../../../widgets/custom_modal.dart';

class CreateMerchandiseTypeModal extends StatefulWidget {
  const CreateMerchandiseTypeModal({Key? key}) : super(key: key);

  @override
  State<CreateMerchandiseTypeModal> createState() => _CreateMerchandiseTypeModalState();

  static Future<bool?> show(BuildContext context) {
    return CustomModal.show<bool>(
      context: context,
      title: 'Cadastro de tipo de mercadoria',
      child: const _CreateMerchandiseTypeForm(),
    );
  }
}

class _CreateMerchandiseTypeModalState extends State<CreateMerchandiseTypeModal> {
  @override
  Widget build(BuildContext context) {
    return Container(); // Este widget não será mais usado diretamente
  }
}

class _CreateMerchandiseTypeForm extends StatefulWidget {
  const _CreateMerchandiseTypeForm({Key? key}) : super(key: key);

  @override
  _CreateMerchandiseTypeFormState createState() => _CreateMerchandiseTypeFormState();
}

class _CreateMerchandiseTypeFormState extends State<_CreateMerchandiseTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recordNumberController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  final _minimumStockController = TextEditingController();
  
  bool _controlled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _recordNumberController.dispose();
    _unitOfMeasureController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  Future<void> _createMerchandiseType(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final merchandiseTypeProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    try {
      // Obter o stockId do estoque selecionado
      final stockId = stockProvider.selectedStock?.id;
      
      if (stockId == null) {
        throw Exception('Nenhum estoque selecionado');
      }

      final newType = MerchandiseTypeModel(
        name: _nameController.text.trim(),
        recordNumber: _recordNumberController.text.trim(),
        unitOfMeasure: _unitOfMeasureController.text.trim(),
        quantityTotal: 0, // Valor inicial padrão
        controlled: _controlled,
        minimumStock: int.parse(_minimumStockController.text.trim()),
        stockId: stockId, // Incluindo o stockId
      );

      final success = await merchandiseTypeProvider.createMerchandiseType(newType);
      
      if (!success) {
        throw Exception('Falha ao criar tipo de mercadoria');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tipo de mercadoria criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar tipo de mercadoria: $e'),
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



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomModalTextField(
            label: 'Nome do tipo de mercadoria:',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira o nome do tipo de mercadoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomModalTextField(
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
          CustomModalTextField(
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
          CustomModalTextField(
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
          // Campo de controlado (checkbox)
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
          CustomModalButton(
            text: 'CADASTRAR',
            onPressed: () => _createMerchandiseType(context),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}