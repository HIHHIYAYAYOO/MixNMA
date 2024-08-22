import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:xml/xml.dart';

import 'package:mixnma/models/novel/novel_info.dart';
import 'package:mixnma/models/novel/volume.dart';

// 配置日誌紀錄器
void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    throw("${rec.level.name}: ${rec.time}: ${rec.message}");
  }); 
}

enum NovelSortBy {
  allVisit,
  allVote,
  monthVisit,
  monthVote,
  weekVisit,
  weekVote,
  dayVisit,
  dayVote,
  postDate,
  lastUpdate,
  goodNum,
  size,
  fullFlag,
}

extension NovelSortByExtension on NovelSortBy {
  String get value => name.toLowerCase();
}

class Wenku8API {
  static const String baseURL = "http://app.wenku8.com/android.php";
  static const String relayURL = "https://wenku8-relay.mewx.org/";

  static String getRequestString(String request) {
    final base64Request = base64Encode(utf8.encode(request));
    final timeToken = DateTime.now().millisecondsSinceEpoch;
    return "appver=1.0&request=$base64Request&timetoken=$timeToken";
  }

  // 取得小說封面URL
  static String getCoverURL(int aid) {
    final dir = (aid / 1000).floor();
    return "http://img.wenku8.com/image/$dir/$aid/${aid}s.jpg";
  }

  // 取得小說列表
  static Future<List<Novel>> getNovelListWithInfo(NovelSortBy sortBy, int page) async {
    final requestString = getRequestString("action=novellist&sort=${sortBy.value}&page=$page&t=1");

    // 小說列表請求
    // print('curl -X POST "${Wenku8API.relayURL}" -d "$requestString"');

    final response = await http.post(
      Uri.parse(Wenku8API.relayURL),
      body: requestString,
    );

    if(response.statusCode != 200) {
      throw "GetNovelListWithInfo: The sever responded with status code ${response.statusCode}";
    }

    final document = XmlDocument.parse(response.body);
    final novels = document.findAllElements('item').map(Novel.fromXml).toList();

    return novels;
  }

  // 取得小說完整介紹內容
  static Future<List<String>> getNovelFullIntro(int aid) async {
    final requestString = getRequestString("action=book&do=intro&aid=$aid&t=1");

    // 小說完整介紹內容請求
    // print('curl -X POST "${Wenku8API.baseURL}" -H "application/x-www-form-urlencoded" -d "$requestString"');

    final response = await http.post(
      Uri.parse(Wenku8API.baseURL),
      headers: {"content-type": "application/x-www-form-urlencoded"},
      body: requestString,
    );

    if(response.statusCode != 200) {
      throw "GetNovelFullIntro: The sever responded with status code ${response.statusCode}";
    }

    return response.body.split("\n");
  }

  // 取得小說卷數及章節資訊
  static Future<List<Volume>> getNovelVolumes(int aid) async {
    final requestString = getRequestString("action=book&do=list&aid=$aid&t=1");
    
    // 小說卷數及章節資訊請求
    // print('curl -X POST "${Wenku8API.baseURL}" -H "application/x-www-form-urlencoded" -d "$requestString"');

    final response = await http.post(
      Uri.parse(Wenku8API.baseURL),
      headers: {"content-type": "application/x-www-form-urlencoded"},
      body: requestString,
    );
    response.headers["content-type"] = "application/xml; charset=utf-8";

    if(response.statusCode != 200) {
      throw "GetNovelFullIntro: The sever responded with status code ${response.statusCode}";
    }

    final document = XmlDocument.parse(response.body);
    final volumes = document.findAllElements('volume').map(Volume.fromXml).toList();

    return volumes;
  }

  // 取得小說內容
  static Future<List<String>> getNovelContent(int aid, int cid) async {
    final requestString = getRequestString("action=book&do=text&aid=$aid&cid=$cid&t=1");

    final response = await http.post(
      Uri.parse(Wenku8API.baseURL),
      headers: {"content-type": "application/x-www-form-urlencoded"},
      body: requestString,
    );

    if(response.statusCode != 200) {
      throw "GetNovelFullIntro: The sever responded with status code ${response.statusCode}";
    }

    return response.body
        .split("\n")
        .map((line) => line.trimRight()) // 移除每行右邊的空白
        .where((line) => line.isNotEmpty) // 移除空行
        .toList();
  }
}