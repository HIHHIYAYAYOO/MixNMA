import 'package:xml/xml.dart';

import 'package:mixnma/models/novel/chapter.dart';

class Volume {
  final int vid;
  final String cdata;
  final List<Chapter> chapters;

  const Volume({
    required this.vid,
    required this.cdata,
    required this.chapters,
  });

  static Volume fromXml(XmlElement xml) {
    final vid = int.parse(xml.getAttribute('vid')!);
    final cdata = xml.innerText.split("\n").first;
    final chapters = xml.findElements('chapter').map(Chapter.fromXml).toList();

    return Volume(vid: vid, cdata: cdata, chapters: chapters);
  }
}