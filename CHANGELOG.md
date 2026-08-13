# 0.1.0

- Initial release of `m3u_xmltv`.
- Added stream and file parsing for M3U playlists.
- Added stream parser for XMLTV EPG data.
- Added `EpgMatcher` for mapping M3U channels with XMLTV programmes.

## 0.2.0

### Added
- Web-compatible parser API.
- Incremental XMLTV parsing through `XmltvParser.parseStream()`.
- `XmltvEntity` for streaming XMLTV channels and programmes.

### Changed
- Redesigned `M3uParser` API around `parseString()`, `parseBytes()`, and `parseStream()`.
- Redesigned `XmltvParser` API around `parseString()`, `parseBytes()`, and `parseStream()`.
- XMLTV parsing now processes the input incrementally instead of loading the entire document into memory.
- Improved public API documentation.
- Renamed `M3uModel` to `M3uEntry`.

### Removed
- Platform-specific `dart:io` usage from the core parser API.
- Obsolete XML subtree extension.