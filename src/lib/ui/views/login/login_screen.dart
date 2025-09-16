// lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/login_form.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/background_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(context),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              // Widget 1: O Header Azul
              const Header(
                title: "APP",
                subtitle: "CONTROLE DE ESTOQUE",
              ),

              // Widget 2: O Card de Login
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
