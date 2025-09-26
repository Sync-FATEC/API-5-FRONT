// lib/ui/views/section/edit_section_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/section_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_modal.dart';
import '../../../../data/models/section_model.dart';

class EditSectionModal extends StatefulWidget {
  final SectionModel section;
  
  const EditSectionModal({Key? key, required this.section}) : super(key: key);

  @override
  State<EditSectionModal> createState() => _EditSectionModalState();

  static Future<bool?> show(BuildContext context, SectionModel section) {
    return CustomModal.show<bool>(
      context: context,
      title: 'Editar seção',
      child: _EditSectionForm(section: section),
    );
  }
}

class _EditSectionModalState extends State<EditSectionModal> {
  @override
  Widget build(BuildContext context) {
    return Container(); // Este widget não será mais usado diretamente
  }
}

class _EditSectionForm extends StatefulWidget {
  final SectionModel section;
  
  const _EditSectionForm({Key? key, required this.section}) : super(key: key);

  @override
  _EditSectionFormState createState() => _EditSectionFormState();
}

class _EditSectionFormState extends State<_EditSectionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.section.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editSection(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
      
      await sectionProvider.updateSection(
        widget.section.id, 
        _nameController.text.trim()
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seção atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar seção: $e'),
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
        children: [
          CustomModalTextField(
            label: 'Nome da seção:',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome da seção';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomModalButton(
            text: 'ATUALIZAR',
            onPressed: () => _editSection(context),
            isLoading: _isLoading,
            backgroundColor: AppColors.bluePrimary,
          ),
        ],
      ),
    );
  }
}