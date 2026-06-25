import '../app_locale.dart';
import 'api_client.dart';
import 'auth_token_store.dart';

class MobileContentService {
  MobileContentService({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(tokenProvider: const AuthTokenStore().readToken);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> dashboard(bool english) async {
    final response =
        await _apiClient.getJson('/mobile/dashboard?lang=${_lang(english)}');
    return _data(response);
  }

  Future<Map<String, dynamic>> myCvs(bool english) async {
    final response =
        await _apiClient.getJson('/mobile/my-cvs?lang=${_lang(english)}');
    return _data(response);
  }

  Future<Map<String, dynamic>> education(bool english,
      {String type = 'study'}) async {
    final response = await _apiClient
        .getJson('/mobile/education?lang=${_lang(english)}&type=$type');
    return _data(response);
  }

  Future<Map<String, dynamic>> educationContent(int id, bool english) async {
    final response = await _apiClient
        .getJson('/mobile/education/$id?lang=${_lang(english)}');
    return _data(response);
  }

  Future<Map<String, dynamic>> jobNews(bool english) async {
    final response =
        await _apiClient.getJson('/mobile/job-news?lang=${_lang(english)}');
    return _data(response);
  }

  Future<Map<String, dynamic>> jobNewsItem(int id, bool english) async {
    final response =
        await _apiClient.getJson('/mobile/job-news/$id?lang=${_lang(english)}');
    return _data(response);
  }

  Future<Map<String, dynamic>> notifications() async {
    final response = await _apiClient.getJson('/mobile/notifications');
    return _data(response);
  }

  Future<Map<String, dynamic>> markNotificationRead(int id) async {
    final response =
        await _apiClient.postJson('/mobile/notifications/$id/read', const {});
    return _data(response);
  }

  Future<void> markAllNotificationsRead() async {
    await _apiClient.postJson('/mobile/notifications/read-all', const {});
  }

  String _lang(bool english) => english ? 'en' : 'ar';

  Map<String, dynamic> _data(Map<String, dynamic> response) {
    final data = response['data'];
    return data is Map<String, dynamic> ? data : const {};
  }
}

bool mobileContentEnglishFromContext(context) => AppLocale.isEnglish(context);
