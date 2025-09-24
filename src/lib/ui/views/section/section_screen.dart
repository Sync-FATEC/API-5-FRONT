import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/views/section/create_section_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/section_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background_header.dart';

class SectionScreen extends StatefulWidget {
  const SectionScreen({super.key});

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  @override
  void initState() {
    super.initState();
    // Garante que o provider seja chamado após o build da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSections();
    });
  }

  void _loadSections() {
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
    sectionProvider.loadSections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camada de baixo: O Header
          const Header(title: "LISTAGEM DE SEÇÕES"),

          // Camada de cima: A lista de cards
          Consumer<SectionProvider>(
            builder: (context, sectionProvider, child) {
              if (sectionProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.bluePrimary,
                  ),
                );
              }

              if (sectionProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erro ao carregar seções',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSections,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bluePrimary,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              final sections = sectionProvider.sections;

              if (sections.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma seção encontrada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              // Usando ListView.builder para melhor performance
              return Padding(
                padding: const EdgeInsets.only(top: 180.0),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CustomCard(
                        iconData: _getIconForSection(section.name),
                        title: section.name,
                        subtitle: 'Seção',
                        onTap: () {},
                        showArrow: false,
                        onDelete: () => _deleteSection(context, section.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      // Botão flutuante para criar seção
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateSection(context),
        backgroundColor: AppColors.bluePrimary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  IconData _getIconForSection(String sectionName) {
    // Usando um ícone genérico para todas as seções
    return Icons.category_outlined;
  }

  void _navigateToCreateSection(BuildContext context) async {
    final result = await CreateSectionModal.show(context);

    // Se a seção foi criada com sucesso, recarregar a lista
    if (result == true) {
      _loadSections();
    }
  }
  
  void _deleteSection(BuildContext context, String id) async {
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
    
    try {
      final success = await sectionProvider.deleteSection(id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seção excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sectionProvider.errorMessage ?? 'Erro ao excluir seção'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir seção: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}