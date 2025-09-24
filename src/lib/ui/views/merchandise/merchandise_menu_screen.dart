import 'package:flutter/material.dart';
import '../../widgets/background_header.dart';
import '../../widgets/custom_card.dart';

class MerchandiseMenuScreen extends StatelessWidget {
  final VoidCallback onScanQr;
  final VoidCallback onAddItem;

  const MerchandiseMenuScreen({
    super.key,
    required this.onScanQr,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            const Header(
              title: ' ',
              subtitle: '',
              sizeHeader: 120,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text('VOLTAR', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 16, top: 0, bottom: 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                children: [
                  CustomCard(
                    iconData: Icons.qr_code,
                    title: 'Escanear QR CODE',
                    subtitle: 'Preenche informações automaticamente, solicitando apenas a quantidade recebida',
                    onTap: onScanQr,
                    iconBackgroundColor: const Color(0xFF2563EB),
                    iconColor: Colors.white,
                    showArrow: true,
                  ),
                  CustomCard(
                    iconData: Icons.add_box_rounded,
                    title: 'Cadastrar novo item',
                    subtitle: 'Formulário de preenchimento manual',
                    onTap: onAddItem,
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
    );
  }
}
