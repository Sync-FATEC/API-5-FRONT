// lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/header.dart';
import 'widgets/login_form.dart';
import '../../viewmodels/login_viewmodel.dart';

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
              Header(),

              // Widget 2: O Card de Login
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}