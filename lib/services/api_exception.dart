class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.errors = const {},
  });

  String get displayMessage {
    if (errors.isEmpty) return message;

    final firstMessages = errors.values.where((items) => items.isNotEmpty);
    if (firstMessages.isEmpty) return message;

    return firstMessages.first.first;
  }

  @override
  String toString() => displayMessage;
}
