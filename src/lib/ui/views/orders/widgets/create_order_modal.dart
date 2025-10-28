// lib/ui/views/orders/widgets/create_order_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/providers/section_provider.dart';
import '../../../../core/providers/stock_provider.dart';
import '../../../../core/providers/merchandise_type_provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../data/models/section_model.dart';
import '../../../../data/models/merchandise_type_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../widgets/custom_modal.dart';
import '../../../../core/constants/app_colors.dart';

class CreateOrderModal extends StatefulWidget {
  final Order? orderToEdit;
  
  const CreateOrderModal({Key? key, this.orderToEdit}) : super(key: key);

  @override
  State<CreateOrderModal> createState() => _CreateOrderModalState();

  static Future<bool?> show(BuildContext context, {Order? orderToEdit}) {
    return CustomModal.show<bool>(
      context: context,
      title: orderToEdit != null ? 'Editar pedido' : 'Cadastro pedido',
      child: _CreateOrderForm(orderToEdit: orderToEdit),
    );
  }
}

class _CreateOrderModalState extends State<CreateOrderModal> {
  @override
  Widget build(BuildContext context) {
    return Container(); // Este widget não será mais usado diretamente
  }
}

class _CreateOrderForm extends StatefulWidget {
  final Order? orderToEdit;
  
  const _CreateOrderForm({Key? key, this.orderToEdit}) : super(key: key);

  @override
  _CreateOrderFormState createState() => _CreateOrderFormState();
}

class _CreateOrderFormState extends State<_CreateOrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _withdrawalDateController = TextEditingController();
  final _quantityController = TextEditingController();
  
  bool _isLoading = false;
  SectionModel? _selectedSection;
  MerchandiseTypeModel? _selectedMerchandise;
  DateTime? _selectedWithdrawalDate;
  List<OrderItemData> _orderItems = [];

  @override
  void initState() {
    super.initState();
    // Carregar seções e tipos de mercadoria
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
      final merchandiseProvider = Provider.of<MerchandiseTypeProvider>(context, listen: false);
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final selectedStock = stockProvider.selectedStock;
      
      print('🔄 [CREATE_ORDER_MODAL] Iniciando carregamento de seções e produtos...');
      
      await sectionProvider.loadSections();
      
      if (selectedStock != null) {
        print("Carregando tipos de mercadoria para o stock: ${selectedStock.id}");
        await merchandiseProvider.loadMerchandiseTypes(stockId: selectedStock.id);
      } else {
        print("Nenhum stock selecionado, carregando todos os tipos de mercadoria");
        await merchandiseProvider.loadMerchandiseTypes();
      }
      
      print('📦 [CREATE_ORDER_MODAL] Produtos carregados: ${merchandiseProvider.merchandiseTypes.length}');
      for (var product in merchandiseProvider.merchandiseTypes) {
        print('   - Produto: ${product.name} (ID: ${product.id})');
      }
      
      // Se estamos editando um pedido, carregar os dados após carregar seções
      if (widget.orderToEdit != null) {
        _loadOrderData();
      }
    });
  }

  void _loadOrderData() {
    final order = widget.orderToEdit!;
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
    
    print('🔄 [LOAD_ORDER_DATA] Carregando dados do pedido: ${order.id}');
    print('📍 [LOAD_ORDER_DATA] Seção do pedido: ${order.sectionId}');
    print('📋 [LOAD_ORDER_DATA] Seções disponíveis: ${sectionProvider.sections.length}');
    
    // Encontrar e definir a seção
    try {
      _selectedSection = sectionProvider.sections.firstWhere(
        (section) => section.id == order.sectionId,
      );
      print('✅ [LOAD_ORDER_DATA] Seção encontrada: ${_selectedSection?.name}');
    } catch (e) {
      print('⚠️ [LOAD_ORDER_DATA] Seção não encontrada, usando primeira disponível');
      if (sectionProvider.sections.isNotEmpty) {
        _selectedSection = sectionProvider.sections.first;
      }
    }
    
    // Definir data de retirada se existir
    if (order.withdrawalDate != null) {
      try {
        _selectedWithdrawalDate = DateTime.parse(order.withdrawalDate!);
        _withdrawalDateController.text = DateFormat('dd/MM/yyyy').format(_selectedWithdrawalDate!);
        print('📅 [LOAD_ORDER_DATA] Data de retirada carregada: ${_withdrawalDateController.text}');
      } catch (e) {
        print('❌ [LOAD_ORDER_DATA] Erro ao parsear data de retirada: $e');
      }
    }
    
    // Carregar itens do pedido
    _orderItems = order.orderItems.map((item) => OrderItemData(
      merchandiseId: item.merchandiseId,
      merchandiseName: item.merchandiseName,
      quantity: item.quantity,
    )).toList();
    
    print('📦 [LOAD_ORDER_DATA] Itens carregados: ${_orderItems.length}');
    for (var item in _orderItems) {
      print('   - ${item.merchandiseName}: ${item.quantity}');
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    _withdrawalDateController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectWithdrawalDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.bluePrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedWithdrawalDate = picked;
        _withdrawalDateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _addOrderItem() {
    if (_selectedMerchandise != null && _quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text);
      if (quantity != null && quantity > 0) {
        // Validar se a quantidade não excede o estoque disponível
        if (quantity > _selectedMerchandise!.quantityTotal) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quantidade não pode ser maior que ${_selectedMerchandise!.quantityTotal} unidades disponíveis'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // Verificar se já existe este produto na lista e somar as quantidades
        final existingItemIndex = _orderItems.indexWhere(
          (item) => item.merchandiseId == _selectedMerchandise!.id
        );
        
        if (existingItemIndex != -1) {
          final totalQuantity = _orderItems[existingItemIndex].quantity + quantity;
          if (totalQuantity > _selectedMerchandise!.quantityTotal) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quantidade total (${totalQuantity}) não pode ser maior que ${_selectedMerchandise!.quantityTotal} unidades disponíveis'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          // Atualizar quantidade do item existente
          setState(() {
            _orderItems[existingItemIndex] = OrderItemData(
              merchandiseId: _selectedMerchandise!.id!,
              merchandiseName: _selectedMerchandise!.name,
              quantity: totalQuantity,
            );
            _selectedMerchandise = null;
            _quantityController.clear();
          });
        } else {
          // Adicionar novo item
          setState(() {
            _orderItems.add(OrderItemData(
              merchandiseId: _selectedMerchandise!.id!,
              merchandiseName: _selectedMerchandise!.name,
              quantity: quantity,
            ));
            _selectedMerchandise = null;
            _quantityController.clear();
          });
        }
      }
    }
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  Future<void> _saveOrder(BuildContext context) async {
    
    if (_selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma seção'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione pelo menos um produto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      
      final selectedStock = stockProvider.selectedStock;
      if (selectedStock == null) {
        throw Exception('Nenhum estoque selecionado');
      }

      final orderData = {
        'creationDate': widget.orderToEdit?.creationDate ?? DateTime.now().toIso8601String(),
        'withdrawalDate': _selectedWithdrawalDate?.toIso8601String(),
        'status': widget.orderToEdit?.status ?? 'PENDING',
        'sectionId': _selectedSection!.id,
        'stockId': selectedStock.id,
        'orderItems': _orderItems.map((item) => {
          'quantity': item.quantity,
          'merchandiseId': item.merchandiseId,
        }).toList(),
      };

      bool success;
      String successMessage;
      
      if (widget.orderToEdit != null) {
        // Editando pedido existente
        final stockProvider = Provider.of<StockProvider>(context, listen: false);
        final selectedStock = stockProvider.selectedStock;
        success = await orderProvider.updateOrder(
          widget.orderToEdit!.id, 
          orderData, 
          stockId: selectedStock?.id
        );
        successMessage = 'Pedido atualizado com sucesso!';
      } else {
        // Criando novo pedido
        success = await orderProvider.createOrder(orderData);
        successMessage = 'Pedido criado com sucesso!';
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(orderProvider.errorMessage ?? 'Erro ao salvar pedido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar pedido: $e'),
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown de Seção
          Consumer<SectionProvider>(
            builder: (context, sectionProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seção:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SectionModel>(
                          value: _selectedSection,
                          isExpanded: true,
                          hint: const Text('Selecione uma seção'),
                          menuMaxHeight: 300,
                          items: sectionProvider.sections.map((section) {
                            return DropdownMenuItem<SectionModel>(
                              value: section,
                              child: Text(section.name),
                            );
                          }).toList(),
                          onChanged: (SectionModel? newValue) {
                            setState(() {
                              _selectedSection = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Data do pedido (automática - apenas exibição)
            CustomModalTextField(
              label: 'Data do pedido:',
              controller: TextEditingController(
                text: "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}"
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            
            // Data de retirada
            GestureDetector(
              onTap: _selectWithdrawalDate,
              child: AbsorbPointer(
                child: CustomModalTextField(
                  label: 'Data de retirada:',
                  controller: _withdrawalDateController,
                  suffixIcon: const Icon(Icons.calendar_today, color: AppColors.bluePrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Seção de Produtos
            const Text(
              'Produtos:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Dropdown de Produtos
            Consumer2<MerchandiseTypeProvider, UserProvider>(
              builder: (context, merchandiseProvider, userProvider, child) {
                print('🛒 [CREATE_ORDER_MODAL] Renderizando dropdown de produtos...');
                print('📋 [CREATE_ORDER_MODAL] Total de produtos disponíveis: ${merchandiseProvider.merchandiseTypes.length}');
                print('🔄 [CREATE_ORDER_MODAL] Estado de carregamento: ${merchandiseProvider.isLoading}');
                print('👤 [CREATE_ORDER_MODAL] Papel do usuário: ${userProvider.userRole}');
                print('🔐 [CREATE_ORDER_MODAL] É admin/supervisor: ${userProvider.isAdmin || userProvider.userRole == 'SUPERVISOR'}');
                
                // Filtrar produtos baseado no papel do usuário
                final isAuthorizedUser = userProvider.isAdmin || userProvider.userRole == 'SUPERVISOR';
                final filteredProducts = merchandiseProvider.merchandiseTypes.where((product) {
                  // Se o produto não é controlado, sempre mostrar
                  if (!product.controlled) return true;
                  // Se o produto é controlado, só mostrar para admin/supervisor
                  return isAuthorizedUser;
                }).toList();
                
                // Verificar se o produto selecionado ainda está disponível após o filtro
                if (_selectedMerchandise != null && !filteredProducts.contains(_selectedMerchandise)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedMerchandise = null;
                    });
                  });
                }
                
                print('📦 [CREATE_ORDER_MODAL] Produtos após filtro: ${filteredProducts.length}');
                if (filteredProducts.isNotEmpty) {
                  print('📋 [CREATE_ORDER_MODAL] Lista de produtos filtrados:');
                  for (var product in filteredProducts) {
                    print('  - ${product.name} (Controlado: ${product.controlled})');
                  }
                } else {
                  print('⚠️ [CREATE_ORDER_MODAL] Nenhum produto encontrado após filtro');
                }
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MerchandiseTypeModel>(
                      value: _selectedMerchandise,
                      isExpanded: true,
                      hint: const Text('Selecione um produto'),
                      menuMaxHeight: 300,
                      items: filteredProducts.map((merchandise) {
                        return DropdownMenuItem<MerchandiseTypeModel>(
                          value: merchandise,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        merchandise.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    if (merchandise.controlled)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.orange.shade300),
                                        ),
                                        child: Text(
                                          'CONTROLADO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Disponível: ${merchandise.quantityTotal} ${merchandise.unitOfMeasure}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: merchandise.quantityTotal <= merchandise.minimumStock 
                                      ? Colors.orange 
                                      : Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (MerchandiseTypeModel? newValue) {
                        setState(() {
                          _selectedMerchandise = newValue;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Lista de produtos adicionados
            if (_orderItems.isNotEmpty) ...[
              const Text(
                'Produtos adicionados:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _orderItems.length,
                  itemBuilder: (context, index) {
                    final item = _orderItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.merchandiseName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Quantidade: ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeOrderItem(index),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Campo de quantidade e botão adicionar
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomModalTextField(
                        label: _selectedMerchandise != null 
                          ? 'Quantidade (Disponível: ${_selectedMerchandise!.quantityTotal}):'
                          : 'Quantidade:',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira a quantidade';
                          }
                          
                          final quantity = int.tryParse(value.trim());
                          if (quantity == null || quantity <= 0) {
                            return 'Por favor, insira um número válido maior que 0';
                          }
                          
                          if (_selectedMerchandise != null && quantity > _selectedMerchandise!.quantityTotal) {
                            return 'Quantidade não pode ser maior que ${_selectedMerchandise!.quantityTotal}';
                          }
                          
                          return null;
                        },
                      ),
                      if (_selectedMerchandise != null && _selectedMerchandise!.quantityTotal <= _selectedMerchandise!.minimumStock)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '⚠️ Estoque baixo (${_selectedMerchandise!.quantityTotal} unidades)',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 56,
                  child: ElevatedButton(
                    onPressed: _selectedMerchandise != null && _selectedMerchandise!.quantityTotal > 0 
                      ? _addOrderItem 
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Botão de salvar
            CustomModalButton(
              text: widget.orderToEdit != null ? 'ATUALIZAR' : 'CADASTRAR',
              onPressed: () => _saveOrder(context),
              isLoading: _isLoading,
            ),
          ],
        ),
    );
  }
}

// Classe auxiliar para armazenar dados dos itens do pedido
class OrderItemData {
  final String merchandiseId;
  final String merchandiseName;
  final int quantity;

  OrderItemData({
    required this.merchandiseId,
    required this.merchandiseName,
    required this.quantity,
  });
}