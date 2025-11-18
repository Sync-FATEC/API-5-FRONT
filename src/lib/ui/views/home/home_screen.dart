// lib/ui/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../widgets/header_icon.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../widgets/custom_card.dart';
import '../merchandise/merchandise_list_screen.dart';
import '../appointments/appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final userRole = userProvider.apiUserData?.role.toUpperCase() ?? '';

        // PACIENTE vê a lista de agendamentos
        if (userRole == 'PACIENTE') {
          return const AppointmentsScreen();
        }

        // Outros papéis veem a HOME normal com cards de cadastro
        return Scaffold(
          body: Stack(
            children: [
              Consumer<StockProvider>(
                builder: (context, stockProvider, child) {
                  final selectedStock = stockProvider.selectedStock;

                  if (selectedStock == null) {
                    return const HeaderIcon(
                      title: 'NENHUM ESTOQUE SELECIONADO',
                      sizeHeader: 180,
                    );
                  }

                  return HeaderIcon(
                    title: selectedStock.name.toUpperCase(),
                    subtitle: selectedStock.location,
                    sizeHeader: 180,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 140.0),
                child: Consumer2<UserProvider, StockProvider>(
                  builder: (context, userProvider, stockProvider, child) {
                    final user = userProvider.apiUserData;

                    if (user == null) {
                      return const Center(
                        child: Text('No user data available.'),
                      );
                    }

                    // Outros papéis veem os cards de cadastro e controle
                    return Column(
                      children: [
                        // Cards principais
                        CustomCard(
                          iconData: Icons.add_circle_outline,
                          title: 'Cadastro novo produto',
                          subtitle:
                              'Adicione novos produtos no\nseu estoque do ${stockProvider.selectedStock?.name ?? 'estoque'}',
                          onTap: () {
                            Navigator.pushNamed(context, '/merchandise-menu');
                            print('Navegando para cadastro de produto');
                          },
                        ),
                        CustomCard(
                          iconData: Icons.inventory_2_outlined,
                          title: 'Controle do Estoque',
                          subtitle:
                              'Visualizar e gerenciar tipos de mercadoria cadastrados no\n${stockProvider.selectedStock?.name ?? 'estoque'}',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MerchandiseListScreen(),
                              ),
                            );
                            print('Navegando para controle de estoque');
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
        );
      },
    );
  }
}
