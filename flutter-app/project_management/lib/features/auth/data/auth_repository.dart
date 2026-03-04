import 'package:dio/dio.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  Future<String> login(String email, String password) async {
    final response = await dio.post(
      "/auth/login",
      data: {"email": email, "password": password},
    );

    return response.data["access_token"];
  }
}
