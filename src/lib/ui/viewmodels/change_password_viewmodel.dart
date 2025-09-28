// lib/ui/viewmodels/change_password_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final BuildContext context;

  ChangePasswordViewModel(this.context);

  // Propriedades de estado
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCurrentPasswordVisible => _isCurrentPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // Toggle para mostrar/esconder senhas
  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  // Alterar senha
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Validações básicas
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _setError('Todos os campos são obrigatórios');
      return false;
    }

    if (newPassword.length < 6) {
      _setError('A nova senha deve ter pelo menos 6 caracteres');
      return false;
    }

    if (currentPassword == newPassword) {
      _setError('A nova senha deve ser diferente da senha atual');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Primeiro, reautenticar o usuário com a senha atual
      final reauthSuccess = await userProvider.reauthenticateUser(
        currentPassword,
      );

      if (!reauthSuccess) {
        _setError('Senha atual incorreta');
        return false;
      }

      // Se a reautenticação foi bem-sucedida, alterar a senha
      final changeSuccess = await userProvider.updatePassword(newPassword);

      if (changeSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(userProvider.errorMessage ?? 'Falha ao alterar a senha');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  // Validação de senha forte
  bool isStrongPassword(String password) {
    if (password.length < 6) return false;

    // Verificar se tem pelo menos uma letra maiúscula
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    // Verificar se tem pelo menos uma letra minúscula
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    // Verificar se tem pelo menos um número
    bool hasNumber = password.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasLowercase && hasNumber;
  }

  // Obter dicas de senha baseadas no que está faltando
  List<String> getPasswordTips(String password) {
    List<String> tips = [];

    if (password.length < 6) {
      tips.add('Mínimo de 6 caracteres');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      tips.add('Pelo menos uma letra maiúscula');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      tips.add('Pelo menos uma letra minúscula');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      tips.add('Pelo menos um número');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      tips.add('Pelo menos um símbolo especial');
    }

    return tips;
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
