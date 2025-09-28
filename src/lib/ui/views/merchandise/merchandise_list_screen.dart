import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/widgets/merchandise_card.dart';
import 'package:api2025/data/models/merchandise_type_model.dart';
import 'package:api2025/core/providers/merchandise_type_provider.dart';
import 'package:api2025/core/providers/stock_provider.dart';
import 'package:api2025/data/enums/merchandise_enums.dart';
import 'package:provider/provider.dart';
import 'widgets/create_merchandise_type_modal.dart';
import 'merchandise_detail_screen.dart';

class MerchandiseListScreen extends StatefulWidget {
  final String title;

  const MerchandiseListScreen({
    super.key,
    this.title = "CONTROLE DE ESTOQUE",
  });

  @override
  State<MerchandiseListScreen> createState() => _MerchandiseListScreenState();
}

class _MerchandiseListScreenState extends State<MerchandiseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Garante que o provider seja chamado após o build da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMerchandiseTypes();
    });
  }

  void _loadMerchandiseTypes() {
    print("Método _loadMerchandiseTypes chamado");
    final merchandiseProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final selectedStock = stockProvider.selectedStock;
    
    if (selectedStock != null) {
      print("Carregando tipos de mercadoria para o stock: ${selectedStock.id}");
      merchandiseProvider.loadMerchandiseTypes(stockId: selectedStock.id);
    } else {
      print("Nenhum stock selecionado, carregando todos os tipos de mercadoria");
      merchandiseProvider.loadMerchandiseTypes();
    }
  }

  List<MerchandiseTypeModel> _filterMerchandise(List<MerchandiseTypeModel> merchandises) {
    List<MerchandiseTypeModel> filtered = merchandises;

    // Aplicar busca por texto
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((merchandise) {
        final query = _searchQuery.toLowerCase();
        return merchandise.name.toLowerCase().contains(query) ||
            merchandise.recordNumber.toLowerCase().contains(query) ||
            merchandise.unitOfMeasure.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
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
            sizeHeader: 450,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                // Campo de busca
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por nome, registro ou unidade',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                // Lista de mercadorias
                Expanded(
                  child: Consumer<MerchandiseTypeProvider>(
                    builder: (context, merchandiseProvider, child) {
                      if (merchandiseProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bluePrimary,
                          ),
                        );
                      }

                      if (merchandiseProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Erro ao carregar mercadorias',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                merchandiseProvider.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadMerchandiseTypes,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bluePrimary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filtrar mercadorias
                      List<MerchandiseTypeModel> filteredMerchandises = 
                          _filterMerchandise(merchandiseProvider.merchandiseTypes);

                      if (filteredMerchandises.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma mercadoria encontrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tente ajustar os filtros ou adicionar novos itens',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: filteredMerchandises.length,
                        itemBuilder: (context, index) {
                          final merchandise = filteredMerchandises[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: MerchandiseCard(
                              merchandise: merchandise,
                              onTap: () async {
                                // Navegar para tela de detalhes
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MerchandiseDetailScreen(
                                      merchandise: merchandise,
                                    ),
                                  ),
                                );
                                
                                // Se houve alteração (edição ou exclusão), recarregar lista
                                if (result == true) {
                                  _loadMerchandiseTypes();
                                }
                              },
                              onEdit: () => _editMerchandise(context, merchandise),
                              onDelete: () => _deleteMerchandise(context, merchandise),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createMerchandise(context),
        backgroundColor: AppColors.bluePrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }



  Future<void> _createMerchandise(BuildContext context) async {
    final result = await CreateMerchandiseTypeModal.show(context);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mercadoria criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editMerchandise(BuildContext context, MerchandiseTypeModel merchandise) async {
    // TODO: Implementar modal de edição ou melhorar o modal existente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de edição ainda não implementada'),
        backgroundColor: Colors.orange,
      ),
    );
    
    /*
    final result = await CreateMerchandiseTypeModal.show(context);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mercadoria atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    */
  }

  Future<void> _deleteMerchandise(BuildContext context, MerchandiseTypeModel merchandise) async {
    // Mostrar diálogo de confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir ${merchandise.name}?'),
          content: const Text(
            'Tem certeza que deseja excluir esta mercadoria? Esta ação não pode ser desfeita.',
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
        );
      },
    );

    if (confirmed == true && merchandise.id != null && mounted) {
      try {
        final merchandiseProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
        final success = await merchandiseProvider.deleteMerchandiseType(merchandise.id!);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mercadoria excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Verificar se é erro específico de produto em uso
          String errorMessage = merchandiseProvider.errorMessage ?? 'Erro ao excluir mercadoria';
          Color backgroundColor = Colors.red;
          
          if (errorMessage.toLowerCase().contains('pedido')) {
            backgroundColor = Colors.orange;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 4), // Mais tempo para ler a mensagem
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir mercadoria: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}