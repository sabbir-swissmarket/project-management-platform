import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:project_management/core/network/base_url.dart';

class ApiClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiClient({String? overrideBaseUrl}) {
    _dio.options.baseUrl = resolveBaseUrl(overrideBaseUrl: overrideBaseUrl);
  }

  Future<void> attachToken() async {
    final token = await _storage.read(key: "access_token");
    if (token != null) {
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
  }

  Dio get client => _dio;
}
