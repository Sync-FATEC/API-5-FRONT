// lib/data/models/exam_type_model.dart

/// Modelo de Tipo de Exame conforme documentação da API.
/// Campos originais da API (JSON):
/// - nome, descricao, duracaoEstimada, preparoNecessario, isActive, id
class ExamTypeModel {
  final String? id;
  final String name; // mapeia para 'nome'
  final String? description; // mapeia para 'descricao'
  final int estimatedDuration; // mapeia para 'duracaoEstimada' (minutos)
  final String? requiredPreparation; // mapeia para 'preparoNecessario'
  final bool isActive;

  const ExamTypeModel({
    this.id,
    required this.name,
    this.description,
    required this.estimatedDuration,
    this.requiredPreparation,
    this.isActive = true,
  });

  factory ExamTypeModel.fromJson(Map<String, dynamic> json) {
    return ExamTypeModel(
      id: json['id']?.toString(),
      name: (json['nome'] ?? json['name'] ?? '').toString(),
      description: (json['descricao'] ?? json['description'])?.toString(),
      estimatedDuration:
          int.tryParse((json['duracaoEstimada'] ?? '0').toString()) ?? 0,
      requiredPreparation:
          (json['preparoNecessario'] ?? json['requiredPreparation'])?.toString(),
      isActive: (json['isActive'] is bool)
          ? json['isActive'] as bool
          : (json['isActive']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'descricao': description,
      'duracaoEstimada': estimatedDuration,
      'preparoNecessario': requiredPreparation,
      'isActive': isActive,
    };
  }

  // Validações simples de dados para uso na UI/ViewModel
  bool get isValidName => name.trim().isNotEmpty;
  bool get isValidDuration => estimatedDuration > 0 && estimatedDuration <= 480; // até 8h
}