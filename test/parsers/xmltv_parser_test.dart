import 'dart:io';
import 'package:m3u_xmltv/src/parsers/xmltv_parser.dart';
import 'package:test/test.dart';

void main() {
  group('XmltvParser', () {
    late File sampleXmlFile;
    final parser = XmltvParser();
    setUp(() {
      sampleXmlFile = File('test/fixtures/sample.xml');
    });

    test('parseByteStream streams channels and programs correctly', () async {
      final byteStream = sampleXmlFile.openRead();

      final epgData = await parser.parseStream(byteStream);

      expect(epgData.channels, isNotEmpty);

      expect(epgData.channels.first.id, equals('discovery.us'));

      expect(
        epgData.channels.first.displayNames.first,
        equals('Discovery Channel'),
      );

      expect(epgData.programs, isNotEmpty);

      expect(epgData.programs.first.title, equals('MythBusters'));

      expect(epgData.programs.first.channelId, equals('discovery.us'));
    });

    test('gracefully skips programmes with invalid date format', () async {
      final byteStream = sampleXmlFile.openRead();
      final epg = await parser.parseStream(byteStream);

      expect(epg.channels.length, equals(1));
      expect(epg.programs.length, equals(2));
    });
  });
}
