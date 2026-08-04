import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:xml/xml.dart';

class EpgChannelParser {
  EpgChannelModel? parse(XmlElement element) {
    final id = element.getAttribute('id');
    if (id == null || id.isEmpty) return null;

    final displayNames = element
        .findElements('display-name')
        .map((e) => e.innerText.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final iconElement = element.findElements('icon').firstOrNull;
    final iconUrl = iconElement?.getAttribute('src');

    final urlElement = element.findElements('url').firstOrNull;
    final url = urlElement?.innerText.trim();

    return EpgChannelModel(
      id: id,
      displayNames: displayNames,
      iconUrl: iconUrl,
      channelUrl: url,
    );
  }
}
