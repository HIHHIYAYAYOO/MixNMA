class Comic {
  final String? pathword;
  String? name;
  String? cover;
  int? popular;
  DateTime? lastUpdate;

  Comic({
    this.pathword,
    this.name,
    this.cover,
    this.popular,
    this.lastUpdate,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      pathword: json['path_word'],
      name: json['name'],
      cover: json['cover'],
      popular: json['popular'],
      lastUpdate: json['datetime_updated'] != null 
          ? DateTime.parse(json['datetime_updated']) 
          : null,
    );
  }
}

class ComicFullInfo {
  final String? pathword;
  String? name;
  String? status;
  List<String>? author;
  List<String>? theme;
  String? brief;
  DateTime? lastUpdate;
  String? cover;
  String? lastChapter;
  int? popular;

  ComicFullInfo({
    this.pathword,
    this.name,
    this.status,
    this.author,
    this.theme,
    this.brief,
    this.lastUpdate,
    this.cover,
    this.lastChapter,
    this.popular,
  });

factory ComicFullInfo.fromJson(Map<String, dynamic> json) {
    return ComicFullInfo(
      pathword: json['path_word'],
      name: json['name'],
      status: json['status']['display'],
      author: (json['author'] as List<dynamic>).map((author) => author['name'] as String).toList(),
      theme: (json['theme'] as List<dynamic>).map((theme) => theme['name'] as String).toList(),
      brief: json['brief'],
      lastUpdate: json['datetime_updated'] != null 
          ? DateTime.parse(json['datetime_updated']) 
          : null,
      cover: json['cover'],
      lastChapter: json['last_chapter']['name'],
      popular: json['popular'],
    );
  }
}

class ComicChapter {
  final String? pathword;
  final String? uuid;
  String? name;
  String? dateTimeCreated;

  ComicChapter({
    this.pathword,
    this.uuid,
    this.name,
    this.dateTimeCreated,
  });

  factory ComicChapter.fromJson(Map<String, dynamic> json) {
    return ComicChapter(
      pathword: json['comic_path_word'],
      uuid: json['uuid'],
      name: json['name'],
      dateTimeCreated: json['datetime_created'],
    );
  }
}

class ComicChapterData {
  final String? comicName;
  final String? chapterName;
  String? prevUuid;
  String? nextUuid;
  List<String>? chapterContents;

  ComicChapterData({
    this.comicName,
    this.chapterName,
    this.prevUuid,
    this.nextUuid,
    this.chapterContents,
  });

  factory ComicChapterData.fromJson(Map<String, dynamic> json) {
  // 取得 chapterContents 和 words
  List<dynamic> contents = json['chapter']['contents'];
  List<int> words = List<int>.from(json['chapter']['words']);

  // 配對並排序
  List<MapEntry<int, String>> contentsWithWords = List.generate(
    contents.length,
    (i) => MapEntry(words[i], contents[i]['url']),
  );

  // 根據 words 的數值排序並提取排序後的 chapterContents
  List<String> sortedChapterContents = (contentsWithWords
    ..sort((a, b) => a.key.compareTo(b.key)))
    .map((entry) => entry.value)
    .toList();

    return ComicChapterData(
      comicName: json['comic']['name'],
      chapterName: json['chapter']['name'],
      prevUuid: json['chapter']['prev'],
      nextUuid: json['chapter']['next'],
      chapterContents: sortedChapterContents,
    );
  }
}

