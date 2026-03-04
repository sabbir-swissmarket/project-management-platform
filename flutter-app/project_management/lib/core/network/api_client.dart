import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.options.baseUrl = "http://127.0.0.1:8000";
  }

  Future<void> attachToken() async {
    final token = await _storage.read(key: "access_token");
    if (token != null) {
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
  }

  Dio get client => _dio;
}
