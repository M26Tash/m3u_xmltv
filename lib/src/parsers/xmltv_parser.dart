import 'dart:async';
import 'dart:convert';
import 'package:m3u_xmltv/src/exceptions/m3u_xmltv_exception.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';
import 'package:m3u_xmltv/src/models/xmltv_entity.dart';
import 'package:m3u_xmltv/src/models/xmltv_model.dart';
import 'package:m3u_xmltv/src/parsers/epg_channel_parser.dart';
import 'package:m3u_xmltv/src/parsers/epg_program_parser.dart';
import 'package:m3u_xmltv/src/utils/sanitizer/xml_sanitizer.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// Parses XMLTV EPG data from strings, byte lists, or byte streams.
class XmltvParser {
  final EpgChannelParser _channelParser;
  final EpgProgramParser _programParser;

  /// Creates an [XmltvParser].
  ///
  /// Custom [channelParser] and [programParser] instances can be provided
  /// to customize how XMLTV channels and programmes are converted into
  /// models.
  XmltvParser({
    EpgChannelParser? channelParser,
    EpgProgramParser? programParser,
  }) : _channelParser = channelParser ?? EpgChannelParser(),
       _programParser = programParser ?? EpgProgramParser();

  /// Parses an XMLTV byte stream incrementally.
  ///
  /// Returns a stream of [XmltvEntity] objects containing either an
  /// [EpgChannelModel] or an [EpgProgramModel].
  ///
  /// XML data is processed incrementally, and only the currently processed
  /// XML subtree is materialized. This allows large XMLTV files to be parsed
  /// without loading the entire document into memory.
  ///
  /// Invalid or unsupported XMLTV entries are skipped.
  ///
  /// Throws [M3uXmltvException] if the XMLTV stream cannot be parsed.
  Stream<XmltvEntity> parseStream(
    Stream<List<int>> byteStream,
  ) async* {
    try {
      final subtreeStream = byteStream
          .transform(utf8.decoder)
          .transform(const XmlSanitizer())
          .toXmlEvents()
          .normalizeEvents()
          .selectSubtreeEvents(
            (event) => event.name == 'channel' || event.name == 'programme',
          )
          .toXmlNodes();

      await for (final nodes in subtreeStream) {
        try {
          final element = nodes.whereType<XmlElement>().firstOrNull;

          if (element == null) {
            continue;
          }

          switch (element.name.local) {
            case 'channel':
              final channel = _channelParser.parse(element);

              if (channel != null) {
                yield XmltvChannelEntity(channel);
              }

            case 'programme':
              final program = _programParser.parse(element);

              if (program != null) {
                yield XmltvProgramEntity(program);
              }
          }
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      if (e is M3uXmltvException) {
        rethrow;
      }

      throw M3uXmltvException(
        'Failed to parse XMLTV stream: $e',
        error: e,
      );
    }
  }

  /// Parses XMLTV data from encoded bytes into an [XmltvModel].
  ///
  /// The entire parsed result is stored in memory, including all channels
  /// and programmes.
  ///
  /// For large XMLTV files, prefer [parseStream] to process entries
  /// incrementally.
  Future<XmltvModel> parseBytes(List<int> bytes) async {
    final channels = <EpgChannelModel>[];
    final programs = <EpgProgramModel>[];

    await for (final entity in parseStream(
      Stream.value(bytes),
    )) {
      switch (entity) {
        case XmltvChannelEntity(:final channel):
          channels.add(channel);

        case XmltvProgramEntity(:final program):
          programs.add(program);
      }
    }

    return XmltvModel(
      channels: channels,
      programs: programs,
    );
  }

  /// Parses XMLTV data from a string into an [XmltvModel].
  ///
  /// The entire parsed result is stored in memory, including all channels
  /// and programmes.
  ///
  /// For large XMLTV files, prefer [parseStream] to process entries
  /// incrementally.
  Future<XmltvModel> parseString(String source) {
    return parseBytes(
      utf8.encode(source),
    );
  }
}
