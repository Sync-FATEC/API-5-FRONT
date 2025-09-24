import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/merchandise_model.dart';
import '../../data/models/merchandise_type_model.dart';

class MerchandiseService {
  final String baseUrl;

  MerchandiseService({required this.baseUrl});

  Future<List<MerchandiseModel>> fetchMerchandiseList() async {
    final response = await http.get(Uri.parse('$baseUrl/merchandise'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => MerchandiseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load merchandise');
    }
  }

  Future<MerchandiseModel> fetchMerchandiseById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/merchandise/$id'));
    if (response.statusCode == 200) {
      return MerchandiseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load merchandise');
    }
  }

  Future<void> createMerchandise(MerchandiseModel merchandise) async {
    final response = await http.post(
      Uri.parse('$baseUrl/merchandise'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(merchandise.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create merchandise');
    }
  }

  Future<void> updateMerchandise(MerchandiseModel merchandise) async {
    final response = await http.put(
      Uri.parse('$baseUrl/merchandise/${merchandise.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(merchandise.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update merchandise');
    }
  }

  // Métodos para MerchandiseTypeModel
  Future<List<MerchandiseTypeModel>> fetchMerchandiseTypeList() async {
    final response = await http.get(Uri.parse('$baseUrl/merchandise-types'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => MerchandiseTypeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load merchandise types');
    }
  }

  Future<MerchandiseTypeModel> fetchMerchandiseTypeById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/merchandise-types/$id'));
    if (response.statusCode == 200) {
      return MerchandiseTypeModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load merchandise type');
    }
  }

  Future<void> createMerchandiseType(MerchandiseTypeModel type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/merchandise-types'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(type.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create merchandise type');
    }
  }

  Future<void> updateMerchandiseType(MerchandiseTypeModel type) async {
    final response = await http.put(
      Uri.parse('$baseUrl/merchandise-types/${type.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(type.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update merchandise type');
    }
  }
}
