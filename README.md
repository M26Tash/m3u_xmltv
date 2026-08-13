# m3u_xmltv

A Dart package for parsing M3U playlists and XMLTV EPG files and matching
channels between them.

## Contents

- [Getting Started](#getting-started)
- [Requirements](#requirements)
- [M3U](#m3u)
- [M3U Use Cases](#m3u-use-cases)
- [XMLTV](#xmltv)
- [XMLTV Use Cases](#xmltv-use-cases)
- [Large XMLTV Files](#large-xmltv-files)
- [Matching M3U and XMLTV](#matching-m3u-and-xmltv)
- [Supported M3U Data](#supported-m3u-data)
- [Supported XMLTV Data](#supported-xmltv-data)
- [What This Package Does Not Do](#what-this-package-does-not-do)
- [Upcoming](#upcoming)
- [API Overview](#api-overview)
- [License](#license)

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
  m3u_xmltv: ^0.2.0
```

Import the package:

```dart
import 'package:m3u_xmltv/m3u_xmltv.dart';
```

## Requirements

- Dart SDK 3.12.2 or later

## M3U
`M3uParser` has three methods depending on how the playlist data is available.

### Parse a string
Use `parseString()` when the complete playlist is already available as a
string.

```dart
final playlist = M3uParser.parseString(content);

print('Channels: ${playlist.entries.length}');

for (final entry in playlist.entries) {
  print('${entry.title} -> ${entry.url}');
}
```

The result is an `M3uPlaylist`, which contains the parsed entries and EPG URLs
from the playlist header.

### Parse bytes
If the playlist is already available as bytes:
```dart
final playlist = M3uParser.parseBytes(bytes);

print('Channels: ${playlist.entries.length}');
```
UTF-8 is used by default. A different encoding can be provided if necessary:
```dart
final playlist = M3uParser.parseBytes(
  bytes,
  encoding: latin1,
);
```
### Parse a stream
For large playlists, or when the data is already available as a stream, use
`parseStream()`.
```dart
await for (final entry in M3uParser.parseStream(lines)) {
  print('${entry.title} -> ${entry.url}');
}
```
`parseStream()` returns each `M3uEntry` as soon as it has been parsed instead
of first building an `M3uPlaylist`.

The parser expects a `Stream<String>`, so converting bytes to lines is the
responsibility of the application.
## M3U Use Cases
There are 3 use cases of how to use `M3uParser` in real-case scenarios

### M3U from a file
For example, in a Dart or Flutter application with access to the local
filesystem:
```dart
import 'dart:convert';
import 'dart:io';

import 'package:m3u_xmltv/m3u_xmltv.dart';

final file = File('playlist.m3u');

final lines = file
    .openRead()
    .transform(utf8.decoder)
    .transform(const LineSplitter());

await for (final entry in M3uParser.parseStream(lines)) {
  print(entry.title);
}
```
This is intentionally not part of `M3uParser` itself. The parser only deals
with the data it receives.

### M3U over HTTP
The same approach can be used with an HTTP response.

For example, using the `http` package:
```dart
import 'package:http/http.dart' as http;
import 'package:m3u_xmltv/m3u_xmltv.dart';

final client = http.Client();

try {
  final request = http.Request(
    'GET',
    Uri.parse('https://example.com/playlist.m3u'),
  );

  final response = await client.send(request);

  final lines = response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  await for (final entry in M3uParser.parseStream(lines)) {
    print(entry.title);
  }
} finally {
  client.close();
}
```

If the playlist is small and you don't need streaming, `http.get()` and
`parseBytes()` can also be used:

```dart
final response = await http.get(
  Uri.parse('https://example.com/playlist.m3u'),
);

final playlist = M3uParser.parseBytes(response.bodyBytes);
```

### M3U over WebSocket
`parseStream()` can consume any `Stream<String>`, including data received from
a WebSocket.
```dart
await for (final entry in M3uParser.parseStream(webSocketStream)) {
  print(entry.title);
}
```
The package does not create or manage the WebSocket connection. It only parses
the stream provided by the application.

## XMLTV
`XmltvParser` has three methods depending on how the playlist data is available.

* `parseString()`
* `parseBytes()`
* `parseStream()`

The first two return a complete `XmltvModel`. The streaming API returns
individual XMLTV entities as they are parsed.

### Parse a string

```dart
final parser = XmltvParser();

final epg = await parser.parseString(content);

print('Channels: ${epg.channels.length}');
print('Programs: ${epg.programs.length}');
```
The returned `XmltvModel` contains:
```dart
epg.channels
epg.programs
```

### Parse bytes
```dart
final parser = XmltvParser();

final epg = await parser.parseBytes(bytes);

print('Channels: ${epg.channels.length}');
print('Programs: ${epg.programs.length}');
```
### Parse a stream

For large XMLTV files, use `parseStream()`.

```dart
final parser = XmltvParser();

await for (final entity in parser.parseStream(byteStream)) {
  switch (entity) {
    case XmltvChannelEntity(:final channel):
      print('Channel: ${channel.name}');

    case XmltvProgramEntity(:final program):
      print('Program: ${program.title}');
  }
}
```
The stream produces two types of entities:

```dart
XmltvChannelEntity
XmltvProgramEntity
```
This means the complete XMLTV document does not have to be loaded before
processing starts.

This is especially useful for large EPG files.

## XMLTV Use Cases
There are 3 use cases of how to use `XmltvParser` in real-case scenarios

### XMLTV from a file

```dart
import 'dart:io';

import 'package:m3u_xmltv/m3u_xmltv.dart';

final parser = XmltvParser();
final byteStream = File('epg.xml').openRead();

await for (final entity in parser.parseStream(byteStream)) {
  switch (entity) {
    case XmltvChannelEntity(:final channel):
      print(channel.name);

    case XmltvProgramEntity(:final program):
      print(program.title);
  }
}
```

### XMLTV over HTTP

Using the `http` package:

```dart
import 'package:http/http.dart' as http;

import 'package:m3u_xmltv/m3u_xmltv.dart';

final client = http.Client();

try {
  final request = http.Request(
    'GET',
    Uri.parse('https://example.com/epg.xml'),
  );

  final response = await client.send(request);

  final parser = XmltvParser();

  await for (final entity in parser.parseStream(response.stream)) {
    switch (entity) {
      case XmltvChannelEntity(:final channel):
        print('Channel: ${channel.name}');

      case XmltvProgramEntity(:final program):
        print('Program: ${program.title}');
    }
  }
} finally {
  client.close();
}
```

For large EPG files, this is preferable to first downloading the entire
response into a `List<int>` and then calling `parseBytes()`.

### XMLTV over WebSocket

`XmltvParser.parseStream()` accepts a `Stream<List<int>>`, so it can also be
used with a byte stream received from another source.

```dart
await for (final entity in parser.parseStream(byteStream)) {
  switch (entity) {
    case XmltvChannelEntity(:final channel):
      // Process channel.

    case XmltvProgramEntity(:final program):
      // Process programme.
  }
}
```

The package does not create or manage the connection.


## Large XMLTV files
XMLTV files can become quite large. In testing with real XMLTV data, the
streaming parser was tested with files of approximately 50 MB and 150 MB.


<table>
  <tr>
    <th align="left">File Size</th>
    <th align="right">Channels</th>
    <th align="right">Programs</th>
    <th align="right">Parsing Time</th>
  </tr>
  <tr>
    <td><b>~50 MB</b></td>
    <td align="right"><code>3,748</code></td>
    <td align="right"><code>221,388</code></td>
    <td align="right"><b>~6.3 s</b></td>
  </tr>
  <tr>
    <td><b>~150 MB</b></td>
    <td align="right"><code>3,748</code></td>
    <td align="right"><code>450,978</code></td>
    <td align="right"><b> ~12.1 s</b></td>
  </tr>
</table>

<details>
<summary><b>⚠️ A note on performance results</b></summary>

These are reference measurements only. Results will vary depending on the device, CPU, Dart version, XML structure, and other factors.
</details>

For large files, prefer:

```dart
XmltvParser().parseStream(...)
```

when you don't need the complete `XmltvModel`.

For example, instead of collecting hundreds of thousands of programmes:

```dart
await for (final entity in parser.parseStream(byteStream)) {
  switch (entity) {
    case XmltvChannelEntity(:final channel):
      await saveChannel(channel);

    case XmltvProgramEntity(:final program):
      await saveProgram(program);
  }
}
```

This allows the application to decide how the parsed data should be stored or
processed.


## Matching M3U and XMLTV

When the complete M3U and XMLTV models are available, EpgMatcher can be used
to match channels and their programmes.

```dart
final playlist = M3uParser.parseString(m3uContent);
final epg = await XmltvParser().parseString(xmltvContent);

final matcher = EpgMatcher();

final matchedChannels = matcher.match(
  m3uChannels: playlist.entries,
  xmltvModel: epg,
);
```

Matching is attempted in this order:

1. M3U `tvg-id` → XMLTV channel ID
1. M3U `tvg-name` → XMLTV display name
1. M3U channel title → XMLTV display name

Example:
```dart
for (final match in matchedChannels) {
  print('Channel: ${match.m3uChannel.title}');
  print('EPG: ${match.epgChannel?.name ?? 'Not found'}');
  print('Now: ${match.currentProgram?.title ?? 'No programme'}');
  print('Next: ${match.nextProgram?.title ?? 'No programme'}');
}
```

## Supported M3U data

The parser currently handles commonly used M3U metadata including:

* `EXTINF`
* `EXTGRP`
* `tvg-id`
* `tvg-name`
* `tvg-logo`
* `group-title`
* Channel numbers
* EPG URLs (`x-tvg-url` and `url-tvg`)
* `EXTVLCOPT`
* `KODIPROP`
* Catch-up attributes
* HTTP headers
* Other attributes exposed through `rawAttributes`

## Supported XMLTV data

The parser currently handles:

* Channels
* Multiple channel display names
* Channel icons
* Channel URLs
* Programme start and end times
* Titles
* Subtitles
* Descriptions
* Credits
* Categories
* Languages
* Countries
* Episode numbers
* Ratings
* Programme duration

Malformed individual entries are skipped when possible so that one invalid
channel or programme does not prevent the rest of the document from being
processed.

## What this package does not do

This package is a parser. It does not act as a media player or a network
client.

For example, it can parse:

```dart
M3U playlist
    ↓
M3uEntry
    ↓
your application
    ↓
HLS / MPEG-TS / other player
```

It does not play the stream.

The following are currently outside the scope of the package:

* HLS/M3U8 playback
* Video or audio playback
* Downloading media streams
* Creating HTTP or WebSocket connections
* Automatically downloading EPG URLs from an M3U playlist
* EPG caching or database storage
* Streaming M3U/XMLTV matching

M3U playlists containing HLS/M3U8 URLs can still be parsed normally. The
package simply treats the stream URL as data.

## Upcoming

Possible future improvements include:

* Streaming M3U/XMLTV matching
* Better support for different M3U variants
* Additional XMLTV elements
* More real-world playlist and EPG compatibility tests
* Further performance improvements
* Helpers for working with large EPG datasets
* Compitability with `.xml.gz` and `.xml.tar.gz`

## API Overview

| Method | Input | Returns | Use When |
| :--- | :--- | :--- | :--- |
| `M3uParser.parseString()` | `String` | `M3uPlaylist` | You already have the complete playlist |
| `M3uParser.parseBytes()` | `List<int>` | `M3uPlaylist` | You already have the complete bytes |
| `M3uParser.parseStream()` | `Stream<String>` | `Stream<M3uEntry>` | You want incremental parsing |
| `XmltvParser.parseString()` | `String` | `XmltvModel` | You need the complete EPG model |
| `XmltvParser.parseBytes()` | `List<int>` | `XmltvModel` | You already have the complete bytes |
| `XmltvParser.parseStream()` | `Stream<List<int>>` | `Stream<XmltvEntity>` | You want incremental parsing |


## License

This project is licensed under the MIT License. See the `LICENSE` file for details.