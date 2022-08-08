import 'dart:developer';

import 'package:http/http.dart' as http;

import 'dart:convert';

class BaseApi {
  static const url = "https://api.tear.one";

  String? _accessToken;
  String? _refreshToken;

  late Function(String, String)? refreshCallback;

  void setAuth(String? accessToken, String? refreshToken) {
    log("Tokens: $accessToken, $refreshToken");
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<String> getToken() async {
    if (_accessToken == null) return "";

    final claims = Jwt.parseJwt(_accessToken!);

    // Jwt expired, generate new one
    if (claims["iat"] + 600 <= (DateTime.now().millisecondsSinceEpoch / 1000).floor()) {
      log("Refreshing token...");
      final res = await http.get(Uri.parse("$url/auth/refresh?refresh_token=${Uri.encodeComponent(_refreshToken!)}"));

      if (res.statusCode != 200) {
        log("Failed to refresh token (${res.statusCode})");
        _accessToken = null;
        _refreshToken = null;
        return "";
      }

      log("Token refreshed");

      final token = jsonDecode(res.body);
      _accessToken = token["access_token"];
      _refreshToken = token["refresh_token"];

      refreshCallback != null ? refreshCallback!(_accessToken ?? "", _refreshToken ?? "") : null;
    }

    return _accessToken!;
  }
}

class Jwt {
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token.');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw const FormatException('Invalid payload.');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += "==";
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64 string.');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
