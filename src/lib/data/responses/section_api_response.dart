import '../models/section_model.dart';

class SectionApiResponse {
  final bool success;
  final List<SectionModel> data;
  final String message;

  SectionApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SectionApiResponse.fromJson(Map<String, dynamic> json) {
    return SectionApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => SectionModel.fromJson(item))
                .toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}
