import 'package:m3u_xmltv/src/matcher/matched_channel_epg.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';
import 'package:m3u_xmltv/src/models/m3u_entry.dart';
import 'package:m3u_xmltv/src/models/xmltv_model.dart';

/// Matches M3U playlist entries with channels and programmes from an XMLTV
/// EPG source.
///
/// Matching is performed in the following order:
///
/// 1. M3U `tvg-id` against the XMLTV channel ID.
/// 2. M3U `tvg-name` against XMLTV channel display names.
/// 3. M3U entry title against XMLTV channel display names.
///
/// Channel names are normalized before name-based matching.
class EpgMatcher {
  /// Matches M3U channels with channels and programmes from an [XmltvModel].
  ///
  /// Returns one [MatchedChannelEpg] for every entry in [m3uChannels].
  ///
  /// When no matching EPG channel is found, the resulting
  /// [MatchedChannelEpg] contains a `null` [MatchedChannelEpg.epgChannel]
  /// and an empty list of programmes.
  ///
  /// XMLTV programmes belonging to each matched channel are sorted by
  /// their start time.
  List<MatchedChannelEpg> match({
    required List<M3uEntry> m3uChannels,
    required XmltvModel xmltvModel,
  }) {
    final channelById = <String, EpgChannelModel>{};
    final channelByName = <String, EpgChannelModel>{};

    for (final channel in xmltvModel.channels) {
      channelById[channel.id] = channel;
      for (final name in channel.displayNames) {
        final normalized = _normalize(name);
        if (normalized.isNotEmpty) {
          channelByName[normalized] = channel;
        }
      }
    }

    final programsByChannelId = <String, List<EpgProgramModel>>{};
    for (final program in xmltvModel.programs) {
      programsByChannelId.putIfAbsent(program.channelId, () => []).add(program);
    }

    for (final list in programsByChannelId.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    final results = <MatchedChannelEpg>[];

    for (final m3uChannel in m3uChannels) {
      EpgChannelModel? matchedEpgChannel;

      if (m3uChannel.tvgId != null && m3uChannel.tvgId!.isNotEmpty) {
        matchedEpgChannel = channelById[m3uChannel.tvgId];
      }

      if (matchedEpgChannel == null &&
          m3uChannel.tvgName != null &&
          m3uChannel.tvgName!.isNotEmpty) {
        final normalizedTvgName = _normalize(m3uChannel.tvgName!);
        matchedEpgChannel = channelByName[normalizedTvgName];
      }

      if (matchedEpgChannel == null && m3uChannel.title.isNotEmpty) {
        final normalizedTitle = _normalize(m3uChannel.title);
        matchedEpgChannel = channelByName[normalizedTitle];
      }

      List<EpgProgramModel> channelPrograms = const [];
      if (matchedEpgChannel != null) {
        channelPrograms = programsByChannelId[matchedEpgChannel.id] ?? const [];
      }

      results.add(
        MatchedChannelEpg(
          m3uChannel: m3uChannel,
          epgChannel: matchedEpgChannel,
          programs: channelPrograms,
        ),
      );
    }

    return results;
  }

  /// Normalizes a channel name for name-based matching.
  ///
  /// Removes common quality and format indicators such as `HD`, `4K`,
  /// `FHD`, and `50fps`, and removes non-alphanumeric characters.
  String _normalize(String text) {
    var cleaned = text.toLowerCase();

    cleaned = cleaned.replaceAll(
      RegExp(r'\((hd|4k|50fps|orig|fhd|sd|50hz)\)'),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\b(hd|4k|50fps|orig|fhd|sd)\b'), '');

    cleaned = cleaned.replaceAll(RegExp(r'[^a-zа-я0-9]'), '');

    return cleaned.trim();
  }
}
