// lib/ui/views/forgot_password/widgets/forgot_password_form.dart
import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset('assets/LOGO1.png', height: 60),
                    const Text(
                      "Recuperar\nSenha",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Image.asset('assets/LOGO2.png', height: 60),
                  ],
                ),
                const SizedBox(height: 30),

                const Text(
                  "Digite seu e-mail abaixo e enviaremos instruções para redefinir sua senha.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de e-mail
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Insira seu e-mail',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botões
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão Voltar
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Voltar ao Login',
                        style: TextStyle(
                          color: AppColors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    // Botão Enviar ou Loading
                    viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              final email = _emailController.text;
                              
                              final success = await viewModel.sendResetEmail(email);
                              
                              if (success && context.mounted) {
                                // Mostrar diálogo de sucesso
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('E-mail Enviado'),
                                    content: const Text(
                                      'Instruções para redefinir sua senha foram enviadas para seu e-mail.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Fecha o diálogo
                                          Navigator.of(context).pop(); // Volta para login
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.bluePrimary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 5, 
                                horizontal: 20
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Enviar',
                              style: TextStyle(
                                fontSize: 18, 
                                color: AppColors.white
                              ),
                            ),
                          ),
                  ],
                ),

                // Mostra a mensagem de erro, se houver
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: AppColors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}