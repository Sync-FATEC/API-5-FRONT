// lib/ui/widgets/change_password_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../viewmodels/change_password_viewmodel.dart';
import 'custom_modal.dart';

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({Key? key}) : super(key: key);

  static Future<bool?> show(BuildContext context) {
    return CustomModal.show<bool>(
      context: context,
      title: 'Alterar Senha',
      width: MediaQuery.of(context).size.width * 0.9,
      child: ChangeNotifierProvider(
        create: (context) => ChangePasswordViewModel(context),
        child: const ChangePasswordModal(),
      ),
    );
  }

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangePasswordViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo Senha Atual
              CustomModalTextField(
                label: 'Senha Atual',
                controller: _currentPasswordController,
                obscureText: !viewModel.isCurrentPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.isCurrentPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: viewModel.toggleCurrentPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite sua senha atual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Nova Senha
              CustomModalTextField(
                label: 'Nova Senha',
                controller: _newPasswordController,
                obscureText: !viewModel.isNewPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.isNewPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: viewModel.toggleNewPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a nova senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Confirmar Nova Senha
              CustomModalTextField(
                label: 'Confirmar Nova Senha',
                controller: _confirmPasswordController,
                obscureText: !viewModel.isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: viewModel.toggleConfirmPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme a nova senha';
                  }
                  if (value != _newPasswordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Mensagem de erro
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop(false);
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomModalButton(
                      text: 'Alterar Senha',
                      backgroundColor: AppColors.bluePrimary,
                      isLoading: viewModel.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await viewModel.changePassword(
                            currentPassword: _currentPasswordController.text,
                            newPassword: _newPasswordController.text,
                          );

                          if (success && context.mounted) {
                            // Mostrar mensagem de sucesso
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Senha alterada com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
