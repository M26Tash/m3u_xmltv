import 'package:equatable/equatable.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';

class XmltvModel extends Equatable {
  final List<EpgChannelModel> channels;
  final List<EpgProgramModel> programs;

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [channels, programs];

  const XmltvModel({required this.channels, required this.programs});
}
