import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/providers/stock_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/stock_model.dart';

class UserEditHelper {
  static void show({
    required BuildContext context,
    required UserModel user,
    required List<StockModel> availableStocks,
    required VoidCallback onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserEditModal(
        user: user,
        availableStocks: availableStocks,
        onSuccess: onSuccess,
      ),
    ).then((_) {
      // Chamar onSuccess quando o modal for fechado por qualquer motivo
      onSuccess();
    });
  }
}

class UserEditModal extends StatefulWidget {
  final UserModel user;
  final List<StockModel> availableStocks;
  final VoidCallback onSuccess;

  const UserEditModal({
    super.key,
    required this.user,
    required this.availableStocks,
    required this.onSuccess,
  });

  @override
  State<UserEditModal> createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedRole;
  late bool _isActive;
  bool _isEditing = false;
  bool _isLoading = false;
  List<String> _userStockIds = [];
  List<StockModel> _userStocks = [];

  final List<String> _roleOptions = ['ADMIN', 'SUPERVISOR', 'SOLDADO', 'PACIENTE'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
    
    // Carregar estoques após o build estar completo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserStocks();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStocks() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final stocks = await userProvider.getUserStocks(widget.user.id);
      
      print('Estoques carregados: $stocks');
      
      setState(() {
        // Verificar se stocks é uma lista de Maps ou uma lista simples
        if (stocks.isNotEmpty && stocks[0] is Map) {
          _userStockIds = stocks.map((stock) {
            if (stock is Map) {
              return stock['stockId'] as String? ?? stock['id'] as String? ?? '';
            }
            return '';
          }).where((id) => id.isNotEmpty).toList();
        } else {
          // Se não for uma lista de Maps, tentar tratar como lista de strings (IDs)
          _userStockIds = stocks
              .where((stock) => stock is String)
              .map((stock) => stock as String)
              .toList();
        }
        
        _userStocks = widget.availableStocks
            .where((stock) => _userStockIds.contains(stock.id))
            .toList();
        
        print('IDs dos estoques do usuário: $_userStockIds');
        print('Estoques vinculados: ${_userStocks.map((s) => s.name).toList()}');
      });
    } catch (e) {
      print('Erro ao carregar estoques do usuário: $e');
      // Não mostrar erro para pacientes, pois eles não têm estoques vinculados
      if (widget.user.role.toUpperCase() != 'PACIENTE') {
        _showSnackBar('Erro ao carregar estoques do usuário: $e');
      }
      setState(() {
        _userStockIds = [];
        _userStocks = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUser() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.updateUser(
        widget.user.id,
        _nameController.text.trim(),
        _emailController.text.trim(),
        _selectedRole,
        _isActive,
      );

      if (success) {
        _showSnackBar('Usuário atualizado com sucesso!');
        widget.onSuccess();
        Navigator.of(context).pop();
      } else {
        _showSnackBar('Erro ao atualizar usuário.');
      }
    } catch (e) {
      _showSnackBar('Erro ao atualizar usuário: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteUser(widget.user.id);

      if (success) {
        _showSnackBar('Usuário excluído com sucesso!');
        widget.onSuccess();
        Navigator.of(context).pop();
      } else {
        _showSnackBar('Erro ao excluir usuário.');
      }
    } catch (e) {
      _showSnackBar('Erro ao excluir usuário: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o usuário "${widget.user.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _linkStock(StockModel stock) async {
    setState(() => _isLoading = true);
    try {
      print('Vinculando usuário ${widget.user.name} ao estoque ${stock.name}');
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.linkUserToStock(
        widget.user.id,
        stock.id,
        _selectedRole == 'SUPERVISOR' ? 'MANAGER' : 'USER',
      );

      if (success) {
        _showSnackBar('Usuário vinculado ao estoque "${stock.name}" com sucesso!');
        // Recarregar os estoques do usuário
        await _loadUserStocks();
      } else {
        _showSnackBar('Erro ao vincular usuário ao estoque.');
      }
    } catch (e) {
      print('Erro ao vincular estoque: $e');
      _showSnackBar('Erro ao vincular usuário ao estoque: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlinkStock(StockModel stock) async {
    setState(() => _isLoading = true);
    try {
      print('Desvinculando usuário ${widget.user.name} do estoque ${stock.name}');
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.unlinkUserFromStock(widget.user.id, stock.id);

      if (success) {
        _showSnackBar('Usuário desvinculado do estoque "${stock.name}" com sucesso!');
        // Recarregar os estoques do usuário
        await _loadUserStocks();
      } else {
        _showSnackBar('Erro ao desvincular usuário do estoque.');
      }
    } catch (e) {
      print('Erro ao desvincular estoque: $e');
      _showSnackBar('Erro ao desvincular usuário do estoque: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bluePrimary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Detalhes do Usuário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informações básicas
                        _buildUserInfo(),
                        const SizedBox(height: 24),
                        
                        // Gerenciamento de estoques (apenas para Soldado e Supervisor)
                        if (_selectedRole == 'SOLDADO' || _selectedRole == 'SUPERVISOR')
                          _buildStockManagement(),
                        
                        const SizedBox(height: 24),
                        
                        // Botões de ação
                        _buildActionButtons(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.user.roleColor.withOpacity(0.1),
                  radius: 30,
                  child: Text(
                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: widget.user.roleColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.user.roleColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.user.roleDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(
                      widget.user.isActive ? Icons.check_circle : Icons.cancel,
                      color: widget.user.isActive ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    Text(
                      widget.user.isActive ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.user.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Campos editáveis
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Função',
                  border: OutlineInputBorder(),
                ),
                menuMaxHeight: 300,
                items: _roleOptions.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value ?? false);
                    },
                  ),
                  const Text('Usuário ativo'),
                ],
              ),
            ] else ...[
              // Informações somente leitura
              _buildInfoRow('ID', widget.user.id),
              _buildInfoRow('Criado em', widget.user.formattedCreatedAt),
              _buildInfoRow('Válido até', widget.user.formattedValidUntil),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStockManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: AppColors.bluePrimary),
                const SizedBox(width: 8),
                const Text(
                  'Estoques Vinculados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista de estoques vinculados
            if (_userStocks.isEmpty)
              const Text('Nenhum estoque vinculado')
            else
              ..._userStocks.map((stock) => _buildStockItem(stock)),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Botão para adicionar estoque
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showStockSelection,
                icon: const Icon(Icons.add),
                label: const Text('Vincular Estoque'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(StockModel stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warehouse,
            color: stock.active ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  stock.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _unlinkStock(stock),
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            tooltip: 'Desvincular',
          ),
        ],
      ),
    );
  }

  void _showStockSelection() {
    print('Estoques disponíveis: ${widget.availableStocks.map((s) => s.name).toList()}');
    print('IDs dos estoques já vinculados: $_userStockIds');
    
    final availableStocks = widget.availableStocks
        .where((stock) => !_userStockIds.contains(stock.id))
        .toList();

    print('Estoques disponíveis para seleção: ${availableStocks.map((s) => s.name).toList()}');

    if (availableStocks.isEmpty) {
      _showSnackBar('Todos os estoques já estão vinculados a este usuário.');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecionar Estoque',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...availableStocks.map((stock) => ListTile(
              leading: const Icon(Icons.warehouse),
              title: Text(stock.name),
              subtitle: Text(stock.location),
              onTap: () {
                Navigator.of(context).pop();
                _linkStock(stock);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_isEditing) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _deleteUser,
              icon: const Icon(Icons.delete),
              label: const Text('Excluir Usuário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
