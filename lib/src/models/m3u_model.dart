import 'package:equatable/equatable.dart';

class M3uModel extends Equatable {
  final String title;
  final String url;
  final int duration;
  final int? channelNumber;
  final String? tvgId;
  final String? tvgName;
  final String? tvgLogo;
  final String? group;
  final int? epgShift;
  final String? country;
  final String? language;
  final bool isRadio;
  final String? parentCode;
  final String? aspectRatio;
  final bool hasCatchup;
  final String? catchupType;
  final int? catchupDays;
  final String? catchupSource;
  final Map<String, String> httpHeaders;
  final Map<String, String> kodiProps;
  final Map<String, String> rawAttributes;

  const M3uModel({
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

  M3uModel copyWith({
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
    return M3uModel(
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
