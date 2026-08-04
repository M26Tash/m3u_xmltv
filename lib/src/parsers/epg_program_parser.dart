import 'package:m3u_xmltv/src/models/epg_program_model.dart';
import 'package:m3u_xmltv/src/utils/formatters/xmltv_time_formatter.dart';
import 'package:xml/xml.dart';

class EpgProgramParser {
  final XmltvTimeFormatter _timeFormatter;

  EpgProgramParser({XmltvTimeFormatter? timeFormatter})
    : _timeFormatter = timeFormatter ?? XmltvTimeFormatter();

  EpgProgramModel? parse(XmlElement element) {
    try {
      final channelId = element.getAttribute('channel');
      final startStr = element.getAttribute('start');

      if (channelId == null || startStr == null) return null;

      final startTime = _timeFormatter.parse(time: startStr);
      if (startTime == null) return null;

      final stopStr = element.getAttribute('stop');
      final endTime = stopStr != null
          ? _timeFormatter.parse(time: stopStr)
          : null;

      final title = _getText(element, 'title');
      final subTitle = _getText(element, 'sub-title');
      final description = _getText(element, 'desc');

      final creditsNode = element.findElements('credits').firstOrNull;
      final presenter = creditsNode != null
          ? _getText(creditsNode, 'presenter')
          : null;
      final guest = creditsNode != null ? _getText(creditsNode, 'guest') : null;

      final category = _getText(element, 'category');
      final date = _getText(element, 'date');
      final language =
          element.findElements('language').firstOrNull?.innerText.trim() ??
          element.findElements('title').firstOrNull?.getAttribute('lang');
      final country = _getText(element, 'country');

      final episodeNum = _getText(element, 'episode-num');
      final ratingNode = element.findElements('rating').firstOrNull;
      final ratingValue = ratingNode != null
          ? _getText(ratingNode, 'value')
          : null;

      final iconElement = element.findElements('icon').firstOrNull;
      final iconUrl = iconElement?.getAttribute('src');

      int? length;
      if (endTime != null) {
        length = endTime.difference(startTime).inMinutes;
      } else {
        final lengthStr = _getText(element, 'length');
        if (lengthStr != null) {
          length = int.tryParse(lengthStr);
        }
      }

      return EpgProgramModel(
        startTime: startTime,
        endTime: endTime,
        channelId: channelId,
        title: title,
        subTitle: subTitle,
        description: description,
        presenter: presenter,
        guest: guest,
        date: date,
        category: category,
        language: language,
        length: length,
        iconUrl: iconUrl,
        country: country,
        episodeNum: episodeNum,
        ratingValue: ratingValue,
      );
    } catch (_) {
      return null;
    }
  }

  String? _getText(XmlElement parent, String tagName) {
    try {
      final node = parent.findElements(tagName).firstOrNull;
      final text = node?.innerText.trim();
      return (text != null && text.isNotEmpty) ? text : null;
    } catch (_) {
      return null;
    }
  }
}
