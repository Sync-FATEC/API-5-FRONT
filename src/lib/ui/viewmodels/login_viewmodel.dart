// lib/ui/viewmodels/login_viewmodel.dart

import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  // Propriedades de estado privadas
  bool _isLoading = false;
  String? _errorMessage;

  // Getters públicos para a View acessar o estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // A função principal que a View vai chamar
  Future<void> login(String email, String password) async {
    // 1. Inicia o estado de carregamento
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a View que o estado mudou

    try {
      // Simula uma chamada de API
      await Future.delayed(const Duration(seconds: 2));

      // LÓGICA DE LOGIN REAL IRIA AQUI
      if (email.isEmpty || password.isEmpty) {
        throw Exception('E-mail e senha são obrigatórios.');
      }

      if (email == 'teste@email.com' && password == '123') {
        print('Login bem-sucedido!');
        // TODO: Navegar para a próxima tela
      } else {
        throw Exception('Credenciais inválidas.');
      }

    } catch (e) {
      // 3a. Em caso de erro, atualiza a mensagem de erro
      _errorMessage = e.toString();
    } finally {
      // 3b. Finaliza o estado de carregamento
      _isLoading = false;
      notifyListeners(); // Notifica a View que o estado mudou novamente
    }
  }
}