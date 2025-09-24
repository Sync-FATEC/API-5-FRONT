import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class CustomCard extends StatefulWidget {
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

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool _isPressed = false;

  // CORREÇÃO 1: MÉTODOS MOVIDOS PARA A CLASSE STATE
  void _showOptionsMenu(BuildContext context, RenderBox renderBox, Size size) {
    final theme = Theme.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    
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
      color: Colors.white,
      constraints: BoxConstraints(
        minWidth: cardWidth,
        maxWidth: cardWidth,
      ),
      items: [
        PopupMenuItem(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.delete_outline, color: Colors.red, size: 24),
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
      color: Colors.white,
      constraints: BoxConstraints(
        minWidth: cardWidth,
        maxWidth: cardWidth,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          // CORREÇÃO 2: Usar widget.title
          child: Text(
            'Excluir ${widget.title}?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        PopupMenuItem(
          enabled: false,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: Text(
            'Tem certeza que deseja excluir este item?',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
            ),
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 16,
          child: Divider(height: 1),
        ),
        PopupMenuItem(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.cancel, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 16),
              Text(
                'Cancelar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 24),
              const SizedBox(width: 16),
              Text(
                'Excluir',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: () {
            // CORREÇÃO 2: Usar widget.onDelete
            if (widget.onDelete != null) {
              widget.onDelete!();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.apiUserData?.role?.toUpperCase() ?? '';
    // CORREÇÃO 2: Usar widget.onDelete
    final bool canDelete = userRole != 'SOLDADO' && widget.onDelete != null;
    
    return GestureDetector(
      // CORREÇÃO 2: A chamada do método agora está correta, pois ele foi movido.
      onLongPress: canDelete ? () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        
        _showOptionsMenu(context, renderBox, size);
      } : null,
      // CORREÇÃO 2: Usar widget.onTap
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // CORREÇÃO 2: Usar widget.iconBackgroundColor
                color: widget.iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              // CORREÇÃO 2: Usar widget.iconData e widget.iconColor
              child: Icon(widget.iconData, size: 45, color: widget.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // CORREÇÃO 2: Usar widget.title
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // CORREÇÃO 2: Usar widget.subtitle
                    widget.subtitle,
                    style: TextStyle(fontSize: 14, color: AppColors.gray),
                  ),
                ],
              ),
            ),
            // CORREÇÃO 2: Usar widget.showArrow
            if (widget.showArrow)
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