// lib/core/routing/role_router.dart
import 'package:flutter/foundation.dart';

/// Enum de roles suportados pelo app
enum Role {
  SOLDADO,
  SUPERVISOR,
  ADMIN,
  COORDENADOR_AGENDA,
  PACIENTE,
}

/// Converte string (case-insensitive) para Role
Role? roleFromString(String? value) {
  if (value == null || value.isEmpty) return null;
  switch (value.toUpperCase()) {
    case 'SOLDADO':
      return Role.SOLDADO;
    case 'SUPERVISOR':
      return Role.SUPERVISOR;
    case 'ADMIN':
      return Role.ADMIN;
    case 'COORDENADOR_AGENDA':
      return Role.COORDENADOR_AGENDA;
    case 'PACIENTE':
      return Role.PACIENTE;
    default:
      return null;
  }
}

/// Resolve a rota inicial após login, com base no role
String? resolveRedirectRoute(Role? role) {
  if (role == null) return null;
  switch (role) {
    case Role.COORDENADOR_AGENDA:
      // Tela de agendamentos com capacidades de criação/edição
      return '/appointments';
    case Role.PACIENTE:
      // Tela de agendamentos em modo somente visualização
      return '/appointments';
    case Role.ADMIN:
      // Direção padrão para Admin (pode ajustar conforme necessidade)
      return '/users';
    case Role.SUPERVISOR:
      // Supervisores para a Home por padrão
      return '/home';
    case Role.SOLDADO:
      // Soldados para seleção de estoque por padrão
      return '/stock-selection';
  }
}

