import 'dart:convert';
import 'dart:io';
import 'package:m3u_xmltv/src/models/m3u_entry.dart';
import 'package:m3u_xmltv/src/parsers/m3u_parser.dart';
import 'package:test/test.dart';

void main() {
  late String sampleString;
  late List<int> sampleBytes;

  setUp(() async {
    final file = File('test/fixtures/sample.m3u');

    sampleString = await file.readAsString();
    sampleBytes = await file.readAsBytes();
  });

  group('parseString', () {
    test('parses valid M3U entries', () {
      final playlist = M3uParser.parseString(sampleString);

      expect(
        playlist.entries,
        hasLength(7),
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
        first.tvgName,
        equals('Discovery HD'),
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

    test('parses entries without attributes', () {
      final playlist = M3uParser.parseString(sampleString);

      final entry = playlist.entries.firstWhere(
        (entry) => entry.title == 'Simple Channel Without Attributes',
      );

      expect(
        entry.url,
        equals('http://example.com/stream1.m3u8'),
      );
      expect(entry.tvgId, isNull);
      expect(entry.tvgName, isNull);
      expect(entry.group, isNull);
    });

    test('parses entries with EXTGRP', () {
      final playlist = M3uParser.parseString(sampleString);

      final entry = playlist.entries.firstWhere(
        (entry) => entry.title == 'CNN',
      );

      expect(
        entry.group,
        equals('News'),
      );
    });

    test('skips invalid lines', () {
      final playlist = M3uParser.parseString(sampleString);

      expect(
        playlist.entries.map((entry) => entry.title),
        isNot(
          contains('INVALID LINE THAT SHOULD BE SKIPPED'),
        ),
      );
    });

    test('skips entries without URL', () {
      final playlist = M3uParser.parseString(sampleString);

      expect(
        playlist.entries.map((entry) => entry.title),
        isNot(
          contains('Broken Channel No URL'),
        ),
      );

      expect(
        playlist.entries.map((entry) => entry.title),
        isNot(
          contains('Channel With Empty URL'),
        ),
      );
    });

    test('parses an entry with empty attributes', () {
      final playlist = M3uParser.parseString(sampleString);

      final entry = playlist.entries.firstWhere(
        (entry) => entry.title == 'Channel with URL',
      );

      expect(
        entry.url,
        equals('http://example.com/withurl.m3u8'),
      );
      expect(entry.tvgId, isEmpty);
      expect(entry.tvgName, isEmpty);
    });

    test('parses the final valid entry', () {
      final playlist = M3uParser.parseString(sampleString);

      final entry = playlist.entries.firstWhere(
        (entry) => entry.title == 'Valid Channel',
      );

      expect(
        entry.tvgId,
        equals('valid.id'),
      );
      expect(
        entry.url,
        equals('http://example.com/valid.m3u8'),
      );
    });

    test('parses VLC HTTP headers', () {
      final playlist = M3uParser.parseString(sampleString);

      final entry = playlist.entries.firstWhere(
        (entry) => entry.title == 'Channel With VLC Options',
      );

      expect(
        entry.httpHeaders['User-Agent'],
        equals('TestAgent'),
      );

      expect(
        entry.httpHeaders['Referer'],
        equals('https://example.com'),
      );
    });

    test('parses Kodi properties', () {
      final playlist = M3uParser.parseString(sampleString);

      final entry = playlist.entries.firstWhere(
        (entry) => entry.title == 'Channel With Kodi Properties',
      );

      expect(
        entry.kodiProps['inputstream.adaptive.manifest_type'],
        equals('hls'),
      );
    });

    test('extracts EPG URLs', () {
      final playlist = M3uParser.parseString(sampleString);

      expect(
        playlist.epgUrls,
        equals([
          'https://example.com/epg1.xml',
          'https://example.com/epg2.xml',
        ]),
      );
    });

    test('returns an empty playlist for empty input', () {
      final playlist = M3uParser.parseString('');

      expect(playlist.entries, isEmpty);
      expect(playlist.epgUrls, isEmpty);
    });
  });

  group('parseBytes', () {
    test('parses UTF-8 encoded bytes', () {
      final playlist = M3uParser.parseBytes(sampleBytes);

      expect(
        playlist.entries,
        hasLength(7),
      );

      expect(
        playlist.entries.first.title,
        equals('Discovery Channel'),
      );
    });

    test('uses the provided encoding', () {
      const content = '''
#EXTM3U
#EXTINF:-1,Hello
https://example.com/stream.m3u8
''';

      final bytes = latin1.encode(content);

      final playlist = M3uParser.parseBytes(
        bytes,
        encoding: latin1,
      );

      expect(
        playlist.entries,
        hasLength(1),
      );
      expect(
        playlist.entries.single.title,
        equals('Hello'),
      );
    });

    test('returns an empty playlist for empty bytes', () {
      final playlist = M3uParser.parseBytes(<int>[]);

      expect(playlist.entries, isEmpty);
      expect(playlist.epgUrls, isEmpty);
    });
  });

  group('parseStream', () {
    test('parses entries from a stream of lines', () async {
      final lines = Stream.fromIterable(
        sampleString.split('\n'),
      );

      final entries = await M3uParser.parseStream(lines).toList();

      expect(
        entries,
        hasLength(7),
      );

      expect(
        entries.first.title,
        equals('Discovery Channel'),
      );

      expect(
        entries.last.title,
        equals('Channel With Kodi Properties'),
      );
    });

    test('yields M3uEntry objects', () async {
      final lines = Stream.fromIterable(
        const [
          '#EXTINF:-1,Test Channel',
          'https://example.com/test.m3u8',
        ],
      );

      final entries = await M3uParser.parseStream(lines).toList();

      expect(
        entries.single,
        isA<M3uEntry>(),
      );
    });

    test('skips invalid lines', () async {
      final lines = Stream.fromIterable(
        const [
          'INVALID LINE',
          '#EXTINF:-1,Valid Channel',
          'https://example.com/valid.m3u8',
        ],
      );

      final entries = await M3uParser.parseStream(lines).toList();

      expect(entries, hasLength(1));
      expect(
        entries.single.title,
        equals('Valid Channel'),
      );
    });

    test('parses entries incrementally', () async {
      final lines = Stream.fromIterable(
        const [
          '#EXTINF:-1,First Channel',
          'https://example.com/first.m3u8',
          '#EXTINF:-1,Second Channel',
          'https://example.com/second.m3u8',
        ],
      );

      final entries = await M3uParser.parseStream(lines).toList();

      expect(
        entries,
        hasLength(2),
      );
      expect(
        entries[0].title,
        equals('First Channel'),
      );
      expect(
        entries[1].title,
        equals('Second Channel'),
      );
    });
  });
}
