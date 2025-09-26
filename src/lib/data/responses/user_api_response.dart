import '../models/user_model.dart';

class UserApiResponse {
  final bool success;
  final UserModel? data;
  final String message;

  UserApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory UserApiResponse.fromJson(Map<String, dynamic> json) {
    return UserApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}
