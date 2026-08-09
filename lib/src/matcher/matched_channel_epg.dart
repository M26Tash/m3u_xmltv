import 'package:equatable/equatable.dart';
import 'package:m3u_xmltv/src/models/epg_channel_model.dart';
import 'package:m3u_xmltv/src/models/epg_program_model.dart';
import 'package:m3u_xmltv/src/models/m3u_entry.dart';

class MatchedChannelEpg extends Equatable {
  final M3uEntry m3uChannel;
  final EpgChannelModel? epgChannel;
  final List<EpgProgramModel> programs;

  const MatchedChannelEpg({
    required this.m3uChannel,
    this.epgChannel,
    this.programs = const [],
  });

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
            now.isBefore(start.add(const Duration(hours: 2)))) {
          return program;
        }
      }
    }
    return null;
  }

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
  List<Object?> get props => [m3uChannel, epgChannel, programs];
}
