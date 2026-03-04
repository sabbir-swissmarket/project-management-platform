import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw Exception("Invalid token");
    }

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );

    return json.decode(payload);
  }

  static String getRole(String token) {
    final decoded = decode(token);
    return decoded["role"];
  }
}
