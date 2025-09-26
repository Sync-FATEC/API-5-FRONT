// lib/ui/viewmodels/forgot_password_viewmodel.dart

import 'package:flutter/material.dart';
import '../../core/services/http_client.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Validar e-mail
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Enviar e-mail de recuperação
  Future<bool> sendResetEmail(String email) async {
    if (!isValidEmail(email)) {
      _setError('Por favor, digite um e-mail válido');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await HttpClient.put(
        '/auth/forgot-password',
        body: {
          'email': email,
        },
      );

      if (response.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Erro de conexão: Verifique sua internet e tente novamente');
      return false;
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpar erro manualmente
  void clearError() {
    _clearError();
  }
}