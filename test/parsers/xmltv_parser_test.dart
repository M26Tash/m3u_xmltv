import 'dart:io';

import 'package:m3u_xmltv/src/models/xmltv_entity.dart';
import 'package:m3u_xmltv/src/parsers/xmltv_parser.dart';
import 'package:test/test.dart';

void main() {
  group('XmltvParser', () {
    late File sampleXmlFile;
    late XmltvParser parser;

    setUp(() {
      sampleXmlFile = File('test/fixtures/sample.xml');
      parser = XmltvParser();
    });

    group('parseStream', () {
      test('parses channels and programmes correctly', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        final channels = entities
            .whereType<XmltvChannelEntity>()
            .map((entity) => entity.channel)
            .toList();

        final programs = entities
            .whereType<XmltvProgramEntity>()
            .map((entity) => entity.program)
            .toList();

        expect(channels, hasLength(2));
        expect(programs, hasLength(4));
      });

      test('preserves channel and programme order', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        expect(entities, hasLength(6));

        expect(entities[0], isA<XmltvChannelEntity>());
        expect(entities[1], isA<XmltvChannelEntity>());
        expect(entities[2], isA<XmltvProgramEntity>());
        expect(entities[3], isA<XmltvProgramEntity>());
        expect(entities[4], isA<XmltvProgramEntity>());
        expect(entities[5], isA<XmltvProgramEntity>());

        final firstChannel = (entities[0] as XmltvChannelEntity).channel;

        final secondChannel = (entities[1] as XmltvChannelEntity).channel;

        final firstProgram = (entities[2] as XmltvProgramEntity).program;

        final secondProgram = (entities[3] as XmltvProgramEntity).program;

        final thirdProgram = (entities[4] as XmltvProgramEntity).program;

        final fourthProgram = (entities[5] as XmltvProgramEntity).program;

        expect(firstChannel.id, equals('discovery.us'));
        expect(secondChannel.id, equals('news.us'));

        expect(firstProgram.title, equals('MythBusters'));
        expect(secondProgram.title, equals('News'));
        expect(thirdProgram.title, equals('Tom & Jerry'));
        expect(fourthProgram.title, equals('Program Without Stop'));
      });

      test('parses channel fields correctly', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        final channels = entities
            .whereType<XmltvChannelEntity>()
            .map((entity) => entity.channel)
            .toList();

        final discovery = channels.firstWhere(
          (channel) => channel.id == 'discovery.us',
        );

        expect(
          discovery.displayNames,
          equals([
            'Discovery Channel',
            'Discovery Channel',
          ]),
        );

        expect(
          discovery.name,
          equals('Discovery Channel'),
        );

        expect(
          discovery.iconUrl,
          equals('http://example.com/logo.png'),
        );

        expect(
          discovery.channelUrl,
          equals('http://example.com/discovery'),
        );
      });

      test('parses programme fields correctly', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        final programs = entities
            .whereType<XmltvProgramEntity>()
            .map((entity) => entity.program)
            .toList();

        final mythBusters = programs.firstWhere(
          (program) => program.title == 'MythBusters',
        );

        expect(
          mythBusters.channelId,
          equals('discovery.us'),
        );

        expect(
          mythBusters.startTime,
          equals(
            DateTime.parse('2026-08-04T20:00:00+03:00'),
          ),
        );

        expect(
          mythBusters.endTime,
          equals(
            DateTime.parse('2026-08-04T21:00:00+03:00'),
          ),
        );

        expect(
          mythBusters.subTitle,
          equals('Special Episode'),
        );

        expect(
          mythBusters.description,
          equals('Special Episode'),
        );

        expect(
          mythBusters.presenter,
          equals('Adam Savage'),
        );

        expect(
          mythBusters.guest,
          equals('Special Guest'),
        );

        expect(
          mythBusters.date,
          equals('20260804'),
        );

        expect(
          mythBusters.category,
          equals('Documentary'),
        );

        expect(
          mythBusters.language,
          equals('en'),
        );

        expect(
          mythBusters.country,
          equals('US'),
        );

        expect(
          mythBusters.length,
          equals(60),
        );

        expect(
          mythBusters.iconUrl,
          equals('http://example.com/mythbusters.png'),
        );

        expect(
          mythBusters.episodeNum,
          equals('1.2.0/1'),
        );

        expect(
          mythBusters.ratingValue,
          equals('TV-PG'),
        );
      });

      test('calculates programme length from start and end times', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        final programs = entities
            .whereType<XmltvProgramEntity>()
            .map((entity) => entity.program)
            .toList();

        final mythBusters = programs.firstWhere(
          (program) => program.title == 'MythBusters',
        );

        final news = programs.firstWhere(
          (program) => program.title == 'News',
        );

        expect(mythBusters.length, equals(60));
        expect(news.length, equals(60));
      });

      test('uses length element when stop time is missing', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        final programs = entities
            .whereType<XmltvProgramEntity>()
            .map((entity) => entity.program)
            .toList();

        final program = programs.firstWhere(
          (program) => program.title == 'Program Without Stop',
        );

        expect(program.startTime, isNotNull);
        expect(program.endTime, isNull);
        expect(program.length, equals(45));
      });

      test('skips programmes with invalid date format', () async {
        final entities = await parser
            .parseStream(sampleXmlFile.openRead())
            .toList();

        final programs = entities
            .whereType<XmltvProgramEntity>()
            .map((entity) => entity.program)
            .toList();

        expect(programs, hasLength(4));

        expect(
          programs.map((program) => program.title),
          isNot(contains('Broken Date Program')),
        );
      });

      test('handles XML data split across stream chunks', () async {
        final bytes = await sampleXmlFile.readAsBytes();

        final byteStream = Stream<List<int>>.fromIterable([
          bytes.sublist(0, 10),
          bytes.sublist(10, 25),
          bytes.sublist(25, 50),
          bytes.sublist(50, 100),
          bytes.sublist(100, 200),
          bytes.sublist(200),
        ]);

        final entities = await parser.parseStream(byteStream).toList();

        final channels = entities.whereType<XmltvChannelEntity>().toList();

        final programs = entities.whereType<XmltvProgramEntity>().toList();

        expect(channels, hasLength(2));
        expect(programs, hasLength(4));
      });

      test('handles empty stream', () async {
        final entities = await parser
            .parseStream(Stream<List<int>>.empty())
            .toList();

        expect(entities, isEmpty);
      });
    });

    group('parseBytes', () {
      test('returns complete XmltvModel', () async {
        final bytes = await sampleXmlFile.readAsBytes();

        final result = await parser.parseBytes(bytes);

        expect(result.channels, hasLength(2));
        expect(result.programs, hasLength(4));

        expect(
          result.channels.first.id,
          equals('discovery.us'),
        );

        expect(
          result.programs.first.title,
          equals('MythBusters'),
        );
      });

      test('returns empty model for empty input', () async {
        final result = await parser.parseBytes([]);

        expect(result.channels, isEmpty);
        expect(result.programs, isEmpty);
      });
    });

    group('parseString', () {
      test('returns complete XmltvModel', () async {
        final source = await sampleXmlFile.readAsString();

        final result = await parser.parseString(source);

        expect(result.channels, hasLength(2));
        expect(result.programs, hasLength(4));

        expect(
          result.channels.first.id,
          equals('discovery.us'),
        );

        expect(
          result.programs.first.title,
          equals('MythBusters'),
        );
      });

      test('returns empty model for empty input', () async {
        final result = await parser.parseString('');

        expect(result.channels, isEmpty);
        expect(result.programs, isEmpty);
      });
    });
  });
}
