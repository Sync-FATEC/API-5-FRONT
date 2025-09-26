// lib/ui/views/forgot_password/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/forgot_password_viewmodel.dart';
import 'widgets/forgot_password_form.dart';
import '../../widgets/background_header.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordViewModel(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              // Widget 1: O Header Azul
              Header(
                title: "RECUPERAR SENHA",
                showBackButton: true,
                onBackPressed: () => Navigator.of(context).pop(),
              ),

              // Widget 2: O Card de Forgot Password
              const ForgotPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }
}