import 'package:equatable/equatable.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';
import 'package:m3u_xmltv/src/models/m3u_entry.dart';

/// Represents an M3U channel together with its matched XMLTV EPG data.
///
/// [epgChannel] is `null` when no matching XMLTV channel was found.
/// [programs] contains the programmes associated with the matched EPG
/// channel.
class MatchedChannelEpg extends Equatable {
  /// The original M3U channel entry.
  final M3uEntry m3uChannel;

  /// The XMLTV channel matched to [m3uChannel], if one was found.
  final EpgChannelModel? epgChannel;

  /// The XMLTV programmes associated with [epgChannel].
  final List<EpgProgramModel> programs;

  const MatchedChannelEpg({
    required this.m3uChannel,
    this.epgChannel,
    this.programs = const [],
  });

  /// Returns the programme that is currently airing.
  ///
  /// Returns `null` when there are no programmes or when no programme
  /// is currently active.
  ///
  /// If a programme has no [EpgProgramModel.endTime], it is considered
  /// current for up to two hours after its [EpgProgramModel.startTime].
  EpgProgramModel? get currentProgram {
    if (programs.isEmpty) return null;
    final now = DateTime.now();

    for (final program in programs) {
      final start = program.startTime;
      final end = program.endTime;

      if (end != null) {
        if (now.isAfter(start) && now.isBefore(end)) {
          return program;
        }
      } else {
        if (now.isAfter(start) &&
            now.isBefore(
              start.add(
                const Duration(hours: 2),
              ),
            )) {
          return program;
        }
      }
    }
    return null;
  }

  /// Returns the programme scheduled immediately after [currentProgram].
  ///
  /// Returns `null` when there is no current programme or when there is
  /// no subsequent programme in the list.
  EpgProgramModel? get nextProgram {
    final current = currentProgram;
    if (current == null || programs.isEmpty) return null;

    final index = programs.indexOf(current);
    if (index != -1 && index + 1 < programs.length) {
      return programs[index + 1];
    }
    return null;
  }

  @override
  List<Object?> get props => [
    m3uChannel,
    epgChannel,
    programs,
  ];
}
