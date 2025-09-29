import 'dart:ui';

import 'package:api2025/core/constants/app_colors.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String validUntil;
  final String createdAt;
  final bool isActive;

  const UserModel({
    required this.email, 
    required this.name, 
    required this.role, 
    required this.validUntil, 
    required this.createdAt, 
    required this.isActive, 
    required this.id
    });

  // Métodos getters
  String get getId => id;
  String get getEmail => email;
  String get getName => name;
  String get getRole => role;
  String get getValidUntil => validUntil;
  String get getCreatedAt => createdAt;
  bool get getIsActive => isActive;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      validUntil: json['validUntil'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'validUntil': validUntil,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}

// EXTENSÃO PARA LÓGICA DE APRESENTAÇÃO
extension UserDisplayExtension on UserModel {
  Color get roleColor {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return AppColors.red;
      case 'SUPERVISOR':
        return AppColors.orange;
      case 'SOLDADO':
        return AppColors.bluePrimary;
      default:
        return AppColors.gray;
    }
  }

  String get roleDisplayName {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'SUPERVISOR':
        return 'Supervisor';
      case 'SOLDADO':
        return 'Soldado';
      default:
        return role;
    }
  }

  String get formattedCreatedAt {
    return _formatDate(createdAt);
  }

  String get formattedValidUntil {
    return _formatDate(validUntil);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString; // Retorna a string original se houver erro
    }
  }
}