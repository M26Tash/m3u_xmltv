import 'dart:convert';
import 'package:m3u_xmltv/src/mappers/m3u_mapper.dart';
import 'package:m3u_xmltv/src/models/m3u_model.dart';

class M3uPlaylist {
  final List<M3uModel> entries;

  final List<String> epgUrls;

  const M3uPlaylist({
    required this.entries,
    this.epgUrls = const [],
  });
}

abstract final class M3uParser {
  static M3uPlaylist parseString(String content) {
    final lines = const LineSplitter().convert(content);
    return _parseLines(lines);
  }

  static Stream<M3uModel> parseStream(Stream<String> lineStream) async* {
    String? currentExtInf;
    String? currentExtGrp;
    final httpHeaders = <String, String>{};
    final kodiProps = <String, String>{};

    await for (var line in lineStream) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        currentExtInf = line;
      } else if (line.startsWith('#EXTGRP:')) {
        currentExtGrp = line.substring(8).trim();
      } else if (line.startsWith('#EXTVLCOPT:')) {
        _parseOptLine(line.substring(11), httpHeaders);
      } else if (line.startsWith('#KODIPROP:')) {
        _parseOptLine(line.substring(10), kodiProps);
      } else if (!line.startsWith('#') && currentExtInf != null) {
        yield M3uMapper.fromLines(
          extInfLine: currentExtInf,
          url: line,
          extGrpGroup: currentExtGrp,
          httpHeaders: Map.from(httpHeaders),
          kodiProps: Map.from(kodiProps),
        );

        currentExtInf = null;
        currentExtGrp = null;
        httpHeaders.clear();
        kodiProps.clear();
      }
    }
  }

  static Stream<M3uModel> parseByteStream(
    Stream<List<int>> byteStream, {
    Encoding encoding = utf8,
  }) {
    final lineStream = byteStream
        .transform(encoding.decoder)
        .transform(const LineSplitter());

    return parseStream(lineStream);
  }

  static M3uPlaylist _parseLines(List<String> lines) {
    final entries = <M3uModel>[];
    final epgUrls = <String>[];

    String? currentExtInf;
    String? currentExtGrp;
    final httpHeaders = <String, String>{};
    final kodiProps = <String, String>{};

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTM3U')) {
        _extractEpgUrls(line, epgUrls);
      } else if (line.startsWith('#EXTINF:')) {
        currentExtInf = line;
      } else if (line.startsWith('#EXTGRP:')) {
        currentExtGrp = line.substring(8).trim();
      } else if (line.startsWith('#EXTVLCOPT:')) {
        _parseOptLine(line.substring(11), httpHeaders);
      } else if (line.startsWith('#KODIPROP:')) {
        _parseOptLine(line.substring(10), kodiProps);
      } else if (!line.startsWith('#') && currentExtInf != null) {
        entries.add(
          M3uMapper.fromLines(
            extInfLine: currentExtInf,
            url: line,
            extGrpGroup: currentExtGrp,
            httpHeaders: Map.from(httpHeaders),
            kodiProps: Map.from(kodiProps),
          ),
        );

        currentExtInf = null;
        currentExtGrp = null;
        httpHeaders.clear();
        kodiProps.clear();
      }
    }

    return M3uPlaylist(entries: entries, epgUrls: epgUrls);
  }

  static void _extractEpgUrls(String headerLine, List<String> epgUrls) {
    final regExp = RegExp(r'(?:x-tvg-url|url-tvg)="([^"]+)"');
    final match = regExp.firstMatch(headerLine);
    if (match != null) {
      final rawUrls = match.group(1);
      if (rawUrls != null) {
        epgUrls.addAll(rawUrls.split(',').map((e) => e.trim()));
      }
    }
  }

  static void _parseOptLine(String optContent, Map<String, String> targetMap) {
    final equalsIndex = optContent.indexOf('=');
    if (equalsIndex != -1) {
      final key = optContent.substring(0, equalsIndex).trim();
      final value = optContent.substring(equalsIndex + 1).trim();

      if (key == 'http-user-agent') {
        targetMap['User-Agent'] = value;
      } else if (key == 'http-referrer') {
        targetMap['Referer'] = value;
      } else {
        targetMap[key] = value;
      }
    }
  }
}
