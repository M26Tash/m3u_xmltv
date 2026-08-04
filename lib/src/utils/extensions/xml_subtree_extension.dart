import 'dart:async';
import 'package:xml/xml_events.dart';

extension XmlSubtreeEventsExtension on Stream<XmlEvent> {
  Stream<List<XmlEvent>> selectSubtreeEvents(
    bool Function(XmlStartElementEvent event) predicate,
  ) async* {
    List<XmlEvent>? currentSubtree;
    int depth = 0;

    await for (final event in this) {
      if (currentSubtree == null) {
        if (event is XmlStartElementEvent && predicate(event)) {
          if (event.isSelfClosing) {
            yield [event];
          } else {
            currentSubtree = [event];
            depth = 1;
          }
        }
      } else {
        currentSubtree.add(event);

        if (event is XmlStartElementEvent && !event.isSelfClosing) {
          depth++;
        } else if (event is XmlEndElementEvent) {
          depth--;

          if (depth == 0) {
            yield currentSubtree;
            currentSubtree = null;
          }
        }
      }
    }
  }
}
