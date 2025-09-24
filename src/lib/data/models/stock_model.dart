class StockModel {
  final String id;
  final String name;
  final String location;
  final bool active;

  StockModel({
    required this.id,
    required this.name,
    required this.location,
    required this.active,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'location': location, 'active': active};
  }
}