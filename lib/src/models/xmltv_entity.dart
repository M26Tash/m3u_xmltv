import 'epg_channel_model.dart';
import 'epg_program_model.dart';

/// Represents an item produced by the incremental XMLTV parser.
///
/// An [XmltvEntity] is either an [XmltvChannelEntity] or an
/// [XmltvProgramEntity].
sealed class XmltvEntity {
  /// Creates an [XmltvEntity].
  const XmltvEntity();
}

/// An XMLTV entity containing a parsed channel.
final class XmltvChannelEntity extends XmltvEntity {
  /// The parsed XMLTV channel.
  final EpgChannelModel channel;

  /// Creates an [XmltvChannelEntity].
  const XmltvChannelEntity(
    this.channel,
  );
}

/// An XMLTV entity containing a parsed programme.
final class XmltvProgramEntity extends XmltvEntity {
  /// The parsed XMLTV programme.
  final EpgProgramModel program;

  /// Creates an [XmltvProgramEntity].
  const XmltvProgramEntity(
    this.program,
  );
}
