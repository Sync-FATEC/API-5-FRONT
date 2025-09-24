import 'package:flutter/material.dart';
// Adicione o pacote mobile_scanner no pubspec.yaml
// import 'package:mobile_scanner/mobile_scanner.dart';

class ScanOrManualDialog extends StatefulWidget {
  final void Function(String ficha) onResult;

  const ScanOrManualDialog({super.key, required this.onResult});

  @override
  State<ScanOrManualDialog> createState() => _ScanOrManualDialogState();
}

class _ScanOrManualDialogState extends State<ScanOrManualDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _showScanner = false;
  String? _scanResult;

  void _openScanner() async {
    setState(() {
      _showScanner = true;
    });
  }

  void _onScan(String code) {
    setState(() {
      _scanResult = code;
      _showScanner = false;
    });
    widget.onResult(code);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      // Substitua pelo widget do pacote escolhido
      return Scaffold(
        appBar: AppBar(title: const Text('Escanear QR Code')),
        body: Center(
          child: Text('Aqui vai o scanner de QR code'),
          // Exemplo com mobile_scanner:
          // MobileScanner(
          //   onDetect: (barcode, args) {
          //     if (barcode.rawValue != null) {
          //       _onScan(barcode.rawValue!);
          //     }
          //   },
          // ),
        ),
      );
    }
    return AlertDialog(
      title: const Text('Informe o número da ficha'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Número da ficha',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code),
            label: const Text('Escanear QR Code'),
            onPressed: _openScanner,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Confirmar'),
          onPressed: () {
            final ficha = _controller.text.trim();
            if (ficha.isNotEmpty) {
              widget.onResult(ficha);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
