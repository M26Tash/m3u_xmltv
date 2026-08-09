import 'package:m3u_xmltv/src/models/m3u_entry.dart';

abstract final class M3uMapper {
  static final RegExp _attributeRegExp = RegExp(
    r'([\w-]+)=(?:"([^"]*)"|([^\s"]+))',
  );

  static final RegExp _durationRegExp = RegExp(r'#EXTINF:\s*(-?\d+)');

  static M3uEntry fromLines({
    required String extInfLine,
    required String url,
    String? extGrpGroup,
    Map<String, String> httpHeaders = const {},
    Map<String, String> kodiProps = const {},
  }) {
    final commaIndex = extInfLine.indexOf(',');
    final metadataPart = commaIndex != -1
        ? extInfLine.substring(0, commaIndex)
        : extInfLine;

    final title = commaIndex != -1
        ? extInfLine.substring(commaIndex + 1).trim()
        : '';

    final durationMatch = _durationRegExp.firstMatch(metadataPart);
    final duration = int.tryParse(durationMatch?.group(1) ?? '-1') ?? -1;

    final attributes = <String, String>{};
    for (final match in _attributeRegExp.allMatches(metadataPart)) {
      final key = match.group(1);
      final value = match.group(2) ?? match.group(3);
      if (key != null && value != null) {
        attributes[key] = value;
      }
    }

    final tvgId = attributes['tvg-id'];
    final tvgName = attributes['tvg-name'];
    final tvgLogo = attributes['tvg-logo'];

    final group = attributes['group-title'] ?? extGrpGroup;

    final channelNumber = int.tryParse(
      attributes['tvg-chno'] ?? attributes['channel-id'] ?? '',
    );
    final epgShift = int.tryParse(attributes['tvg-shift'] ?? '');
    final country = attributes['tvg-country'];
    final language = attributes['tvg-language'];

    final isRadio = attributes['radio']?.toLowerCase() == 'true';
    final parentCode = attributes['parent-code'];
    final aspectRatio = attributes['aspect-ratio'];

    final catchupType = attributes['catchup'];
    final catchupDays = int.tryParse(attributes['catchup-days'] ?? '');
    final catchupSource = attributes['catchup-source'];
    final hasCatchup =
        attributes['tvg-rec'] == '1' ||
        catchupType != null ||
        catchupDays != null ||
        catchupSource != null;

    return M3uEntry(
      title: title,
      url: url.trim(),
      duration: duration,
      channelNumber: channelNumber,
      tvgId: tvgId,
      tvgName: tvgName,
      tvgLogo: tvgLogo,
      group: group,
      epgShift: epgShift,
      country: country,
      language: language,
      isRadio: isRadio,
      parentCode: parentCode,
      aspectRatio: aspectRatio,
      hasCatchup: hasCatchup,
      catchupType: catchupType,
      catchupDays: catchupDays,
      catchupSource: catchupSource,
      httpHeaders: httpHeaders,
      kodiProps: kodiProps,
      rawAttributes: attributes,
    );
  }
}
