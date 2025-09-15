// lib/ui/viewmodels/login_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class LoginViewModel extends ChangeNotifier {
  final BuildContext context;
  
  LoginViewModel(this.context);

  // Propriedades de estado privadas
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  // Getters públicos para a View acessar o estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  // Toggle para mostrar/esconder senha
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // A função principal que a View vai chamar
  Future<bool> login(String email, String password) async {
    // Validações básicas
    if (email.isEmpty || password.isEmpty) {
      _setError('E-mail e senha são obrigatórios.');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('Por favor, insira um e-mail válido.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.login(email, password);
      
      if (success) {
        print('Login realizado com sucesso!');
        return true;
      } else {
        _setError(userProvider.errorMessage ?? 'Falha no login');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset de senha
  Future<bool> resetPassword(String email) async {
    if (email.isEmpty) {
      _setError('Por favor, insira seu e-mail.');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('Por favor, insira um e-mail válido.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.resetPassword(email);
      
      if (success) {
        return true;
      } else {
        _setError(userProvider.errorMessage ?? 'Falha ao enviar e-mail de recuperação');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Validação de e-mail
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
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