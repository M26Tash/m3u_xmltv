# m3u_xmltv

A fast parser for M3U playlists and XMLTV EPG files with built-in channel matching.

## Features

- 🚀 Parse M3U playlists from strings or streams.
- 📺 Efficiently parse XMLTV EPG files.
- 🔗 Match M3U channels with XMLTV programmes using `EpgMatcher`.

## Getting Started

Add the package to your project.

### Dart

```sh
dart pub add m3u_xmltv
```

### Flutter

```sh
flutter pub add m3u_xmltv
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  m3u_xmltv: ^0.1.0
```

Import the package:

```dart
import 'package:m3u_xmltv/m3u_xmltv.dart';
```

---

## Usage

### Parse an M3U playlist

```dart
import 'package:m3u_xmltv/m3u_xmltv.dart';

final playlist = M3uParser.parseString(m3uContent);

for (final channel in playlist.entries) {
  print('${channel.title} -> ${channel.url}');
}
```

### Parse an XMLTV EPG

```dart
import 'dart:io';
import 'package:m3u_xmltv/m3u_xmltv.dart';

final byteStream = File('epg.xml').openRead();

final epg = await XmltvParser().parseStream(byteStream);

for (final channel in epg.channels) {
  print(channel.id);
}
```

### Match M3U channels with EPG

```dart
import 'package:m3u_xmltv/m3u_xmltv.dart';

final matcher = EpgMatcher();

final matchedChannels = matcher.match(
  m3uChannels: playlist.entries,
  xmltvModel: epgData,
);

for (final match in matchedChannels) {
  print('Channel: ${match.m3uChannel.title}');
  print('Now: ${match.currentProgram?.title ?? 'No programme'}');
}
```

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.