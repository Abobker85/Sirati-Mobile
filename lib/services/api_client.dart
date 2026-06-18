import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const _timeout = Duration(seconds: 45);

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _send(() {
      return _httpClient.get(
        ApiConfig.uri(path),
        headers: const {'Accept': 'application/json'},
      );
    });

    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _send(() {
      return _httpClient.post(
        ApiConfig.uri(path),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    });

    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    http.MultipartFile? file,
  }) async {
    final response = await _send(() async {
      final request = http.MultipartRequest('POST', ApiConfig.uri(path))
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(fields);

      if (file != null) {
        request.files.add(file);
      }

      final streamedResponse =
          await _httpClient.send(request).timeout(_timeout);
      return http.Response.fromStream(streamedResponse);
    });

    return _decodeObject(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw _exceptionFromResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.');
    } on http.ClientException {
      throw const ApiException(
          'تعذر الاتصال بالخادم. تأكد من تشغيل Laravel وصحة رابط API.');
    } catch (_) {
      throw const ApiException('حدث خطأ غير متوقع أثناء الاتصال بالخادم.');
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const ApiException('استجابة الخادم غير متوقعة.');
  }

  ApiException _exceptionFromResponse(http.Response response) {
    try {
      final decoded = _decodeObject(response);
      final message =
          decoded['message']?.toString() ?? 'فشل الطلب. حاول مرة أخرى.';
      final rawErrors = decoded['errors'];
      final errors = <String, List<String>>{};

      if (rawErrors is Map<String, dynamic>) {
        rawErrors.forEach((key, value) {
          if (value is List) {
            errors[key] = value.map((item) => item.toString()).toList();
          } else if (value != null) {
            errors[key] = [value.toString()];
          }
        });
      }

      return ApiException(message,
          statusCode: response.statusCode, errors: errors);
    } catch (_) {
      return ApiException(
        'فشل الطلب برمز ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
  }
}
