// lib/ui/views/login/widgets/login_form.dart
import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/login_viewmodel.dart'; // Importe a ViewModel

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Crie os controladores para os campos de texto
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Lembre-se de limpar os controladores para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use um Consumer para ouvir as mudanças na ViewModel
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        // O `child` é opcional, usado para otimização
        // Todo o seu código de UI vai aqui dentro.
        // A UI será reconstruída sempre que `notifyListeners()` for chamado.
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
                       "Bem-vindo ao App de\ncontrole de estoque!",
                       textAlign: TextAlign.center,
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                     ),
                     Image.asset('assets/LOGO2.png', height: 60),
                   ],
                 ),
                 const SizedBox(height: 50),

                // Conecte o controlador ao TextField
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
                const SizedBox(height: 15),

                // Conecte o controlador ao TextField
                TextField(
                  controller: _passwordController,
                  obscureText: !viewModel.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Insira sua senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: viewModel.togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: const Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(
                        color: AppColors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                // Mostra um indicador de carregamento ou o botão
                Align(
                  alignment: Alignment.centerRight,
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator() // Mostra enquanto estiver carregando
                      : ElevatedButton(
                          onPressed: () async {
                            // Pega o texto dos controladores e chama a ViewModel
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            
                            final success = await viewModel.login(email, password);
                            
                            if (success && context.mounted) {
                              // Navegar para a tela de seleção de estoque
                              Navigator.of(context).pushReplacementNamed('/stock-selection');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bluePrimary,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 18, color: AppColors.white),
                          ),
                        ),
                ),

                // Mostra a mensagem de erro, se houver
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      viewModel.errorMessage!.replaceFirst('Exception: ', ''),
                      style: const TextStyle(color: AppColors.red),
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