import 'package:equatable/equatable.dart';
import 'package:m3u_xmltv/src/models/m3u_entry.dart';

class M3uPlaylist extends Equatable {
  final List<M3uEntry> entries;
  final List<String> epgUrls;

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    entries,
    epgUrls,
  ];

  const M3uPlaylist({
    required this.entries,
    this.epgUrls = const [],
  });

  M3uPlaylist copyWith({
    List<M3uEntry>? entries,
    List<String>? epgUrls,
  }) {
    return M3uPlaylist(
      entries: entries ?? this.entries,
      epgUrls: epgUrls ?? this.epgUrls,
    );
  }
}
