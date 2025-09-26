import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBackgroundColor;
  final Color iconColor;
  final bool showArrow;
  final Function? onDelete;

  const CustomCard({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackgroundColor = AppColors.bluePrimary,
    this.iconColor = AppColors.white,
    this.showArrow = true,
    this.onDelete,
  });

  void _showOptionsMenu(BuildContext context, RenderBox renderBox, Size size) {
    final theme = Theme.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    
    // Considerando as margens do card (16.0 horizontal)
    final cardMargin = 16.0;
    final cardWidth = size.width - (cardMargin * 2);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + cardMargin,
        position.dy + size.height,
        MediaQuery.of(context).size.width - position.dx - size.width + cardMargin,
        0,
      ),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white, // Mesma cor do card
      constraints: BoxConstraints(
        minWidth: cardWidth,
        maxWidth: cardWidth,
      ),
      items: [
        PopupMenuItem(
          height: 60, // Aumentando altura para mais padding
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0), // Padding maior
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 24),
              const SizedBox(width: 16),
              Text(
                'Excluir',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(seconds: 0),
              () => _showDeleteConfirmationMenu(context),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmationMenu(BuildContext context) {
    final theme = Theme.of(context);
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // Considerando as margens do card (16.0 horizontal)
    final cardMargin = 16.0;
    final cardWidth = size.width - (cardMargin * 2);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + cardMargin,
        position.dy + size.height,
        MediaQuery.of(context).size.width - position.dx - size.width + cardMargin,
        0,
      ),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: theme.cardColor,
      constraints: BoxConstraints(
        minWidth: cardWidth,
        maxWidth: cardWidth,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Excluir $title?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        PopupMenuItem(
          enabled: false,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Tem certeza que deseja excluir este item?',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 1,
          child: Divider(),
        ),
        PopupMenuItem(
          height: 50,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.cancel, color: theme.colorScheme.primary),
            title: Text(
              'Cancelar',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          height: 50,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Excluir',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          onTap: () {
            if (onDelete != null) {
              onDelete!();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        
        _showOptionsMenu(context, renderBox, size);
      },
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Círculo do Ícone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, size: 45, color: iconColor),
            ),
            const SizedBox(width: 16),
            // Coluna com Título e Subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: AppColors.gray),
                  ),
                ],
              ),
            ),
            // Ícone de seta (condicional)
            if (showArrow)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.black,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}