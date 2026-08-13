import 'package:equatable/equatable.dart';

/// Represents a single entry in an M3U playlist.
class M3uEntry extends Equatable {
  /// The display title of the channel or media entry.
  final String title;

  /// The URL of the channel or media stream.
  final String url;

  /// The duration of the entry in seconds.
  ///
  /// A value of `-1` indicates an entry with an unknown or unlimited duration.
  final int duration;

  /// The channel number, if provided by the playlist.
  final int? channelNumber;

  /// The TVG channel ID used to associate the entry with an EPG channel.
  final String? tvgId;

  /// The TVG display name of the channel.
  final String? tvgName;

  /// URL of the channel logo.
  final String? tvgLogo;

  /// The group or category the channel belongs to.
  final String? group;

  /// The EPG time shift in minutes.
  final int? epgShift;

  /// The country associated with the channel.
  final String? country;

  /// The language associated with the channel.
  final String? language;

  /// Whether this entry represents a radio stream.
  final bool isRadio;

  /// The parent channel or group code.
  final String? parentCode;

  /// The aspect ratio of the channel or stream.
  final String? aspectRatio;

  /// Whether catch-up functionality is available for this entry.
  final bool hasCatchup;

  /// The catch-up type, if provided.
  final String? catchupType;

  /// The number of days for which catch-up content is available.
  final int? catchupDays;

  /// The source or URL pattern used for catch-up content.
  final String? catchupSource;

  /// HTTP headers associated with the stream.
  final Map<String, String> httpHeaders;

  /// Kodi properties associated with the entry.
  final Map<String, String> kodiProps;

  /// Additional attributes that were found in the original M3U entry.
  final Map<String, String> rawAttributes;

  const M3uEntry({
    required this.title,
    required this.url,
    this.duration = -1,
    this.channelNumber,
    this.tvgId,
    this.tvgName,
    this.tvgLogo,
    this.group,
    this.epgShift,
    this.country,
    this.language,
    this.isRadio = false,
    this.parentCode,
    this.aspectRatio,
    this.hasCatchup = false,
    this.catchupType,
    this.catchupDays,
    this.catchupSource,
    this.httpHeaders = const {},
    this.kodiProps = const {},
    this.rawAttributes = const {},
  });

  @override
  List<Object?> get props => [
    title,
    url,
    duration,
    channelNumber,
    tvgId,
    tvgName,
    tvgLogo,
    group,
    epgShift,
    country,
    language,
    isRadio,
    parentCode,
    aspectRatio,
    hasCatchup,
    catchupType,
    catchupDays,
    catchupSource,
    httpHeaders,
    kodiProps,
    rawAttributes,
  ];

  @override
  bool get stringify => true;

  M3uEntry copyWith({
    String? title,
    String? url,
    int? duration,
    int? channelNumber,
    String? tvgId,
    String? tvgName,
    String? tvgLogo,
    String? group,
    int? epgShift,
    String? country,
    String? language,
    bool? isRadio,
    String? parentCode,
    String? aspectRatio,
    bool? hasCatchup,
    String? catchupType,
    int? catchupDays,
    String? catchupSource,
    Map<String, String>? httpHeaders,
    Map<String, String>? kodiProps,
    Map<String, String>? rawAttributes,
  }) {
    return M3uEntry(
      title: title ?? this.title,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      channelNumber: channelNumber ?? this.channelNumber,
      tvgId: tvgId ?? this.tvgId,
      tvgName: tvgName ?? this.tvgName,
      tvgLogo: tvgLogo ?? this.tvgLogo,
      group: group ?? this.group,
      epgShift: epgShift ?? this.epgShift,
      country: country ?? this.country,
      language: language ?? this.language,
      isRadio: isRadio ?? this.isRadio,
      parentCode: parentCode ?? this.parentCode,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      hasCatchup: hasCatchup ?? this.hasCatchup,
      catchupType: catchupType ?? this.catchupType,
      catchupDays: catchupDays ?? this.catchupDays,
      catchupSource: catchupSource ?? this.catchupSource,
      httpHeaders: httpHeaders ?? this.httpHeaders,
      kodiProps: kodiProps ?? this.kodiProps,
      rawAttributes: rawAttributes ?? this.rawAttributes,
    );
  }
}
