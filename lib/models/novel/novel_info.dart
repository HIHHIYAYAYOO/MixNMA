import 'package:xml/xml.dart';

import 'package:mixnma/api/novel/wenku8_api.dart';

class Novel {
  final int aid;
  String? title;
  String? author;
  String? bookStatus;
  int? totalHitsCount;
  int? pushCount;
  int? favCount;
  DateTime? lastUpdate;
  List<String>? tags;

  Novel({
    required this.aid,
    this.title,
    this.author,
    this.bookStatus,
    this.totalHitsCount,
    this.pushCount,
    this.favCount,
    this.lastUpdate,
    this.tags,
  });

  static Novel fromXml(XmlElement xml) {
    final aid = int.parse(xml.getAttribute("aid")!);
    final newNovel = Novel(aid: aid);

    final Map<String, Function(XmlElement)> attributeMap = {
      'Title': (data) => newNovel.title = data.innerText,
      'Author': (data) => newNovel.author = data.getAttribute('value')!,
      'BookStatus': (data) => newNovel.bookStatus = data.getAttribute('value')!,
      'TotalHitsCount': (data) => newNovel.totalHitsCount = int.parse(data.getAttribute('value')!),
      'PushCount': (data) => newNovel.pushCount = int.parse(data.getAttribute('value')!),
      'FavCount': (data) => newNovel.favCount = int.parse(data.getAttribute('value')!),
      'LastUpdate': (data) => newNovel.lastUpdate = DateTime.parse(data.getAttribute('value')!),
      'Tags': (data) => newNovel.tags = data.getAttribute('value')!.split(' '),
    };

    for(var data in xml.childElements) {
      final key = data.getAttribute('name');
      if(key != null && attributeMap.containsKey(key)) {
        attributeMap[key]!(data);
      }
    }

    return newNovel;
  }

  String get coverURL => Wenku8API.getCoverURL(aid);
}