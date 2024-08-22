
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mixnma/api/comic/copyManga_api.dart';
import 'package:mixnma/models/comic/comic_info.dart';
import 'package:mixnma/utils/context_extension.dart';
import 'package:mixnma/widgets/comic/comic_cateloge_info_widget.dart';
import 'package:mixnma/global.dart';


import 'package:mixnma/pages/watch/comic/comic_reader.dart';

class ComicCateloge extends StatefulWidget {
  final String pathword;
  final String heroTag;

  const ComicCateloge({
    required this.pathword,
    required this.heroTag,
    super.key,
  });

  @override
  State<ComicCateloge> createState() => _ComicCatelogeState();
}

class _ComicCatelogeState extends State<ComicCateloge> {
  // late final Future<List<ComicInfo>> comicInfo;
  /*
  late final Future<List<Volume>> novelVolumes;
  Map<int, bool> expandedVolume = {};
  int? lastReadVolumeVid;
  int? lastReadChapterCid;
  */

  late Future<ComicFullInfo> comicFullInfo;
  late Future<List<ComicChapter>> comicChapterList;
  String? lastReadChapterUuid;


  @override
  void initState() {
    super.initState();
    comicFullInfo = CopyMangaAPI.getComicInfo(widget.pathword);
    comicChapterList = CopyMangaAPI.getComicChapterList(widget.pathword);
    lastReadChapterUuid = Global.preferences.getString("last_read_chapter:${widget.pathword}");
    /*
    novelVolumes = Wenku8API.getNovelVolumes(widget.novel.aid);
    lastReadVolumeVid = Global.preferences.getInt("last_read_volume:${widget.novel.aid}");
    lastReadChapterCid = Global.preferences.getInt("last_read_chapter:${widget.novel.aid}");
    expandedVolume[lastReadVolumeVid ?? 0] =true;
    */
  }  

  /*
  Future<ComicFullInfo> _fetchComicInfo() async {
    return await CopyMangaAPI.getComicInfo(widget.pathword);
  } 

  Future <List<ComicChapter>> _fetchcomicChapterList() async {
    return await CopyMangaAPI.getComicChapterList(widget.pathword);
  }
  */

  @override
  Widget build(BuildContext context) {
    final detailTextStyle = context.themeData.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSurfaceVariant, fontSize: 12.5);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<ComicFullInfo?>(
          future: comicFullInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Text(
                snapshot.data!.name ?? '漫畫名稱',
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: context.colorScheme.secondary,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
              );
            }
          },
        ),
      ),
      body: FutureBuilder<ComicFullInfo?>(
        future: comicFullInfo,
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
            ComicFullInfo comicFullInfo = snapshot.data!;
            return ListView(
              children: [
                ComicCatelogeInfoWidget(
                  heroTag: widget.heroTag, 
                  comicFullInfo: comicFullInfo,
                  showStatus: true,
                  showAuthor: true,
                  showLastUpdate: true,
                  showLastChapter: true,
                  showPopular: true,
                ),
                 _buildIntroCard(detailTextStyle),
                _buildChapterList(),
              ],
            );
          }
        },
      ),
    );
  }

  // 顯示漫畫簡介
  Widget _buildIntroCard(TextStyle detailTextStyle) {
    return FutureBuilder(
      future: comicFullInfo, 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          ComicFullInfo comicFullInfo = snapshot.data!;
          return Card(
            shadowColor: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /*
                  Text(
                    "漫畫簡介",
                    style: context.themeData.textTheme.titleMedium!.copyWith(color: context.colorScheme.secondary,)
                  ),
                  const SizedBox(height: 4),
                  */
                  Text(
                    comicFullInfo.brief!,
                    style: detailTextStyle,
                  ),
                ],
              )
            ),
          );
        }
      }
    );
  }

  Widget _buildChapterList() {
    return FutureBuilder(
      future: comicChapterList, 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          
          final chapterList = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: chapterList.length,
            itemBuilder: (context, index) {
              final chapter = chapterList[index];
              final isLastRead = lastReadChapterUuid == chapter.uuid;
              return ListTile(
                onTap: () => _onChapterTap(widget.pathword, chapter.uuid!),
                title: Text(
                  chapter.name ?? 'No name',
                  style: TextStyle(
                    color: isLastRead ? Colors.blueAccent : null,
                  ),
                ),
                subtitle: Text(
                  chapter.dateTimeCreated ?? 'Unknow',
                  style: TextStyle(
                    color: isLastRead ? Colors.lightBlueAccent : null,
                  ),
                ),
                // trailing: Text(chapter.uuid ?? 'No uuid'),
              );
            }
          );
        }
      },
    );
  }

  Future<void> _onChapterTap(String pathword, String uuid) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReader(
          pathword: pathword,
          uuid: uuid, 
        )
      )
    );
    setState(() {
      lastReadChapterUuid = uuid;
      Global.preferences.setString("last_read_chapter:${widget.pathword}", uuid);
    });
  }

/*
  // 顯示漫畫卷數及章節
  Widget _buildVolumeList() {
    return FutureBuilder(
      future: novelVolumes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final volumes = snapshot.data!;
          if (lastReadChapterCid != null) {
            // 初始化 expandedVolume 狀態
            for (var volume in volumes) {
              for (var chapter in volume.chapters) {
                if (chapter.cid == lastReadChapterCid) {
                  expandedVolume[volume.vid] = true;
                  break;
                }
              }
            }
          }
          return Column(
            children: volumes.map((volume) => _buildVolumeCard(volume)).toList(),
          );
        }
      },
    );
  }

  // 顯示漫畫卷數
  Widget _buildVolumeCard(Volume volume) {
    return Card(
      elevation: expandedVolume[volume.vid] ?? false ? 16 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(volume.cdata),
          initiallyExpanded: expandedVolume[volume.vid] ?? false,
          dense: true,
          visualDensity: VisualDensity.comfortable,
          textColor: context.colorScheme.primary,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          childrenPadding: const EdgeInsets.all(4),
          children: volume.chapters.map((chapter) => _buildChapterCard(volume, chapter)).toList(),
          onExpansionChanged: (isExpanded) => setState(() => expandedVolume[volume.vid] = isExpanded),
        ),
      )
    );
  }

  // 顯示漫畫章節
  Widget _buildChapterCard(Volume volume, Chapter chapter) {
    final isLastRead = lastReadChapterCid == chapter.cid;

    return Card(
      elevation: 4,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onChapterTap(volume, chapter),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if(isLastRead) _buildLastReadLabel(),
              Text(
                chapter.cdata,
                style: isLastRead
                    ? context.themeData.textTheme.titleSmall!.copyWith(color: Colors.blueAccent)
                    : context.themeData.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

*/


/*
  Future<void> _onChapterTap(Volume volume, Chapter chapter) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelReader(
          aid: widget.novel.aid,
          cid: chapter.cid,
          cdata: chapter.cdata,
        )
      )
    );
    if(chapter.cdata != "插圖"){
      setState(() {
        lastReadChapterCid = chapter.cid;
        Global.preferences.setInt("last_read_volume:${widget.novel.aid}", volume.vid);
        Global.preferences.setInt("last_read_chapter:${widget.novel.aid}", chapter.cid);
      });
    }
  }
*/
}