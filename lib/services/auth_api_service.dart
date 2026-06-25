import '../models/auth_session.dart';
import 'api_client.dart';
import 'auth_token_store.dart';

class AuthApiService {
  AuthApiService(
      {ApiClient? apiClient,
      AuthTokenStore tokenStore = const AuthTokenStore()})
      : _apiClient =
            apiClient ?? ApiClient(tokenProvider: tokenStore.readToken),
        _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  Future<AuthSession> login(
      {required String email, required String password}) async {
    final response = await _apiClient.postJson('/auth/login', {
      'email': email,
      'password': password,
      'device_name': 'sirati-mobile',
    });

    final session = AuthSession.fromJson(response);
    await _tokenStore.saveToken(session.token);
    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.postJson('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': 'sirati-mobile',
    });

    final session = AuthSession.fromJson(response);
    await _tokenStore.saveToken(session.token);
    return session;
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await _apiClient.postJson('/auth/forgot-password', {
      'email': email,
    });

    return response['message']?.toString() ??
        'تم إرسال رابط استعادة كلمة المرور إذا كان البريد مسجلاً لدينا.';
  }

  Future<void> logout() async {
    try {
      await _apiClient.postJson('/auth/logout', const {});
    } finally {
      await _tokenStore.clearToken();
    }
  }

  Future<AuthUser?> me() async {
    final response = await _apiClient.getJson('/auth/me');
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return AuthUser.fromJson(data);
  }
}
