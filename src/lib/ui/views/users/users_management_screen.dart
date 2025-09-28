import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/background_header.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../modals/user_edit_modal.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pede ao provider para carregar os dados assim que a tela iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditUserModal(BuildContext context, UserModel user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    UserEditHelper.showModal(
      context: context,
      user: user,
      availableStocks: stockProvider.stocks,
      onUpdate: userProvider.updateUser,
      onDelete: userProvider.deleteUser,
      onLinkStock: userProvider.linkUserToStock,
      onUnlinkStock: userProvider.unlinkUserFromStock,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(
            title: "VOLTAR",
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                // Barra de pesquisa
                _buildSearchBar(),
                // Lista de usuários
                Expanded(
                  child: Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(child: Text(provider.errorMessage!));
                      }
                      
                      if (provider.filteredUsers.isEmpty) {
                        return const Center(child: Text('Nenhum usuário encontrado.'));
                      }

                      return RefreshIndicator(
                        onRefresh: () => provider.fetchAllUsers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = provider.filteredUsers[index];
                            return _UserCard(
                              user: user,
                              onTap: () => _showEditUserModal(context, user),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 4),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar usuários...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<UserProvider>(context, listen: false).updateSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          Provider.of<UserProvider>(context, listen: false).updateSearchQuery(value);
        },
      ),
    );
  }
}

// O _UserCard agora é mais simples, pois usa a extensão do UserModel
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: user.roleColor.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(color: user.roleColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: user.roleColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(user.roleDisplayName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(user.isActive ? Icons.check_circle : Icons.cancel, color: user.isActive ? Colors.green : Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(user.isActive ? 'Ativo' : 'Inativo', style: TextStyle(fontSize: 12, color: user.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                 children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text('Criado em: ${user.formattedCreatedAt}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text('Válido até: ${user.formattedValidUntil}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                 ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}