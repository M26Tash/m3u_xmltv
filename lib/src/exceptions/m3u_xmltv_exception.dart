class M3uXmltvException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const M3uXmltvException(this.message, {this.error, this.stackTrace});

  @override
  String toString() {
    if (error != null) {
      return 'M3uXmltvException: $message (Caused by: $error)';
    }
    return 'M3uXmltvException: $message';
  }
}
