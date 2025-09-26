import 'package:flutter/material.dart';
import '../../widgets/background_header.dart';
import '../../widgets/custom_card.dart';

class MerchandiseMenuScreen extends StatefulWidget {
  final Function() onScanQr;
  final VoidCallback onAddItem;
  final Function(Function(String))? onInit;

  const MerchandiseMenuScreen({
    super.key,
    required this.onScanQr,
    required this.onAddItem,
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
                        onTap: widget.onScanQr,
                        iconBackgroundColor: const Color(0xFF2563EB),
                        iconColor: Colors.white,
                        showArrow: true,
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        iconData: Icons.add_box_rounded,
                        title: 'Cadastrar novo item',
                        subtitle: 'Formulário de preenchimento manual',
                        onTap: widget.onAddItem,
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