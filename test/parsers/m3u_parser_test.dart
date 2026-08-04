import 'dart:convert';
import 'dart:io';

import 'package:m3u_xmltv/src/parsers/m3u_parser.dart';
import 'package:test/test.dart';

void main() {
  group('M3uParser', () {
    late String sampleString;
    late File sampleFile;

    setUp(() async {
      sampleFile = File('test/fixtures/sample.m3u');
      sampleString = await sampleFile.readAsString();
    });

    test('parseString correctly parses M3U entries', () async {
      final playlist = M3uParser.parseString(sampleString);

      expect(
        playlist.entries.length,
        equals(5),
      );

      final first = playlist.entries.first;
      expect(
        first.title,
        equals('Discovery Channel'),
      );
      expect(
        first.tvgId,
        equals('discovery.us'),
      );
      expect(
        first.group,
        equals('Documentary'),
      );
      expect(
        first.url,
        equals('http://example.com/stream/discovery.m3u8'),
      );
    });

    test('parseStream correctly parses stream lines', () async {
      final linesStream =
          Stream.value(
            sampleString,
          ).transform(
            const LineSplitter(),
          );

      final playlist = await M3uParser.parseStream(linesStream).toList();

      expect(
        playlist.length,
        equals(5),
      );
      expect(
        playlist.last.title,
        equals('Valid Channel'),
      );
      expect(
        playlist.last.url,
        equals('http://example.com/valid.m3u8'),
      );
    });

    test('parseByteStream correctly parses byte stream', () async {
      final byteStream = sampleFile.openRead();

      final playlist = await M3uParser.parseByteStream(byteStream).toList();

      expect(
        playlist.length,
        equals(5),
      );
      expect(
        playlist.first.tvgId,
        equals('discovery.us'),
      );
    });

    test(
      'handles malformed or missing fields gracefully without crashing',
      () async {
        final playlist = M3uParser.parseString(sampleString);

        expect(playlist.entries, isNotEmpty);
        expect(
          playlist.entries.map((e) => e.tvgId),
          isNot(contains('broken')),
        );
      },
    );
  });
}
