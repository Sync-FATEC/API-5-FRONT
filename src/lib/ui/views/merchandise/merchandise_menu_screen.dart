import 'package:flutter/material.dart';
import '../../widgets/background_header.dart';
import '../../widgets/custom_card.dart';
import 'widgets/create_merchandise_type_modal.dart';
import 'widgets/merchandise_entry_modal.dart';

class MerchandiseMenuScreen extends StatefulWidget {
  final Function() onScanQr;
  final Function(Function(String))? onInit;

  const MerchandiseMenuScreen({
    super.key,
    required this.onScanQr,
    this.onInit,
  });
  
  @override
  State<MerchandiseMenuScreen> createState() => _MerchandiseMenuScreenState();

}

class _MerchandiseMenuScreenState extends State<MerchandiseMenuScreen> {
  String? scanResult;
  
  @override
  void initState() {
    super.initState();
    if (widget.onInit != null) {
      widget.onInit!((result) {
        setState(() {
          scanResult = result;
        });
      });
    }
  }
  
  void updateScanResult(String result) {
    setState(() {
      scanResult = result;
    });
  }

  Future<void> _openMerchandiseEntryModal() async {
    final result = await MerchandiseEntryModal.show(context);
    if (result == true) {
      // Atualizar a lista ou fazer outras ações necessárias
    }
  }

  Future<void> _openCreateMerchandiseTypeModal() async {
    final result = await CreateMerchandiseTypeModal.show(context);
    if (result == true) {
      // Mostrar mensagem de sucesso adicional se necessário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tipo de mercadoria cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
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
          ),
          Padding(
            padding: const EdgeInsets.only(top: 140.0),
            child: Column(
              children: [
                if (scanResult != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resultado do QR Code:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scanResult!,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CustomCard(
                        iconData: Icons.qr_code,
                        title: 'Escanear QR CODE',
                        subtitle: 'Preenche informações, solicitando apenas a quantidade recebida',
                        onTap: _openMerchandiseEntryModal,
                        iconBackgroundColor: const Color(0xFF2563EB),
                        iconColor: Colors.white,
                        showArrow: true,
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        iconData: Icons.add_box_rounded,
                        title: 'Cadastrar novo item',
                        subtitle: 'Formulário de preenchimento manual',
                        onTap: _openCreateMerchandiseTypeModal,
                        iconBackgroundColor: const Color(0xFF2563EB),
                        iconColor: Colors.white,
                        showArrow: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}
}