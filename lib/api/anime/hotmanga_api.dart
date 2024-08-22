import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:mixnma/models/anime/anime_info.dart';

class HotMangaAPI {
  static const String hotMangaURL = "https://mapi.hotmangasd.com";

  // 取得動漫列表
  static Future<List<Anime>> getAnimeList({int page = 0, required String orderingBy}) async {
    final int offset = page * 20;

    final Uri requestUri = Uri.parse("$hotMangaURL/api/v3/cartoons").replace(
      queryParameters: {
        'free_type': '1',
        'offset': offset.toString(),
        'ordering': orderingBy,
      },
    );

    final response = await http.get(requestUri);
    response.headers["content-type"] = "application/xml; charset=utf-8";

    final document = json.decode(response.body);
    List<dynamic> animeList = document['results']['list'];

    return animeList.map((animeData) => Anime.fromJson(animeData)).toList();
  }

  // 取得動畫資訊
  static Future<AnimeFullInfo> getAnimeInfo(String pathword) async {
    final Uri requestUri = Uri.parse("$hotMangaURL/api/v3/cartoon2/$pathword");

    final response = await http.get(requestUri);
    response.headers["content-type"] = "application/json; charset=utf-8";

    final document = json.decode(response.body);
    final animeInfoJson = document['results']['cartoon'];

    return AnimeFullInfo.fromJson(animeInfoJson);
  }

  // 取得動畫集數列表
  static Future<List<AnimeChapter>> getAnimeChapterList(String pathword) async {
    final Uri requestUri = Uri.parse("$hotMangaURL/api/v3/cartoon/$pathword/chapters2");

    final response = await http.get(requestUri);
    response.headers["content-type"] = "application/xml; charset=utf-8";

    final document = json.decode(response.body);
    List<dynamic> animeChapterList = document['results']['list'];

    return animeChapterList.map((animeChapter) => AnimeChapter.fromJson(animeChapter)).toList();
  }

  // 登入 HotManga 取得 token
  static Future<String> setupLogging({username = "TestFish", password = "testfish"}) async {
    // 製作 salt
    final salt = Random().nextInt(1000).toString();

    // 編碼密碼
    final encodePwd = base64Encode(utf8.encode('$password-$salt'));

    final Uri requestUri = Uri.parse("$hotMangaURL/api/v3/login");
    // print("$requestUri");


    final response = await http.post(
      requestUri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': encodePwd,
        'salt': salt.toString(),
        'source': 'Offical',
        'platform': '1',
      },
    );

    response.headers["content-type"] = "application/xml; charset=utf-8";
    final document = json.decode(response.body);
    final token = document['results']['token'];
    return token;
  }

  static Future<String> getAnimeVideo(String pathword, String uuid) async {
    final token = await setupLogging();
    // print("$token");

    final Uri requestUri = Uri.parse("$hotMangaURL/api/v3/cartoon/$pathword/chapter/$uuid");
    // print("$requestUri");

    final response = await http.get(
      requestUri,
      headers: {
        'Authorization': 'Token $token',
      },
    );
    response.headers["content-type"] = "application/xml; charset=utf-8";
    final document = json.decode(response.body);
    final videoURL = document['results']['chapter']['video'];
    // print("$videoURL");

    return videoURL;
  }  
}