import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioProvider {
  /// Creates a preconfigured Dio instance.
  ///
  /// By default we connect to the local backend. On Android emulators
  /// "localhost" refers to the emulator itself, so we use 10.0.2.2 instead.
  static Dio createDio({String? overrideBaseUrl}) {
    final defaultBase = kIsWeb
        ? 'http://localhost:8000'
        : 'http://10.0.2.2:8000';
    final baseUrl = overrideBaseUrl ?? defaultBase;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // interceptor to attach authorization header dynamically before each request
    final storage = const FlutterSecureStorage();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await storage.read(key: 'token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint("API ERROR: ${error.message}");
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
