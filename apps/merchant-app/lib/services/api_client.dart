import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // URL is injected at build time via --dart-define=API_URL=...
  // Defaults to production if not specified.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://bazz-production.up.railway.app/api',
  );

  bool _isRefreshing = false;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await StorageService.instance.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _parseMap(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, body['error'] as String? ?? 'Unknown error');
    }
    return body;
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if successful, false if the session should be cleared.
  Future<bool> _tryRefresh() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await StorageService.instance.getRefreshToken();
      if (refreshToken == null) return false;

      final res = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        await StorageService.instance.saveTokens(
          accessToken: body['accessToken'] as String,
          refreshToken: body['refreshToken'] as String,
          merchantId: await StorageService.instance.getMerchantId() ?? '',
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Executes [request], and if a 401 is returned, refreshes the token and retries once.
  Future<http.Response> _withRefresh(Future<http.Response> Function(Map<String, String> headers) request) async {
    final headers = await _headers();
    var res = await request(headers);

    if (res.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final newHeaders = await _headers();
        res = await request(newHeaders);
      } else {
        // Refresh failed — clear session so the app redirects to login
        await StorageService.instance.clearAll();
      }
    }
    return res;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _withRefresh(
      (h) => http.get(Uri.parse('$baseUrl$path'), headers: h),
    );
    return _parseMap(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    if (!auth) {
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(auth: false),
        body: jsonEncode(body),
      );
      return _parseMap(res);
    }
    final encoded = jsonEncode(body);
    final res = await _withRefresh(
      (h) => http.post(Uri.parse('$baseUrl$path'), headers: h, body: encoded),
    );
    return _parseMap(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final encoded = jsonEncode(body);
    final res = await _withRefresh(
      (h) => http.patch(Uri.parse('$baseUrl$path'), headers: h, body: encoded),
    );
    return _parseMap(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await _withRefresh(
      (h) => http.delete(Uri.parse('$baseUrl$path'), headers: h),
    );
    return _parseMap(res);
  }

  Future<List<dynamic>> getList(String path) async {
    final res = await _withRefresh(
      (h) => http.get(Uri.parse('$baseUrl$path'), headers: h),
    );
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(res.statusCode, body['error'] as String? ?? 'Unknown error');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }
}
