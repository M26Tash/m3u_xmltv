import 'dart:async';

import 'package:m3u_xmltv/src/utils/sanitizer/xml_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('XmlSanitizer', () {
    Future<String> sanitize(
      List<String> chunks,
    ) async {
      final stream = Stream<String>.fromIterable(chunks).transform(
        const XmlSanitizer(),
      );

      return stream.join();
    }

    test('leaves normal text unchanged', () async {
      final result = await sanitize([
        '<title>Hello World</title>',
      ]);

      expect(
        result,
        '<title>Hello World</title>',
      );
    });

    test('repairs invalid ampersand', () async {
      final result = await sanitize([
        '<title>Tom & Jerry</title>',
      ]);

      expect(
        result,
        '<title>Tom &amp; Jerry</title>',
      );
    });

    test('preserves predefined XML entities', () async {
      final result = await sanitize([
        '&amp; &lt; &gt; &quot; &apos;',
      ]);

      expect(
        result,
        '&amp; &lt; &gt; &quot; &apos;',
      );
    });

    test('preserves decimal numeric entities', () async {
      final result = await sanitize([
        '&#38; &#123;',
      ]);

      expect(
        result,
        '&#38; &#123;',
      );
    });

    test('preserves hexadecimal numeric entities', () async {
      final result = await sanitize([
        '&#x26; &#x7B; &#x1F600;',
      ]);

      expect(
        result,
        '&#x26; &#x7B; &#x1F600;',
      );
    });

    test('repairs unknown named entity', () async {
      final result = await sanitize([
        'Tom &nbsp; Jerry',
      ]);

      expect(
        result,
        'Tom &amp;nbsp; Jerry',
      );
    });

    test('repairs malformed entity', () async {
      final result = await sanitize([
        'Tom &something; Jerry',
      ]);

      expect(
        result,
        'Tom &amp;something; Jerry',
      );
    });

    test('handles ampersand split across chunks', () async {
      final result = await sanitize([
        '<title>Tom &',
        ' Jerry</title>',
      ]);

      expect(
        result,
        '<title>Tom &amp; Jerry</title>',
      );
    });

    test('handles valid entity split across chunks', () async {
      final result = await sanitize([
        '<title>Tom &am',
        'p; Jerry</title>',
      ]);

      expect(
        result,
        '<title>Tom &amp; Jerry</title>',
      );
    });

    test('handles numeric entity split across chunks', () async {
      final result = await sanitize([
        '<title>Tom &#3',
        '8; Jerry</title>',
      ]);

      expect(
        result,
        '<title>Tom &#38; Jerry</title>',
      );
    });

    test('handles hexadecimal entity split across chunks', () async {
      final result = await sanitize([
        '<title>Tom &#x2',
        '6; Jerry</title>',
      ]);

      expect(
        result,
        '<title>Tom &#x26; Jerry</title>',
      );
    });

    test('repairs incomplete ampersand at end of stream', () async {
      final result = await sanitize([
        '<title>Tom &',
      ]);

      expect(
        result,
        '<title>Tom &amp;',
      );
    });

    test('handles multiple invalid ampersands', () async {
      final result = await sanitize([
        '<title>Tom & Jerry & Spike</title>',
      ]);

      expect(
        result,
        '<title>Tom &amp; Jerry &amp; Spike</title>',
      );
    });

    test('handles empty chunks', () async {
      final result = await sanitize([
        '',
        '<title>',
        '',
        'Hello',
        '',
        '</title>',
      ]);

      expect(
        result,
        '<title>Hello</title>',
      );
    });

    test(
      'does not modify ampersands in URLs when they are valid text',
      () async {
        final result = await sanitize([
          '<url>https://example.com?a=1&b=2</url>',
        ]);

        expect(
          result,
          '<url>https://example.com?a=1&amp;b=2</url>',
        );
      },
    );
  });
}
