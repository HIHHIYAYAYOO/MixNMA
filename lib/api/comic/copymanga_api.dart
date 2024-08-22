import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mixnma/models/comic/comic_info.dart';

class CopyMangaAPI {
  static const String copyMangaURL = "https://api.copymanga.tv";

  // 取得漫畫列表
  static Future<List<Comic>> getComicList({int page = 0, required String orderingBy}) async {
    final int offset = page * 20;
    final Uri requestUri = Uri.parse("$copyMangaURL/api/v3/comics").replace(
      queryParameters: {
        'offset': offset.toString(),
        'ordering': orderingBy,
      },
    );

    final response = await http.get(requestUri);
    response.headers["content-type"] = "application/json; charset=utf-8";

    final document = json.decode(response.body);
    List<dynamic> comicListJson = document['results']['list'];

    return comicListJson.map((comicDataJson) => Comic.fromJson(comicDataJson)).toList();
  }

  // 取得漫畫資訊
  static Future<ComicFullInfo> getComicInfo(String pathword) async {
    final Uri requestUri = Uri.parse("$copyMangaURL/api/v3/comic2/$pathword").replace(
      queryParameters: {
        'platform': '3',
        '_update': 'true',
      },
    );

    final response = await http.get(requestUri);
    response.headers["content-type"] = "application/json; charset=utf-8";

    final document = json.decode(response.body);
    final comicInfoJson = document['results']['comic'];

    return ComicFullInfo.fromJson(comicInfoJson);
  }

  // 取得漫畫章節列表
  static Future<List<ComicChapter>> getComicChapterList(String pathword) async {
      final Uri requestUri = Uri.parse("$copyMangaURL/api/v3/comic/$pathword/group/default/chapters").replace(
      queryParameters: {
        'limit': '500',
        'offset': '0',
        '_update': 'true',
      },
    );

    final response = await http.get(
      requestUri,
      headers: {
        'platform': '1',
      },
    );

    response.headers["content-type"] = "application/json; charset=utf-8";

    final document = json.decode(response.body);
    List<dynamic> comicChaptersJson = document['results']['list'];

    return comicChaptersJson.map((chapterJson) => ComicChapter.fromJson(chapterJson)).toList();
  }

  // 取得漫畫內容
  static Future<ComicChapterData> getComicPage(String pathword, String uuid) async{
      final Uri requestUri = Uri.parse("$copyMangaURL/api/v3/comic/$pathword/chapter2/$uuid").replace(
      queryParameters: {
        'platform': '3',
        '_update': 'true',
      },
    );

    final response = await http.get(requestUri);
    response.headers["content-type"] = "application/json; charset=utf-8";

    final document = json.decode(response.body);
    final comicChapterDataJson = document['results'];

    return ComicChapterData.fromJson(comicChapterDataJson);
  }
}