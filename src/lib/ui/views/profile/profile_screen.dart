import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/ui/widgets/bottom_nav_bar_widget.dart';
import 'package:api2025/ui/widgets/change_password_modal.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(title: "PERFIL"),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.apiUserData;
              print(user?.name);
              return Container(); // Replace with your actual widget
            },
          ),
          Positioned(
            top: 120,
            left: 20,
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, size: 70, color: AppColors.gray),
            ),
          ),
          Positioned(
            top: 125,
            left: 140,
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.apiUserData;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Usuário',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Email não disponível',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.role ?? 'Role não disponível',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: 310,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  // Verificar se o usuário é admin ou supervisor
                  final userRole =
                      userProvider.apiUserData?.role.toLowerCase() ?? '';
                  final canChangeAccess =
                      userRole == 'admin' || userRole == 'supervisor';

                  return Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.lock,
                        title: 'Alterar senha',
                        onTap: () async {
                          final result = await ChangePasswordModal.show(
                            context,
                          );
                          if (result == true) {
                            // Senha alterada com sucesso - feedback já mostrado no modal
                          }
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.sync,
                        title: 'Alterar acesso',
                        onTap: () {
                          _navigateToChangeStock(context);
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.exit_to_app,
                        title: 'Sair',
                        onTap: () {
                          _logout(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 5),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gray),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _logout(BuildContext context) async {
    Navigator.of(context).pushReplacementNamed('/login');

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();
  }

  void _navigateToChangeStock(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/stock-selection',(route) => false,);
  }
}
