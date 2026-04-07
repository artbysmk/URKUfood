import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendBridgeException implements Exception {
  const BackendBridgeException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class BackendBridge {
  BackendBridge._();

  static final BackendBridge instance = BackendBridge._();
  static const _tokenKey = 'urku_token';
  static const _userKey = 'urku_user';
  static const _rememberSessionKey = 'urku_remember_session';
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  SharedPreferences? _prefs;
  String? _token;
  Map<String, dynamic>? _cachedUser;
  bool _rememberSession = true;

  String? get token => _token;
  bool get hasSession => (_token ?? '').isNotEmpty;
  bool get rememberSession => _rememberSession;
  Map<String, dynamic>? get cachedUser =>
      _cachedUser == null ? null : Map<String, dynamic>.from(_cachedUser!);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _rememberSession = true;
    await _prefs?.setBool(_rememberSessionKey, true);
    _token = _prefs?.getString(_tokenKey);
    final rawUser = _prefs?.getString(_userKey);

    if (rawUser == null || rawUser.isEmpty) {
      return;
    }

    try {
      _cachedUser = jsonDecode(rawUser) as Map<String, dynamic>;
    } catch (_) {
      _cachedUser = null;
    }
  }

  Future<void> clearSession() async {
    _token = null;
    _cachedUser = null;
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userKey);
  }

  Future<void> setRememberSession(bool value) async {
    _rememberSession = true;
    await _prefs?.setBool(_rememberSessionKey, true);

    if ((_token ?? '').isNotEmpty) {
      await _prefs?.setString(_tokenKey, _token!);
    }
    if (_cachedUser != null) {
      await _prefs?.setString(_userKey, jsonEncode(_cachedUser));
    }
  }

  Future<void> updateCachedUser(Map<String, dynamic> user) async {
    await _storeUser(user);
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    print('[Auth] GET $_baseUrl/auth/me');
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode, response.body);
    }

    final user = jsonDecode(response.body) as Map<String, dynamic>;
    await _storeUser(user);
    return cachedUser ?? user;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('[Auth] POST $_baseUrl/auth/login -> $email');
    final response = await _post(
      '/auth/login',
      body: {'email': email, 'password': password},
      authorized: false,
    );
    await _storeToken(response['accessToken'] as String?);
    final user = response['user'];
    if (user is Map<String, dynamic>) {
      await _storeUser(user);
      response['user'] = cachedUser ?? user;
    }
    return response;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    print('[Auth] POST $_baseUrl/auth/register -> $email');
    final response = await _post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      },
      authorized: false,
    );
    await _storeToken(response['accessToken'] as String?);
    final user = response['user'];
    if (user is Map<String, dynamic>) {
      await _storeUser(user);
      response['user'] = cachedUser ?? user;
    }
    return response;
  }

  Future<List<dynamic>> fetchMyOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/my'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded;
    }

    return <dynamic>[];
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final result = await _post('/orders', body: payload);
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createComment({
    required String restaurantId,
    required String message,
  }) async {
    final result = await _post(
      '/comments',
      body: {'restaurantId': restaurantId, 'message': message},
    );
    return result as Map<String, dynamic>;
  }

  Future<List<dynamic>> sendChatMessage({
    required String restaurantId,
    required String restaurantName,
    required String message,
  }) async {
    final response = await _post(
      '/chat/messages',
      body: {
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'message': message,
      },
    );
    if (response is List<dynamic>) {
      return response;
    }
    return <dynamic>[];
  }

  Future<String?> uploadPaymentProof({
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/uploads/payment-proof'),
    );

    if ((_token ?? '').isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw _buildException(streamed.statusCode, body);
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return decoded['path'] as String?;
  }

  Future<dynamic> _post(
    String path, {
    required Map<String, dynamic> body,
    bool authorized = true,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(authorized: authorized),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode, response.body);
    }

    return jsonDecode(response.body);
  }

  Map<String, String> _headers({bool authorized = true}) {
    return {
      'Content-Type': 'application/json',
      if (authorized && (_token ?? '').isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  Future<void> _storeToken(String? token) async {
    if (token == null || token.isEmpty) {
      return;
    }
    _token = token;
    await _prefs?.setString(_tokenKey, token);
  }

  Future<void> _storeUser(Map<String, dynamic> user) async {
    _cachedUser = {
      ...?_cachedUser,
      ...Map<String, dynamic>.from(user),
    };
    await _prefs?.setString(_userKey, jsonEncode(_cachedUser));
  }

  BackendBridgeException _buildException(int statusCode, String rawBody) {
    return BackendBridgeException(
      _extractErrorMessage(rawBody),
      statusCode: statusCode,
    );
  }

  String _extractErrorMessage(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
        if (message is List && message.isNotEmpty) {
          return message.map((entry) => entry.toString()).join('\n');
        }
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error.trim();
        }
      }
    } catch (_) {}

    return rawBody.trim().isEmpty
        ? 'Error de comunicación con el backend'
        : rawBody;
  }
}