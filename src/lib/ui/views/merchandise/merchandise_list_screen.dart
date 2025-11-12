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
import 'widgets/edit_merchandise_type_modal.dart';
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
  
  // Filtros
  bool? _filterControlled; // null = todos, true = controlado, false = não controlado
  String? _filterStockAlert; // null = todos, 'ok' = estoque ok, 'low' = estoque baixo
  MerchandiseGroup? _filterGroup; // null = todos, incluindo sem grupo
  bool _filterNoGroup = false; // true = filtrar apenas produtos sem grupo
  int _activeFiltersCount = 0;
  
  // Ordenação
  String? _sortOrder; // null = padrão, 'asc' = menor estoque, 'desc' = maior estoque
  int _activeSortCount = 0;

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

    // Aplicar filtro de controlado/não controlado
    if (_filterControlled != null) {
      filtered = filtered.where((merchandise) {
        return merchandise.controlled == _filterControlled;
      }).toList();
    }

    // Aplicar filtro de alerta de estoque
    if (_filterStockAlert != null) {
      filtered = filtered.where((merchandise) {
        final currentStock = merchandise.quantityTotal;
        final minimumStock = merchandise.minimumStock;
        
        if (_filterStockAlert == 'low') {
          return currentStock <= minimumStock;
        } else if (_filterStockAlert == 'ok') {
          return currentStock > minimumStock;
        }
        return true;
      }).toList();
    }

    // Aplicar filtro de grupo
    if (_filterNoGroup) {
      // Filtrar apenas produtos sem grupo
      filtered = filtered.where((merchandise) => merchandise.group == null).toList();
    } else if (_filterGroup != null) {
      // Filtrar por grupo específico
      filtered = filtered.where((merchandise) => merchandise.group == _filterGroup).toList();
    }

    // Aplicar ordenação
    if (_sortOrder != null) {
      filtered.sort((a, b) {
        final stockA = a.quantityTotal;
        final stockB = b.quantityTotal;
        
        if (_sortOrder == 'asc') {
          return stockA.compareTo(stockB); // Menor para maior
        } else if (_sortOrder == 'desc') {
          return stockB.compareTo(stockA); // Maior para menor
        }
        return 0;
      });
    }

    return filtered;
  }

  void _updateFilterCount() {
    int count = 0;
    if (_filterControlled != null) count++;
    if (_filterStockAlert != null) count++;
    if (_filterGroup != null || _filterNoGroup) count++;
    setState(() {
      _activeFiltersCount = count;
    });
  }

  void _updateSortCount() {
    setState(() {
      _activeSortCount = _sortOrder != null ? 1 : 0;
    });
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ordenação',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _sortOrder = null;
                          });
                          setState(() {
                            _sortOrder = null;
                            _updateSortCount();
                          });
                        },
                        child: const Text(
                          'Limpar',
                          style: TextStyle(color: AppColors.bluePrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Ordenação por Estoque
                  const Text(
                    'Ordenar por Quantidade em Estoque',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Opções de ordenação
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Padrão',
                    isSelected: _sortOrder == null,
                    onTap: () {
                      setModalState(() {
                        _sortOrder = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Menor Estoque Primeiro',
                    isSelected: _sortOrder == 'asc',
                    onTap: () {
                      setModalState(() {
                        _sortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Maior Estoque Primeiro',
                    isSelected: _sortOrder == 'desc',
                    onTap: () {
                      setModalState(() {
                        _sortOrder = 'desc';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botão aplicar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _updateSortCount();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar Ordenação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _filterControlled = null;
                            _filterStockAlert = null;
                            _filterGroup = null;
                            _filterNoGroup = false;
                          });
                          setState(() {
                            _filterControlled = null;
                            _filterStockAlert = null;
                            _filterGroup = null;
                            _filterNoGroup = false;
                            _updateFilterCount();
                          });
                        },
                        child: const Text(
                          'Limpar tudo',
                          style: TextStyle(color: AppColors.bluePrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  
                  // Conteúdo rolável
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          
                          // Filtro de Produto Controlado
                          const Text(
                            'Tipo de Produto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Opções de filtro
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Todos',
                    isSelected: _filterControlled == null,
                    onTap: () {
                      setModalState(() {
                        _filterControlled = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Controlado',
                    isSelected: _filterControlled == true,
                    onTap: () {
                      setModalState(() {
                        _filterControlled = true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Não Controlado',
                    isSelected: _filterControlled == false,
                    onTap: () {
                      setModalState(() {
                        _filterControlled = false;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Filtro de Alerta de Estoque
                  const Text(
                    'Nível de Estoque',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Todos',
                    isSelected: _filterStockAlert == null,
                    onTap: () {
                      setModalState(() {
                        _filterStockAlert = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Estoque OK',
                    isSelected: _filterStockAlert == 'ok',
                    onTap: () {
                      setModalState(() {
                        _filterStockAlert = 'ok';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Estoque Baixo',
                    isSelected: _filterStockAlert == 'low',
                    onTap: () {
                      setModalState(() {
                        _filterStockAlert = 'low';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Filtro de Grupo
                  const Text(
                    'Grupo de Mercadoria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Todos',
                    isSelected: _filterGroup == null && !_filterNoGroup,
                    onTap: () {
                      setModalState(() {
                        _filterGroup = null;
                        _filterNoGroup = false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Sem Grupo',
                    isSelected: _filterNoGroup,
                    onTap: () {
                      setModalState(() {
                        _filterGroup = null;
                        _filterNoGroup = true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Expediente',
                    isSelected: _filterGroup == MerchandiseGroup.expediente,
                    onTap: () {
                      setModalState(() {
                        _filterGroup = MerchandiseGroup.expediente;
                        _filterNoGroup = false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Limpeza',
                    isSelected: _filterGroup == MerchandiseGroup.limpeza,
                    onTap: () {
                      setModalState(() {
                        _filterGroup = MerchandiseGroup.limpeza;
                        _filterNoGroup = false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Almox Virtual',
                    isSelected: _filterGroup == MerchandiseGroup.almoxVirtual,
                    onTap: () {
                      setModalState(() {
                        _filterGroup = MerchandiseGroup.almoxVirtual;
                        _filterNoGroup = false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption(
                    context,
                    setModalState,
                    label: 'Permanente',
                    isSelected: _filterGroup == MerchandiseGroup.permanente,
                    onTap: () {
                      setModalState(() {
                        _filterGroup = MerchandiseGroup.permanente;
                        _filterNoGroup = false;
                      });
                    },
                  ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Botão aplicar (fixo na parte inferior)
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _updateFilterCount();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar Filtros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    StateSetter setModalState, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.bluePrimary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.bluePrimary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.bluePrimary : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.bluePrimary,
                size: 20,
              ),
          ],
        ),
      ),
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
            sizeHeader: 450,
            trailingAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão de Ordenação
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: _showSortModal,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.sort,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    if (_activeSortCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '$_activeSortCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Botão de Filtro
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    if (_activeFiltersCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '$_activeFiltersCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
    final result = await EditMerchandiseTypeModal.show(context, merchandise);
    if (result == true && mounted) {
      // Recarregar a lista após edição bem-sucedida
      _loadMerchandiseTypes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mercadoria atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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