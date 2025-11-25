import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/amiibo.dart';

class AmiiboApiService {
  static const String _baseUrl = 'https://www.amiiboapi.com/api';

  Future<List<Amiibo>> fetchAllAmiibos() async {
    final uri = Uri.parse('$_baseUrl/amiibo');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['amiibo'] as List<dynamic>;
      return list.map((e) => Amiibo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load amiibo data');
    }
  }

  /// Opsional: contoh penggunaan endpoint get by head
  Future<List<Amiibo>> fetchByHead(String head) async {
    final uri = Uri.parse('$_baseUrl/amiibo/?head=$head');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['amiibo'] as List<dynamic>;
      return list.map((e) => Amiibo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load amiibo by head');
    }
  }
}
