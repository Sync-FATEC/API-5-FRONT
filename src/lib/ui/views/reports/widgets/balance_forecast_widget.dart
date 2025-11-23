import 'package:flutter/material.dart';
import 'package:api2025/core/services/api_service.dart';

class BalanceForecastWidget extends StatefulWidget {
  final int months;
  const BalanceForecastWidget({super.key, this.months = 6});

  @override
  State<BalanceForecastWidget> createState() => _BalanceForecastWidgetState();
}

class _BalanceForecastWidgetState extends State<BalanceForecastWidget> {
  List<String> labels = [];
  List<double> values = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiService();
      final data = await api.getBalanceForecast(months: widget.months);
      final l =
          (data?['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final v =
          (data?['predictions'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [];
      setState(() {
        labels = l;
        values = v;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Adicionar pontos de milhar
    String result = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = intPart[i] + result;
      count++;
    }

    return 'R\$ $result,$decPart';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Erro: $error'),
      );
    }
    if (values.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Sem dados para previsão'),
      );
    }

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs() < 1e-6 ? 1.0 : (maxVal - minVal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Previsão de Saldo (próximos 6 meses)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _LineChartPainter(
                values: values,
                minVal: minVal,
                range: range,
                labels: labels,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 16),
          // Legendas com valores
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: labels.length,
            itemBuilder: (context, i) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(values[i]),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double range;
  final List<String> labels;

  _LineChartPainter({
    required this.values,
    required this.minVal,
    required this.range,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.5;
    final paintGrid = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1.0;
    final paintLine = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final paintGradient = Paint()..style = PaintingStyle.fill;
    final paintPoint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final paintPointBorder = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final padding = 16.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final origin = Offset(padding, size.height - padding);

    // Desenhar grid horizontal
    for (int i = 0; i <= 5; i++) {
      final y = origin.dy - chartHeight * (i / 5);
      canvas.drawLine(
        Offset(origin.dx, y),
        Offset(origin.dx + chartWidth, y),
        paintGrid,
      );
    }

    if (values.length < 2) return;

    final stepX = chartWidth / (values.length - 1);
    final path = Path();
    final gradientPath = Path();

    // Construir path da linha e do gradiente
    for (int i = 0; i < values.length; i++) {
      final vx = origin.dx + stepX * i;
      final vy = origin.dy - ((values[i] - minVal) / range) * chartHeight;

      if (i == 0) {
        path.moveTo(vx, vy);
        gradientPath.moveTo(vx, origin.dy);
        gradientPath.lineTo(vx, vy);
      } else {
        path.lineTo(vx, vy);
        gradientPath.lineTo(vx, vy);
      }

      if (i == values.length - 1) {
        gradientPath.lineTo(vx, origin.dy);
        gradientPath.close();
      }
    }

    // Desenhar gradiente sob a linha
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1976D2).withOpacity(0.3),
        const Color(0xFF1976D2).withOpacity(0.05),
      ],
    );
    paintGradient.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawPath(gradientPath, paintGradient);

    // Desenhar linha principal
    canvas.drawPath(path, paintLine);

    // Desenhar pontos e valores
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < values.length; i++) {
      final vx = origin.dx + stepX * i;
      final vy = origin.dy - ((values[i] - minVal) / range) * chartHeight;

      // Ponto com borda
      canvas.drawCircle(Offset(vx, vy), 5.0, paintPoint);
      canvas.drawCircle(Offset(vx, vy), 5.0, paintPointBorder);

      // Valor acima do ponto (formato simplificado para o gráfico)
      final simplifiedValue = values[i] >= 1000
          ? 'R\$ ${(values[i] / 1000).toStringAsFixed(0)}k'
          : 'R\$ ${values[i].toStringAsFixed(0)}';
      textPainter.text = TextSpan(
        text: simplifiedValue,
        style: const TextStyle(
          color: Color(0xFF1976D2),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          backgroundColor: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(vx - textPainter.width / 2, vy - textPainter.height - 8),
      );
    }

    // Desenhar eixos
    canvas.drawLine(
      Offset(origin.dx, origin.dy - chartHeight),
      origin,
      paintAxis,
    );
    canvas.drawLine(
      origin,
      Offset(origin.dx + chartWidth, origin.dy),
      paintAxis,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
