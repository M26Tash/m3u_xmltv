import 'dart:convert';
import 'package:m3u_xmltv/m3u_xmltv.dart';

Future<void> main() async {
  const m3uContent = '''
#EXTM3U
#EXTINF:-1 tvg-id="cnn.us" tvg-name="CNN HD" group-title="News",CNN International
http://example.com/stream/cnn.m3u8
  ''';

  const xmltvContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="cnn.us">
    <display-name>CNN HD</display-name>
  </channel>
  <programme channel="cnn.us" start="20260804120000 +0000" stop="20260804130000 +0000">
    <title>Global News Digest</title>
    <desc>Latest updates from around the world.</desc>
  </programme>
</tv>
  ''';

  final xmltvParser = XmltvParser();
  final matcher = EpgMatcher();

  final m3uPlaylist = M3uParser.parseString(m3uContent);

  final byteStream = Stream.value(utf8.encode(xmltvContent));

  final xmltvData = await xmltvParser.parseStream(byteStream);

  final matchedChannels = matcher.match(
    m3uChannels: m3uPlaylist.entries,
    xmltvModel: xmltvData,
  );

  for (final match in matchedChannels) {
    print('Channel: ${match.m3uChannel.title}');
    print('Stream URL: ${match.m3uChannel.url}');
    print('Current programme: ${match.currentProgram?.title ?? 'None'}');
    for (final programme in match.programs) {
      print('  - Title: ${programme.title}');
    }
  }
}
