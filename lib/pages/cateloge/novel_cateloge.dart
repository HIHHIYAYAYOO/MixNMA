import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mixnma/api/novel/wenku8_api.dart';
import 'package:mixnma/models/novel/novel_info.dart';
import 'package:mixnma/models/novel/volume.dart';
import 'package:mixnma/utils/context_extension.dart';
import 'package:mixnma/widgets/novel/novel_info_widget.dart';
import 'package:mixnma/models/novel/chapter.dart';
import 'package:mixnma/global.dart';
import 'package:mixnma/pages/watch/novel/novel_reader.dart';

class NovelCateloge extends StatefulWidget {
  final Novel novel;
  final String heroTag;

  const NovelCateloge({
    required this.novel,
    required this.heroTag,
    super.key,
  });

  @override
  State<NovelCateloge> createState() => _NovelCatelogeState();
}

class _NovelCatelogeState extends State<NovelCateloge> {
  late final Future<List<String>> novelFullIntro;
  late final Future<List<Volume>> novelVolumes;
  Map<int, bool> expandedVolume = {};
  int? lastReadVolumeVid;
  int? lastReadChapterCid;

  @override
  void initState() {
    super.initState();
    novelFullIntro = Wenku8API.getNovelFullIntro(widget.novel.aid);
    novelVolumes = Wenku8API.getNovelVolumes(widget.novel.aid);
    lastReadVolumeVid = Global.preferences.getInt("last_read_volume:${widget.novel.aid}");
    lastReadChapterCid = Global.preferences.getInt("last_read_chapter:${widget.novel.aid}");
    expandedVolume[lastReadVolumeVid ?? 0] =true;
  }  

  @override 
  Widget build(BuildContext context) {
    final detailTextStyle = context.themeData.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSurfaceVariant, fontSize: 12.5);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.novel.title!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: context.colorScheme.secondary,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
      body: ListView(
        children: [
          NovelInfoWidget(
            heroTag: widget.heroTag,
            novel: widget.novel,
            showAuthor: true,
            showBookStatus: true,
            showLastUpdate: true,
            titleOverflow: TextOverflow.visible,
          ),
          _buildIntroCard(detailTextStyle),
          _buildVolumeList(),
        ],
      )
    );
  }

  // 顯示小說簡介
  Widget _buildIntroCard(TextStyle detailTextStyle) {
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
              "小說簡介",
              style: context.themeData.textTheme.titleMedium!.copyWith(color: context.colorScheme.secondary,)
            ),
            const SizedBox(height: 4),
            */
            FutureBuilder(
              future: novelFullIntro, 
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: snapshot.data!.map((novelIntro) => Text(novelIntro, style: detailTextStyle)).toList(),
                  );
                }
              }
            )
          ],
        )
      ),
    );
  }

  // 顯示小說卷數及章節
  Widget _buildVolumeList() {
    return FutureBuilder(
      future: novelVolumes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final volumes = snapshot.data!;
          return Column(
            children: volumes.map((volume) => _buildVolumeCard(volume)).toList(),
          );
        }
      },
    );
  }

  // 顯示小說卷數
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

  // 顯示小說章節
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

  /*
  Widget _buildLastReadLabel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "最後閱讀",
        style: TextStyle(
          height: 1,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  */

  Future<void> _onChapterTap(Volume volume, Chapter chapter) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelReader(
          aid: widget.novel.aid,
          cid: chapter.cid,
          novelName: widget.novel.title!,
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
}