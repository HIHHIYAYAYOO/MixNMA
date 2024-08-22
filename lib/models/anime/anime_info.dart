class Anime {
  final String? pathword;
  String? name;
  String? cover;
  int? popular;
  DateTime? lastUpdate;
  
  Anime({
    this.pathword,
    this.name,
    this.cover,
    this.popular,
    this.lastUpdate,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
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

class AnimeFullInfo {
  final String? pathword;
  String? name;
  String? cover;
  List<String>? theme;
  String? company;
  DateTime? years;
  DateTime? lastUpdate;
  String? lastChapter;
  int? popular;
  String? brief;

  AnimeFullInfo({
    this.pathword,
    this.name,
    this.cover,
    this.theme,
    this.company,
    this.years,
    this.lastUpdate,
    this.lastChapter,
    this.popular,
    this.brief,
  });

  factory AnimeFullInfo.fromJson(Map<String, dynamic> json) {
    return AnimeFullInfo(
      pathword: json['path_word'],
      name: json['name'],
      cover: json['cover'],
      theme: (json['theme'] as List<dynamic>).map((theme) => theme['name'] as String).toList(),
      company: json['company']['name'],
      years: json['years'] != null 
          ? DateTime.parse(json['years']) 
          : null,
      lastUpdate: json['datetime_updated'] != null 
          ? DateTime.parse(json['datetime_updated']) 
          : null,
      lastChapter: json['last_chapter']['name'],
      popular: json['popular'],
      brief: json['brief'],
    );
  }
}

class AnimeChapter {
  final String? uuid;
  String? name;

  AnimeChapter({
    this.uuid,
    this.name,
  });

  factory AnimeChapter.fromJson(Map<String, dynamic> json) {
    return AnimeChapter(
      uuid: json['uuid'],
      name: json['name'],
    );
  }

}
