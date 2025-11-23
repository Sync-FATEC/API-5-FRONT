import 'package:flutter/material.dart';
import 'widgets/balance_forecast_widget.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão de Saldo'),
      ),
      body: const SingleChildScrollView(
        child: BalanceForecastWidget(months: 6),
      ),
    );
  }
}