import '../models/stock_model.dart';

// Classe para representar a resposta da API de estoques
class StockApiResponse {
  final bool success;
  final List<StockModel> data;
  final String message;

  StockApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory StockApiResponse.fromJson(Map<String, dynamic> json) {
    return StockApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => StockModel.fromJson(item))
                .toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}
