import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:m3u_xmltv/src/exceptions/m3u_xmltv_exception.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';
import 'package:m3u_xmltv/src/models/xmltv_model.dart';
import 'package:m3u_xmltv/src/parsers/epg_channel_parser.dart';
import 'package:m3u_xmltv/src/parsers/epg_program_parser.dart';
import 'package:m3u_xmltv/src/utils/extensions/xml_subtree_extension.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

class XmltvParser {
  final EpgChannelParser _channelParser;
  final EpgProgramParser _programParser;

  XmltvParser({
    EpgChannelParser? channelParser,
    EpgProgramParser? programParser,
  }) : _channelParser = channelParser ?? EpgChannelParser(),
       _programParser = programParser ?? EpgProgramParser();

  Future<XmltvModel> parseStream(Stream<List<int>> byteStream) async {
    final channels = <EpgChannelModel>[];
    final programs = <EpgProgramModel>[];

    try {
      final bytes = await byteStream.fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );

      var xmlString = const Utf8Decoder(allowMalformed: true).convert(bytes);

      xmlString = xmlString.replaceAllMapped(
        RegExp(r'&(?!(amp|lt|gt|quot|apos);)'),
        (match) => '&amp;',
      );

      final events = Stream.fromIterable(
        parseEvents(xmlString),
      );

      await for (final subtreeEvents in events.selectSubtreeEvents(
        (event) => event.name == 'channel' || event.name == 'programme',
      )) {
        try {
          final nodes = const XmlNodeDecoder().convert(subtreeEvents);
          final element = nodes.whereType<XmlElement>().firstOrNull;
          if (element == null) continue;

          if (element.name.local == 'channel') {
            final channel = _channelParser.parse(element);
            if (channel != null) channels.add(channel);
          } else if (element.name.local == 'programme') {
            final program = _programParser.parse(element);
            if (program != null) programs.add(program);
          }
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      if (e is M3uXmltvException) rethrow;
      throw M3uXmltvException('Failed to parse XMLTV stream: $e', error: e);
    }

    return XmltvModel(
      channels: channels,
      programs: programs,
    );
  }

  Future<XmltvModel> parseUrl(
    Uri url, {
    HttpClient? customClient,
    Map<String, String>? headers,
  }) async {
    final client =
        customClient ??
        (HttpClient()
          ..connectionTimeout = const Duration(
            seconds: 30,
          ));

    try {
      final request = await client.getUrl(url);

      request.headers.set(
        'User-Agent',
        headers?['User-Agent'] ?? 'Mozilla/5.0',
      );

      headers?.forEach((key, value) {
        if (key.toLowerCase() != 'user-agent') {
          request.headers.set(key, value);
        }
      });

      final response = await request.close();

      if (response.statusCode != 200) {
        throw M3uXmltvException(
          'Failed to fetch XMLTV from URL. HTTP Status: ${response.statusCode}',
        );
      }

      return await parseStream(response);
    } catch (e) {
      if (e is M3uXmltvException) rethrow;
      throw M3uXmltvException('Error fetching XMLTV from $url: $e', error: e);
    } finally {
      if (customClient == null) {
        client.close();
      }
    }
  }
}
