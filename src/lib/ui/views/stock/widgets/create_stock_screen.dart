// lib/ui/views/stock/create_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/stock_provider.dart';
import '../../../widgets/custom_modal.dart';

class CreateStockModal extends StatefulWidget {
  const CreateStockModal({Key? key}) : super(key: key);

  @override
  State<CreateStockModal> createState() => _CreateStockModalState();

  static Future<bool?> show(BuildContext context) {
    return CustomModal.show<bool>(
      context: context,
      title: 'Cadastro de estoque do produto',
      child: const _CreateStockForm(),
    );
  }
}

class _CreateStockModalState extends State<CreateStockModal> {
  @override
  Widget build(BuildContext context) {
    return Container(); // Este widget não será mais usado diretamente
  }
}

class _CreateStockForm extends StatefulWidget {
  const _CreateStockForm({Key? key}) : super(key: key);

  @override
  _CreateStockFormState createState() => _CreateStockFormState();
}

class _CreateStockFormState extends State<_CreateStockForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createStock(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    try {
      await stockProvider.createStock(
        _nameController.text,
        _locationController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estoque criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar estoque: $e'),
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
            label: 'Nome do estoque:',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome do estoque';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomModalTextField(
            label: 'Localização:',
            controller: _locationController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a localização';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomModalButton(
            text: 'CADASTRAR',
            onPressed: () => _createStock(context),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}