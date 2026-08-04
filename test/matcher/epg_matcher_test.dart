import 'dart:io';

import 'package:m3u_xmltv/src/matcher/epg_matcher.dart';
import 'package:m3u_xmltv/src/parsers/m3u_parser.dart';
import 'package:m3u_xmltv/src/parsers/xmltv_parser.dart';
import 'package:test/test.dart';

void main() {
  group('EpgMatcher', () {
    late File m3uFile;
    late File xmlFile;

    final xmlParser = XmltvParser();
    final matcher = EpgMatcher();

    setUp(() {
      m3uFile = File('test/fixtures/sample.m3u');
      xmlFile = File('test/fixtures/sample.xml');
    });

    test('successfully matches M3U entry with EPG programs by tvgId', () async {
      final m3uString = await m3uFile.readAsString();
      final playlist = M3uParser.parseString(m3uString);
      final epgData = await xmlParser.parseStream(xmlFile.openRead());

      final matchedList = matcher.match(
        m3uChannels: playlist.entries,
        xmltvModel: epgData,
      );

      final discoveryMatch = matchedList.firstWhere(
        (m) => m.m3uChannel.tvgId == 'discovery.us',
      );

      expect(discoveryMatch.programs, isNotEmpty);
      expect(
        discoveryMatch.programs.map((p) => p.title),
        contains('MythBusters'),
      );
    });

    test(
      'returns entry with empty programs when channel has no matching EPG',
      () async {
        final m3uString = await m3uFile.readAsString();
        final playlist = M3uParser.parseString(m3uString);
        final epgData = await xmlParser.parseStream(xmlFile.openRead());

        final matchedList = matcher.match(
          m3uChannels: playlist.entries,
          xmltvModel: epgData,
        );

        final cnnMatch = matchedList.firstWhere(
          (m) => m.m3uChannel.tvgId == 'cnn.us',
        );

        expect(cnnMatch.programs, isEmpty);
      },
    );
  });
}
