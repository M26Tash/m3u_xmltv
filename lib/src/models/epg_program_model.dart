import 'package:equatable/equatable.dart';

/// Represents a programme entry from an XMLTV EPG source.
class EpgProgramModel extends Equatable {
  /// The date and time when the programme starts.
  final DateTime startTime;

  /// The date and time when the programme ends, if available.
  final DateTime? endTime;

  /// The ID of the channel broadcasting the programme.
  final String channelId;

  /// The title of the programme.
  final String? title;

  /// The subtitle of the programme.
  final String? subTitle;

  /// A description of the programme.
  final String? description;

  /// The presenter or presenters of the programme.
  final String? presenter;

  /// The guest or guests appearing in the programme.
  final String? guest;

  /// The original date associated with the programme.
  final String? date;

  /// The category of the programme.
  final String? category;

  /// The language of the programme.
  final String? language;

  /// The duration of the programme in minutes.
  final int? length;

  /// URL of the programme icon, if provided by the EPG source.
  final String? iconUrl;

  /// The country associated with the programme.
  final String? country;

  /// The episode number or identifier.
  final String? episodeNum;

  /// The programme's content rating.
  final String? ratingValue;

  /// Whether the programme is currently being broadcast.
  ///
  /// Returns `true` when the current time is between [startTime] and
  /// [endTime]. Returns `false` when [endTime] is not available.
  bool get isLive {
    final now = DateTime.now();
    if (endTime == null) return false;
    return now.isAfter(startTime) && now.isBefore(endTime!);
  }

  const EpgProgramModel({
    required this.startTime,
    required this.channelId,
    this.endTime,
    this.title,
    this.subTitle,
    this.description,
    this.presenter,
    this.guest,
    this.date,
    this.category,
    this.language,
    this.length,
    this.iconUrl,
    this.country,
    this.episodeNum,
    this.ratingValue,
  });

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    startTime,
    endTime,
    channelId,
    title,
    subTitle,
    description,
    presenter,
    guest,
    date,
    category,
    language,
    length,
    iconUrl,
    country,
    episodeNum,
    ratingValue,
  ];

  EpgProgramModel copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? channelId,
    String? title,
    String? subTitle,
    String? description,
    String? presenter,
    String? guest,
    String? date,
    String? category,
    String? language,
    int? length,
    String? iconUrl,
    String? country,
    String? episodeNum,
    String? ratingValue,
  }) {
    return EpgProgramModel(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      channelId: channelId ?? this.channelId,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      description: description ?? this.description,
      presenter: presenter ?? this.presenter,
      guest: guest ?? this.guest,
      date: date ?? this.date,
      category: category ?? this.category,
      language: language ?? this.language,
      length: length ?? this.length,
      iconUrl: iconUrl ?? this.iconUrl,
      country: country ?? this.country,
      episodeNum: episodeNum ?? this.episodeNum,
      ratingValue: ratingValue ?? this.ratingValue,
    );
  }
}
