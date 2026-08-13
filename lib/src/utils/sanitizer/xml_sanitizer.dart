import 'dart:async';

/// Repairs invalid ampersands in an XML stream.
///
/// XML only allows ampersands to start valid entity references:
///
///   &amp;
///   &lt;
///   &gt;
///   &quot;
///   &apos;
///   &#123;
///   &#x7B;
///
/// An invalid ampersand is replaced with `&amp;`.
///
/// The sanitizer keeps a possible entity reference between chunks,
/// so references split across stream chunks are handled correctly
class XmlSanitizer extends StreamTransformerBase<String, String> {
  const XmlSanitizer();

  @override
  Stream<String> bind(Stream<String> stream) async* {
    var pending = '';

    await for (final chunk in stream) {
      if (chunk.isEmpty) continue;

      final output = StringBuffer();
      var index = 0;

      while (index < chunk.length) {
        final char = chunk[index];

        if (pending.isEmpty) {
          if (char == '&') {
            pending = '&';
          } else {
            output.write(char);
          }

          index++;
          continue;
        }

        pending += char;
        index++;

        if (char == ';') {
          if (_isValidEntityReference(pending)) {
            output.write(pending);
          } else {
            output
              ..write('&amp;')
              ..write(
                pending.substring(1),
              );
          }

          pending = '';
          continue;
        }

        if (_isWhitespace(char)) {
          output
            ..write('&amp;')
            ..write(
              pending.substring(1),
            );

          pending = '';
          continue;
        }

        if (pending.length > 20) {
          output
            ..write('&amp;')
            ..write(pending.substring(1));

          pending = '';
        }
      }

      if (output.isNotEmpty) {
        yield output.toString();
      }
    }

    if (pending.isNotEmpty) {
      yield '&amp;${pending.substring(1)}';
    }
  }

  bool _isValidEntityReference(String value) {
    switch (value) {
      case '&amp;':
      case '&lt;':
      case '&gt;':
      case '&quot;':
      case '&apos;':
        return true;
    }

    if (value.startsWith('&#x') && value.endsWith(';')) {
      final content = value.substring(
        3,
        value.length - 1,
      );

      return content.isNotEmpty && RegExp(r'^[0-9a-fA-F]+$').hasMatch(content);
    }

    if (value.startsWith('&#') && value.endsWith(';')) {
      final content = value.substring(2, value.length - 1);

      return content.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(content);
    }

    return false;
  }

  bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }
}
