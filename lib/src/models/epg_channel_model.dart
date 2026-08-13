import 'package:equatable/equatable.dart';

/// Represents a channel defined in an XMLTV EPG source.
class EpgChannelModel extends Equatable {
  /// The unique identifier of the channel.
  final String id;

  /// Names associated with the channel.
  ///
  /// The first name is returned by [name].
  final List<String> displayNames;

  /// URL of the channel icon, if provided by the EPG source.
  final String? iconUrl;

  /// URL associated with the channel, if provided by the EPG source.
  final String? channelUrl;

  /// Returns the first display name, or [id] when no display name is available.
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
