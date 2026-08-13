import 'epg_channel_model.dart';
import 'epg_program_model.dart';

sealed class XmltvEntity {
  const XmltvEntity();
}

final class XmltvChannelEntity extends XmltvEntity {
  final EpgChannelModel channel;

  const XmltvChannelEntity(this.channel);
}

final class XmltvProgramEntity extends XmltvEntity {
  final EpgProgramModel program;

  const XmltvProgramEntity(this.program);
}
