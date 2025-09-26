class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String validUntil;
  final String createdAt;
  final bool isActive;

  const UserModel({
    required this.email, 
    required this.name, 
    required this.role, 
    required this.validUntil, 
    required this.createdAt, 
    required this.isActive, 
    required this.id
    });

  // Métodos getters
  String get getId => id;
  String get getEmail => email;
  String get getName => name;
  String get getRole => role;
  String get getValidUntil => validUntil;
  String get getCreatedAt => createdAt;
  bool get getIsActive => isActive;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      validUntil: json['validUntil'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'validUntil': validUntil,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}