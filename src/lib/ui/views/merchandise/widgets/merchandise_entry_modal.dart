import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/merchandise_service.dart';
import '../../../../data/models/merchandise_entry_model.dart';
import 'qr_scanner_screen.dart';

class MerchandiseEntryModal extends StatefulWidget {
  const MerchandiseEntryModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MerchandiseEntryModal(),
    );
  }

  @override
  State<MerchandiseEntryModal> createState() => _MerchandiseEntryModalState();
}

class _MerchandiseEntryModalState extends State<MerchandiseEntryModal> {
  final _formKey = GlobalKey<FormState>();
  final _recordNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _validDateController = TextEditingController();
  
  final MerchandiseService _merchandiseService = MerchandiseService();
  
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Definir data padrão como 1 ano a partir de hoje
    _selectedDate = DateTime.now().add(const Duration(days: 365));
    _validDateController.text = _formatDate(_selectedDate!);
  }

  @override
  void dispose() {
    _recordNumberController.dispose();
    _quantityController.dispose();
    _validDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 anos
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _scanQrCode() async {
    try {
      final result = await QrScannerScreen.show(context);
      if (result != null && result.isNotEmpty) {
        setState(() {
          _recordNumberController.text = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao escanear QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data de validade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final entry = MerchandiseEntryModel(
        recordNumber: _recordNumberController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
        status: 'AVAILABLE',
        validDate: _selectedDate!,
      );

      await _merchandiseService.createMerchandiseEntry(entry);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada de mercadoria criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar entrada: $e'),
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    color: Color(0xFF2563EB),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Entrada de Mercadoria',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Número de Registro
              const Text(
                'Número de Registro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _recordNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Ex: FICHA001',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira o número de registro';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _scanQrCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantidade
              const Text(
                'Quantidade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Ex: 100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  final quantity = int.tryParse(value.trim());
                  if (quantity == null || quantity <= 0) {
                    return 'Por favor, insira uma quantidade válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Data de Validade
              const Text(
                'Data de Validade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _validDateController,
                decoration: const InputDecoration(
                  labelText: 'Selecione a data',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Por favor, selecione uma data de validade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
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
                          : const Text('Criar Entrada'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}