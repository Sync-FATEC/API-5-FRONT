// lib/core/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String?> _userData = {};
  UserModel? _apiUserData;
  List<UserModel> _allUsers = [];
  String _searchQuery = '';

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get userData => _userData;
  UserModel? get apiUserData => _apiUserData;
  bool get isLoggedIn => _currentUser != null;
  String get userEmail => _currentUser?.email ?? _userData['user_email'] ?? '';
  String get userDisplayName =>
      _apiUserData?.name ??
      _currentUser?.displayName ??
      _userData['user_display_name'] ??
      '';
  String get userId => _currentUser?.uid ?? _userData['user_id'] ?? '';
  String get userRole => _apiUserData?.role ?? '';
  bool get isUserActive => _apiUserData?.isActive ?? false;
  String get userValidUntil => _apiUserData?.validUntil ?? '';
  bool get isAdmin => _apiUserData?.role.toUpperCase() == 'ADMIN';

  UserProvider() {
    _initializeUser();
    _listenToAuthChanges();
  }

  List<UserModel> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return _allUsers;
    }
    return _allUsers.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }


  // Inicializar usuário ao abrir o app
  Future<void> _initializeUser() async {
    _setLoading(true);
    try {
      // Verificar se há usuário logado no Firebase
      _currentUser = _authService.currentUser;

      // Se não há usuário no Firebase, verificar dados locais
      if (_currentUser == null) {
        final isLoggedIn = await _authService.isLoggedIn();
        if (isLoggedIn) {
          _userData = await _authService.getUserData();
          _apiUserData = await _loadApiUserData();
        }
      } else {
        // Se há usuário no Firebase, obter dados locais
        _userData = await _authService.getUserData();
        _apiUserData = await _loadApiUserData();
      }
    } catch (e) {
      _setError('Erro ao inicializar usuário: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Escutar mudanças no estado de autenticação
  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user == null) {
        _userData = {};
      }
      notifyListeners();
    });
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        _currentUser = credential!.user;
        _userData = await _authService.getUserData();

        // Fazer chamada da API para buscar dados do usuário
        print('Iniciando chamada da API para o email: $email');
        try {
          final apiResponse = await _apiService.getUserData(email);
          print('Resposta da API recebida: ${apiResponse?.data}');
          _apiUserData = apiResponse?.data;

          // Salvar dados da API localmente
          await _saveApiUserData(_apiUserData);
          print('Dados da API salvos localmente');
        } catch (apiError) {
          // Se a API falhar, continua com o login do Firebase
          print('Erro ao buscar dados da API: $apiError');
        }

        _setLoading(false);
        return true;
      }

      _setError('Falha no login');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Registro
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        _currentUser = credential!.user;
        _userData = await _authService.getUserData();
        _setLoading(false);
        return true;
      }

      _setError('Falha no registro');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      await _clearApiUserData();
      _currentUser = null;
      _userData = {};
      _apiUserData = null;
    } catch (e) {
      _setError('Erro ao fazer logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset de senha
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reautenticar usuário
  Future<bool> reauthenticateUser(String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.reauthenticateUser(password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // do usuário
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Alterar senha via API
  Future<bool> changePasswordViaAPI({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final email = userEmail;
      if (email.isEmpty) {
        throw Exception('Email do usuário não encontrado');
      }

      final success = await _authService.changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUserData() async {
    if (_currentUser != null) {
      _userData = await _authService.getUserData();
      notifyListeners();
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

  // Salvar dados da API localmente
  Future<void> _saveApiUserData(UserModel? userData) async {
    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_user_id', userData.id);
      await prefs.setString('api_user_email', userData.email);
      await prefs.setString('api_user_name', userData.name);
      await prefs.setString('api_user_role', userData.role);
      await prefs.setString('api_user_valid_until', userData.validUntil);
      await prefs.setString('api_user_created_at', userData.createdAt);
      await prefs.setBool('api_user_is_active', userData.isActive);
    }
  }

  // Carregar dados da API salvos localmente
  Future<UserModel?> _loadApiUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('api_user_id');

    if (id != null) {
      return UserModel(
        id: id,
        email: prefs.getString('api_user_email') ?? '',
        name: prefs.getString('api_user_name') ?? '',
        role: prefs.getString('api_user_role') ?? '',
        validUntil: prefs.getString('api_user_valid_until') ?? '',
        createdAt: prefs.getString('api_user_created_at') ?? '',
        isActive: prefs.getBool('api_user_is_active') ?? false,
      );
    }

    return null;
  }

  // Limpar dados da API salvos localmente
  Future<void> _clearApiUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_user_id');
    await prefs.remove('api_user_email');
    await prefs.remove('api_user_name');
    await prefs.remove('api_user_role');
    await prefs.remove('api_user_valid_until');
    await prefs.remove('api_user_created_at');
    await prefs.remove('api_user_is_active');
  }

  // Criar novo usuário
  Future<bool> createUser(String name, String email, String role) async {
    _setLoading(true);
    _clearError();

    try {
      print(
        'UserProvider: Criando usuário - Nome: $name, Email: $email, Role: $role',
      );

      final apiResponse = await _apiService.createUser(name, email, role);

      if (apiResponse != null && apiResponse.data != null) {
        print(
          'UserProvider: Usuário criado com sucesso - ${apiResponse.data!.name}',
        );
        _setLoading(false);
        return true;
      } else {
        throw Exception('Falha ao criar usuário');
      }
    } catch (e) {
      print('UserProvider: Erro ao criar usuário - $e');
      _setError('Erro ao criar usuário: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Listar todos os usuários
  Future<List<UserModel>> getAllUsers() async {
    _setLoading(true);
    _clearError();

    try {
      print('UserProvider: Buscando todos os usuários');

      final users = await _apiService.getAllUsers();
      print('UserProvider: ${users.length} usuários encontrados');

      _setLoading(false);
      return users;
    } catch (e) {
      print('UserProvider: Erro ao buscar usuários - $e');
      _setError('Erro ao buscar usuários: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

    Future<void> fetchAllUsers() async {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        // Supondo que o serviço retorne List<UserModel>
        _allUsers = await _apiService.getAllUsers();
      } catch (e) {
        _errorMessage = 'Erro ao carregar usuários: ${e.toString()}';
        _allUsers = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

  // Atualizar usuário
  Future<bool> updateUser(
    String userId,
    String name,
    String email,
    String role,
    bool isActive,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      print('UserProvider: Atualizando usuário $userId');

      final apiResponse = await _apiService.updateUser(
        userId,
        name,
        email,
        role,
        isActive,
      );

      if (apiResponse != null && apiResponse.data != null) {
        print('UserProvider: Usuário atualizado com sucesso');
        _setLoading(false);
        return true;
      } else {
        throw Exception('Falha ao atualizar usuário');
      }
    } catch (e) {
      print('UserProvider: Erro ao atualizar usuário - $e');
      _setError('Erro ao atualizar usuário: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Deletar usuário
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      print('UserProvider: Deletando usuário $userId');

      final success = await _apiService.deleteUser(userId);

      if (success) {
        print('UserProvider: Usuário deletado com sucesso');
        _setLoading(false);
        return true;
      } else {
        throw Exception('Falha ao deletar usuário');
      }
    } catch (e) {
      print('UserProvider: Erro ao deletar usuário - $e');
      _setError('Erro ao deletar usuário: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Vincular usuário a estoque
  Future<bool> linkUserToStock(
    String userId,
    String stockId,
    String responsibility,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      print(
        'UserProvider: Vinculando usuário $userId ao estoque $stockId com responsabilidade $responsibility',
      );

      final success = await _apiService.linkUserToStock(
        userId,
        stockId,
        responsibility,
      );

      if (success) {
        print('UserProvider: Usuário vinculado ao estoque com sucesso');
        _setLoading(false);
        return true;
      } else {
        throw Exception('Falha ao vincular usuário ao estoque');
      }
    } catch (e) {
      print('UserProvider: Erro ao vincular usuário ao estoque - $e');
      _setError('Erro ao vincular usuário ao estoque: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Desvincular usuário de estoque
  Future<bool> unlinkUserFromStock(String userId, String stockId) async {
    _setLoading(true);
    _clearError();

    try {
      print('UserProvider: Desvinculando usuário $userId do estoque $stockId');

      final success = await _apiService.unlinkUserFromStock(userId, stockId);

      if (success) {
        print('UserProvider: Usuário desvinculado do estoque com sucesso');
        _setLoading(false);
        return true;
      } else {
        throw Exception('Falha ao desvincular usuário do estoque');
      }
    } catch (e) {
      print('UserProvider: Erro ao desvincular usuário do estoque - $e');
      _setError('Erro ao desvincular usuário do estoque: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar estoques do usuário
  Future<List<dynamic>> getUserStocks(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      print('UserProvider: Buscando estoques do usuário $userId');

      final stocks = await _apiService.getUserStocks(userId);

      print(
        'UserProvider: ${stocks.length} estoques encontrados para o usuário',
      );
      _setLoading(false);
      return stocks;
    } catch (e) {
      print('UserProvider: Erro ao buscar estoques do usuário - $e');
      _setError('Erro ao buscar estoques do usuário: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }
}
