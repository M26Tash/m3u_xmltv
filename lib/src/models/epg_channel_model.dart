import 'package:equatable/equatable.dart';

class EpgChannelModel extends Equatable {
  final String id;
  final List<String> displayNames;
  final String? iconUrl;
  final String? channelUrl;

  String get name => displayNames.isNotEmpty ? displayNames.first : id;

  @override
  List<Object?> get props => [
    id,
    displayNames,
    iconUrl,
    channelUrl,
  ];

  @override
  bool get stringify => true;

  const EpgChannelModel({
    required this.id,
    required this.displayNames,
    this.iconUrl,
    this.channelUrl,
  });

  EpgChannelModel copyWith({
    String? id,
    List<String>? displayNames,
    String? iconUrl,
    String? channelUrl,
  }) {
    return EpgChannelModel(
      id: id ?? this.id,
      displayNames: displayNames ?? this.displayNames,
      iconUrl: iconUrl ?? this.iconUrl,
      channelUrl: channelUrl ?? this.channelUrl,
    );
  }
}
