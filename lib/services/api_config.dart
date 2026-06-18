class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'SIRATI_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(
        '${baseUrl.replaceAll(RegExp(r'/$'), '')}/$normalizedPath');
  }
}
