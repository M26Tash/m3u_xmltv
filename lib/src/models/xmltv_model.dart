import 'package:equatable/equatable.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';

/// Represents the complete parsed data from an XMLTV EPG source.
///
/// Contains the channels and programmes defined in the XMLTV document.
class XmltvModel extends Equatable {
  /// The channels defined in the XMLTV source.
  final List<EpgChannelModel> channels;

  /// The programmes defined in the XMLTV source.
  final List<EpgProgramModel> programs;

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    channels,
    programs,
  ];

  const XmltvModel({
    required this.channels,
    required this.programs,
  });
}
