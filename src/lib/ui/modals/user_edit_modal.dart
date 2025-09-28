import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/stock_model.dart';
import '../widgets/custom_modal.dart';
import '../../core/services/api_service.dart';

/// Widget interno para o modal de vinculação de estoques.
/// Gerencia um estado local das seleções e só envia para a API ao salvar.
class _LinkStockContent extends StatefulWidget {
  final String userId;
  final List<StockModel> availableStocks;
  final List<dynamic> initiallyLinkedStocks;
  final Function(String userId, String stockId, String responsibility)
  onLinkStock;
  final Function(String userId, String stockId) onUnlinkStock;

  const _LinkStockContent({
    required this.userId,
    required this.availableStocks,
    required this.initiallyLinkedStocks,
    required this.onLinkStock,
    required this.onUnlinkStock,
  });

  @override
  State<_LinkStockContent> createState() => _LinkStockContentState();
}

class _LinkStockContentState extends State<_LinkStockContent> {
  // Guarda o estado inicial para comparação no momento de salvar
  late final Set<String> _initialLinkedStockIds;
  // Guarda o estado atual que o usuário está modificando
  late final Set<String> _currentLinkedStockIds;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Extrai os IDs dos estoques inicialmente vinculados
    final initialIds = widget.initiallyLinkedStocks
        .map((stock) => stock['stockId']?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    // Inicializa ambos os conjuntos de estado com os mesmos valores
    _initialLinkedStockIds = Set.from(initialIds);
    _currentLinkedStockIds = Set.from(initialIds);
  }

  /// Processa as alterações, comparando o estado inicial com o final
  /// e executando as chamadas de API necessárias.
  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calcula as diferenças entre o estado inicial e o estado atual
      final stocksToLink = _currentLinkedStockIds.difference(
        _initialLinkedStockIds,
      );
      final stocksToUnlink = _initialLinkedStockIds.difference(
        _currentLinkedStockIds,
      );

      // Cria uma lista de todas as operações de API a serem executadas
      final List<Future> operations = [];

      for (final stockId in stocksToLink) {
        operations.add(widget.onLinkStock(widget.userId, stockId, 'USER'));
      }
      for (final stockId in stocksToUnlink) {
        operations.add(widget.onUnlinkStock(widget.userId, stockId));
      }

      // Executa todas as operações em paralelo
      if (operations.isNotEmpty) {
        await Future.wait(operations);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alterações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Fecha o modal e retorna 'true' para indicar que mudanças foram feitas
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alterações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.separated(
              itemCount: widget.availableStocks.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final stock = widget.availableStocks[index];
                final isLinked = _currentLinkedStockIds.contains(stock.id);

                return ListTile(
                  title: Text(
                    stock.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    stock.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isLinked,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                if (value) {
                                  _currentLinkedStockIds.add(stock.id);
                                } else {
                                  _currentLinkedStockIds.remove(stock.id);
                                }
                              });
                            },
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomModalButton(
                text: 'Salvar Alterações',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Modal principal para editar os dados de um usuário.
class UserEditModal extends StatefulWidget {
  final UserModel user;
  final List<StockModel> availableStocks;
  final Function(
    String userId,
    String name,
    String email,
    String role,
    bool isActive,
  )
  onUpdate;
  final Function(String userId) onDelete;
  final Function(String userId, String stockId, String responsibility)
  onLinkStock;
  final Function(String userId, String stockId) onUnlinkStock;

  const UserEditModal({
    Key? key,
    required this.user,
    required this.availableStocks,
    required this.onUpdate,
    required this.onDelete,
    required this.onLinkStock,
    required this.onUnlinkStock,
  }) : super(key: key);

  @override
  State<UserEditModal> createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late String _selectedRole;
  late bool _isActive;
  bool _isLoading = false;
  List<dynamic> _userStocks = [];

  final List<Map<String, String>> _roles = [
    {'value': 'SOLDADO', 'label': 'Soldado'},
    {'value': 'SUPERVISOR', 'label': 'Supervisor'},
    {'value': 'ADMIN', 'label': 'Administrador'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;

    if (_selectedRole == 'SOLDADO') {
      _loadUserStocks();
    }
  }

  Future<void> _loadUserStocks() async {
    try {
      final apiService = ApiService();
      _userStocks = await apiService.getUserStocks(widget.user.id);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar estoques do usuário: $e');
    }
  }

  /// Abre o modal secundário para gerenciar a vinculação de estoques.
  Future<void> _showLinkStockModal() async {
    final bool? changesWereSaved = await CustomModal.show<bool>(
      context: context,
      title: 'Vincular Estoques para ${widget.user.name}',
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      child: _LinkStockContent(
        userId: widget.user.id,
        availableStocks: widget.availableStocks,
        initiallyLinkedStocks: _userStocks,
        onLinkStock: widget.onLinkStock,
        onUnlinkStock: widget.onUnlinkStock,
      ),
    );

    // Apenas recarrega os estoques se o modal de vínculo retornou 'true'.
    if (changesWereSaved == true) {
      await _loadUserStocks();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  Future<void> _handleDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o usuário ${widget.user.name}?',
        ),
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
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);

    try {
      await widget.onDelete(widget.user.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir usuário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(
                widget.user.name.isNotEmpty
                    ? widget.user.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomModalTextField(
            label: 'Nome completo',
            controller: _nameController,
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          CustomModalTextField(
            label: 'Email',
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Função',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role['value'],
                      child: Text(role['label']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                        if (newValue == 'SOLDADO') {
                          _loadUserStocks();
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedRole == 'SOLDADO' &&
              widget.availableStocks.isNotEmpty) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Icon(Icons.inventory_2_outlined),
              ),
              title: const Text('Vincular Estoques'),
              subtitle: Text(
                '${_userStocks.length} de ${widget.availableStocks.length} vinculado(s)',
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.arrow_forward_ios, size: 16),
              ),
              onTap: _showLinkStockModal,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              const Text(
                'Status:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
              Text(
                _isActive ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  color: _isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomModalButton(
                  text: 'Salvar Alterações',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _manageStockLinks() async {
    try {
      if (_selectedRole != 'SOLDADO') {
        for (var userStock in _userStocks) {
          final stockId = userStock['stockId']?.toString();
          if (stockId != null) {
            await widget.onUnlinkStock(widget.user.id, stockId);
          }
        }
      }
    } catch (e) {
      print('Erro ao gerenciar vinculações de estoque: $e');
      rethrow;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onUpdate(
        widget.user.id,
        _nameController.text.trim(),
        _emailController.text.trim(),
        _selectedRole,
        _isActive,
      );

      await _manageStockLinks();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar usuário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Classe auxiliar para exibir o modal de edição de usuário.
class UserEditHelper {
  static Future<void> showModal({
    required BuildContext context,
    required UserModel user,
    required List<StockModel> availableStocks,
    required Function(
      String userId,
      String name,
      String email,
      String role,
      bool isActive,
    )
    onUpdate,
    required Function(String userId) onDelete,
    required Function(String userId, String stockId, String responsibility)
    onLinkStock,
    required Function(String userId, String stockId) onUnlinkStock,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Editar Usuário: ${user.name}',
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.75,
      child: UserEditModal(
        user: user,
        availableStocks: availableStocks,
        onUpdate: onUpdate,
        onDelete: onDelete,
        onLinkStock: onLinkStock,
        onUnlinkStock: onUnlinkStock,
      ),
    );
  }
}
