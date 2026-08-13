import 'dart:io';

import 'package:m3u_xmltv/src/matcher/epg_matcher.dart';
import 'package:m3u_xmltv/src/matcher/matched_channel_epg.dart';
import 'package:m3u_xmltv/src/models/xmltv_model.dart';
import 'package:m3u_xmltv/src/parsers/m3u_parser.dart';
import 'package:m3u_xmltv/src/parsers/xmltv_parser.dart';
import 'package:test/test.dart';

void main() {
  group('EpgMatcher', () {
    late File m3uFile;
    late File xmlFile;

    final matcher = EpgMatcher();
    final xmltvParser = XmltvParser();

    setUp(() {
      m3uFile = File('test/fixtures/sample.m3u');
      xmlFile = File('test/fixtures/sample.xml');
    });

    test('returns a result for every M3U entry', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final results = matcher.match(
        m3uChannels: playlist.entries,
        xmltvModel: epg,
      );

      expect(results, hasLength(playlist.entries.length));
      expect(results, everyElement(isA<MatchedChannelEpg>()));
    });

    test('matches channel by tvgId', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final results = matcher.match(
        m3uChannels: playlist.entries,
        xmltvModel: epg,
      );

      final match = results.firstWhere(
        (result) => result.m3uChannel.tvgId == 'discovery.us',
      );

      expect(match.epgChannel, isNotNull);
      expect(match.epgChannel!.id, equals('discovery.us'));
      expect(match.programs, isNotEmpty);

      expect(
        match.programs.map((program) => program.title),
        contains('MythBusters'),
      );
    });

    test('returns empty programs when channel has no EPG match', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final results = matcher.match(
        m3uChannels: playlist.entries,
        xmltvModel: epg,
      );

      final match = results.firstWhere(
        (result) => result.m3uChannel.tvgId == 'cnn.us',
      );

      expect(match.epgChannel, isNull);
      expect(match.programs, isEmpty);
    });

    test('falls back to tvgName when tvgId does not match', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final discoveryEntry = playlist.entries.firstWhere(
        (entry) => entry.tvgId == 'discovery.us',
      );

      final entry = discoveryEntry.copyWith(
        tvgId: 'unknown.id',
        tvgName: 'Discovery Channel',
      );

      final results = matcher.match(
        m3uChannels: [entry],
        xmltvModel: epg,
      );

      expect(results, hasLength(1));
      expect(results.first.epgChannel, isNotNull);
      expect(results.first.epgChannel!.id, equals('discovery.us'));
      expect(results.first.programs, isNotEmpty);
    });

    test('falls back to title when tvgId and tvgName do not match', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final discoveryEntry = playlist.entries.firstWhere(
        (entry) => entry.tvgId == 'discovery.us',
      );

      final entry = discoveryEntry.copyWith(
        tvgId: 'unknown.id',
        tvgName: 'Unknown Channel',
        title: 'Discovery Channel',
      );

      final results = matcher.match(
        m3uChannels: [entry],
        xmltvModel: epg,
      );

      expect(results, hasLength(1));
      expect(results.first.epgChannel, isNotNull);
      expect(results.first.epgChannel!.id, equals('discovery.us'));
      expect(results.first.programs, isNotEmpty);
    });

    test('does not match an unknown channel', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final unknownEntry = playlist.entries.first.copyWith(
        tvgId: 'unknown.id',
        tvgName: 'Unknown Channel',
        title: 'Completely Unknown Channel',
      );

      final results = matcher.match(
        m3uChannels: [unknownEntry],
        xmltvModel: epg,
      );

      expect(results, hasLength(1));
      expect(results.first.epgChannel, isNull);
      expect(results.first.programs, isEmpty);
    });

    test('sorts matched programs by start time', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final results = matcher.match(
        m3uChannels: playlist.entries,
        xmltvModel: epg,
      );

      final match = results.firstWhere(
        (result) => result.m3uChannel.tvgId == 'discovery.us',
      );

      expect(match.programs, isNotEmpty);

      for (var i = 1; i < match.programs.length; i++) {
        expect(
          match.programs[i].startTime.isAfter(
            match.programs[i - 1].startTime,
          ),
          isTrue,
        );
      }
    });

    test('preserves the original M3U entry', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final results = matcher.match(
        m3uChannels: playlist.entries,
        xmltvModel: epg,
      );

      for (final result in results) {
        expect(
          playlist.entries,
          contains(result.m3uChannel),
        );
      }
    });

    test('returns EPG channel when it has no programs', () async {
      final m3uString = await m3uFile.readAsString();
      final xmlString = await xmlFile.readAsString();

      final playlist = M3uParser.parseString(m3uString);
      final epg = await xmltvParser.parseString(xmlString);

      final discoveryEntry = playlist.entries.firstWhere(
        (entry) => entry.tvgId == 'discovery.us',
      );

      final epgWithoutPrograms = XmltvModel(
        channels: epg.channels,
        programs: const [],
      );

      final results = matcher.match(
        m3uChannels: [discoveryEntry],
        xmltvModel: epgWithoutPrograms,
      );

      expect(results, hasLength(1));
      expect(results.first.epgChannel, isNotNull);
      expect(results.first.epgChannel!.id, equals('discovery.us'));
      expect(results.first.programs, isEmpty);
    });
  });
}
