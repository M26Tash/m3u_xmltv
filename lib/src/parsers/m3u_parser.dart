import 'dart:convert';

import 'package:m3u_xmltv/src/mappers/m3u_mapper.dart';
import 'package:m3u_xmltv/src/models/m3u_entry.dart';
import 'package:m3u_xmltv/src/models/m3u_playlist.dart';

/// Provides methods for parsing M3U playlists.
abstract final class M3uParser {
  /// Parses an M3U playlist from a string.
  ///
  /// Returns an [M3uPlaylist] containing the parsed entries and any EPG URLs
  /// declared in the playlist header.
  static M3uPlaylist parseString(String content) {
    final state = _M3uParserState();
    final entries = <M3uEntry>[];

    const splitter = LineSplitter();

    for (final line in splitter.convert(content)) {
      final entry = state.parseLine(line);

      if (entry != null) {
        entries.add(entry);
      }
    }

    return M3uPlaylist(
      entries: entries,
      epgUrls: state.epgUrls,
    );
  }

  /// Parses an M3U playlist from encoded bytes.
  ///
  /// The [encoding] defaults to UTF-8.
  ///
  /// Returns an [M3uPlaylist] containing the parsed entries and any EPG URLs
  /// declared in the playlist header.
  static M3uPlaylist parseBytes(
    List<int> bytes, {
    Encoding encoding = utf8,
  }) {
    final state = _M3uParserState();
    final entries = <M3uEntry>[];

    final content = encoding.decode(bytes);

    const splitter = LineSplitter();

    for (final line in splitter.convert(content)) {
      final entry = state.parseLine(line);

      if (entry != null) {
        entries.add(entry);
      }
    }

    return M3uPlaylist(
      entries: entries,
      epgUrls: state.epgUrls,
    );
  }

  /// Parses an M3U playlist from a stream of lines.
  ///
  /// Each [M3uEntry] is yielded as soon as it is parsed, allowing large
  /// playlists to be processed without keeping the entire playlist in memory.
  ///
  /// The stream must contain one M3U line per event.
  static Stream<M3uEntry> parseStream(
    Stream<String> lines,
  ) async* {
    final state = _M3uParserState();

    await for (final line in lines) {
      final entry = state.parseLine(line);

      if (entry != null) {
        yield entry;
      }
    }
  }
}

final class _M3uParserState {
  String? _currentExtInf;
  String? _currentExtGrp;

  final _httpHeaders = <String, String>{};
  final _kodiProps = <String, String>{};

  final epgUrls = <String>[];

  M3uEntry? parseLine(String line) {
    line = line.trim();

    if (line.isEmpty) {
      return null;
    }

    if (line.startsWith('#EXTM3U')) {
      _extractEpgUrls(line);
      return null;
    }

    if (line.startsWith('#EXTINF:')) {
      _currentExtInf = line;
      return null;
    }

    if (line.startsWith('#EXTGRP:')) {
      _currentExtGrp = line.substring(8).trim();
      return null;
    }

    if (line.startsWith('#EXTVLCOPT:')) {
      _parseOptLine(
        line.substring(11),
        _httpHeaders,
      );
      return null;
    }

    if (line.startsWith('#KODIPROP:')) {
      _parseOptLine(
        line.substring(10),
        _kodiProps,
      );
      return null;
    }

    if (!line.startsWith('#') && _currentExtInf != null) {
      return _createEntry(line);
    }

    return null;
  }

  M3uEntry? _createEntry(String url) {
    try {
      return M3uMapper.fromLines(
        extInfLine: _currentExtInf!,
        url: url,
        extGrpGroup: _currentExtGrp,
        httpHeaders: Map.from(_httpHeaders),
        kodiProps: Map.from(_kodiProps),
      );
    } finally {
      _reset();
    }
  }

  void _reset() {
    _currentExtInf = null;
    _currentExtGrp = null;
    _httpHeaders.clear();
    _kodiProps.clear();
  }

  void _extractEpgUrls(String headerLine) {
    final match = RegExp(
      r'(?:x-tvg-url|url-tvg)="([^"]+)"',
    ).firstMatch(headerLine);

    if (match == null) {
      return;
    }

    final rawUrls = match.group(1);

    if (rawUrls == null) {
      return;
    }

    epgUrls.addAll(
      rawUrls
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty),
    );
  }

  void _parseOptLine(
    String optContent,
    Map<String, String> targetMap,
  ) {
    final equalsIndex = optContent.indexOf('=');

    if (equalsIndex == -1) {
      return;
    }

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
