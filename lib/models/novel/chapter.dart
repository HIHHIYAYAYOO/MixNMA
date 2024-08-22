import 'package:xml/xml.dart';

class Chapter {
  final int cid;
  final String cdata;

  const Chapter({
    required this.cid,
    required this.cdata,
  });

  static Chapter fromXml(XmlElement xml) {
    final cid = int.parse(xml.getAttribute('cid')!);
    final cdata = xml.innerText.trim(); 

    return Chapter(cid: cid, cdata: cdata);
  }
}