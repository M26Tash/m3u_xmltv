// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:m3u_xmltv/m3u_xmltv.dart';

Future<void> main() async {
  await parseFromString();
  await parseFromBytes();
  await parseFromStream();
}

Future<void> parseFromString() async {
  const m3uContent = '''
#EXTM3U
#EXTINF:-1 tvg-id="cnn.us" tvg-name="CNN HD" group-title="News",CNN International
http://example.com/stream/cnn.m3u8
''';

  final playlist = M3uParser.parseString(m3uContent);

  print(
    'parseFromString() : entries ${playlist.entries.length}, epg ${playlist.epgUrls.length}',
  );
}

Future<void> parseFromBytes() async {
  const m3uContent = '''
#EXTM3U
#EXTINF:-1 tvg-id="cnn.us" tvg-name="CNN HD" group-title="News",CNN International
http://example.com/stream/cnn.m3u8
''';

  final bytes = utf8.encode(m3uContent);

  final playlist = M3uParser.parseBytes(bytes);

  print(
    'parseFromBytes() : entries ${playlist.entries.length}, epg ${playlist.epgUrls.length}',
  );
}

Future<void> parseFromStream() async {
  final lines = Stream.fromIterable(
    const [
      '#EXTM3U',
      '#EXTINF:-1 tvg-id="cnn.us" tvg-name="CNN HD" group-title="News",CNN International',
      'http://example.com/stream/cnn.m3u8',
      '#EXTINF:-1 tvg-id="discovery.us" group-title="Documentary",Discovery HD',
      'http://example.com/stream/discovery.m3u8',
    ],
  );

  final entries = M3uParser.parseStream(lines);

  var count = 0;

  await for (final entry in entries) {
    count++;
  }

  print('parseStream() : entries $count');
}
