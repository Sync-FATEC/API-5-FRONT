class User {
  final String email;
  final String password; // No futuro será necessário alterar para hash para segurança

  const User({
    required this.email,
    required this.password,
  });
}