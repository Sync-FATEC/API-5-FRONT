// lib/ui/views/section/create_section_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/section_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_modal.dart';

class CreateSectionModal extends StatefulWidget {
  const CreateSectionModal({Key? key}) : super(key: key);

  @override
  State<CreateSectionModal> createState() => _CreateSectionModalState();

  static Future<bool?> show(BuildContext context) {
    return CustomModal.show<bool>(
      context: context,
      title: 'Cadastro de seção',
      child: const _CreateSectionForm(),
    );
  }
}

class _CreateSectionModalState extends State<CreateSectionModal> {
  @override
  Widget build(BuildContext context) {
    return Container(); // Este widget não será mais usado diretamente
  }
}

class _CreateSectionForm extends StatefulWidget {
  const _CreateSectionForm({Key? key}) : super(key: key);

  @override
  _CreateSectionFormState createState() => _CreateSectionFormState();
}

class _CreateSectionFormState extends State<_CreateSectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createSection(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
      
      await sectionProvider.createSection(_nameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seção criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar seção: $e'),
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
            text: 'CADASTRAR',
            onPressed: () => _createSection(context),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}