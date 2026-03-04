import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioProvider {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:8000",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint("API ERROR: ${error.message}");
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
