import 'package:equatable/equatable.dart';

class EpgProgramModel extends Equatable {
  final DateTime startTime;
  final DateTime? endTime;
  final String channelId;
  final String? title;
  final String? subTitle;
  final String? description;
  final String? presenter;
  final String? guest;
  final String? date;
  final String? category;
  final String? language;
  final int? length;
  final String? iconUrl;
  final String? country;
  final String? episodeNum;
  final String? ratingValue;

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
