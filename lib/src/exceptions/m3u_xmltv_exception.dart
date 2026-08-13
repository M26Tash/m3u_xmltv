/// Base exception thrown by the `m3u_xmltv` package.
///
/// Contains a human-readable [message] and can optionally preserve the
/// original [error] and [stackTrace] that caused the exception.
class M3uXmltvException implements Exception {
  /// A description of the error.
  final String message;

  /// The original error that caused this exception, if available.
  final Object? error;

  /// The stack trace associated with the original error, if available.
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
