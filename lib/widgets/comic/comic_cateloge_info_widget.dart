import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mixnma/models/comic/comic_info.dart';
import 'package:mixnma/utils/context_extension.dart';

class ComicCatelogeInfoWidget extends StatelessWidget {
  final String heroTag;
  final ComicFullInfo comicFullInfo;
  final bool showName;
  final bool showStatus;
  final bool showAuthor;
  final bool showTheme;
  final bool showBrief;
  final bool showLastUpdate;
  final bool showLastChapter;
  final bool showPopular;
  final TextOverflow? titleOverflow;
  final void Function()? onTap;

  const ComicCatelogeInfoWidget({
    required this.heroTag,
    required this.comicFullInfo,
    this.showName = false,
    this.showStatus = false,
    this.showAuthor = false,
    this.showTheme = false,
    this.showBrief = false,
    this.showLastUpdate = false,
    this.showLastChapter = false,
    this.showPopular = false,
    this.titleOverflow = TextOverflow.ellipsis,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.themeData.textTheme;
    final comicTitleTextStyle = textTheme.titleMedium!.copyWith(color: context.colorScheme.primary);
    final comicDetailTextStyle = textTheme.titleMedium!.copyWith(color: context.colorScheme.onSurface, fontSize: 15);

    return Card(
      elevation: 4,
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _buildThumbnail(context), // 顯示漫畫縮圖
              const SizedBox(width: 12),
              Expanded(child: _buildDetails(comicTitleTextStyle, comicDetailTextStyle)), // 顯示漫畫資訊
            ],
          ),
        ),
      ),
    );
  }

  // 構建漫畫封面縮圖區域
  Widget _buildThumbnail(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          SizedBox(
            height: 100,
            width: 77.7,
            child: Hero(
              tag: "${heroTag}_cover",
              child: CachedNetworkImage(
                imageUrl: comicFullInfo.cover ?? "無資料",
                fit: BoxFit.contain,
              ),
            ),
          ),
          /*
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              onTap: () => _viewImage(context),
            ),
          ),
          */
        ],
      ),
    );
  }

  // 顯示漫畫封面大圖
  /*
  void _viewImage(BuildContext context){

  }
  */

  // 構建漫畫資訊區域
  Widget _buildDetails(TextStyle titleStyle, TextStyle detailStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(showName) _buildTitleText("作品名稱: ${comicFullInfo.popular}", detailStyle),
        if(showAuthor) _buildDetailText("作者: ${comicFullInfo.author!.join(', ')}", detailStyle),
        if(showStatus) _buildDetailText("連載狀態: ${comicFullInfo.status}", detailStyle),
        // if(showTheme) _buildDetailText("主題: ${comicFullInfo.lastUpdate?.toIso8601String().split('T').first}", detailStyle),
        // if(showBrief) _buildDetailText("小說簡介: ${comicFullInfo.popular}", detailStyle),
        if(showLastUpdate) _buildDetailText("更新時間: ${comicFullInfo.lastUpdate?.toIso8601String().split('T').first}", detailStyle),
        if(showLastChapter) _buildDetailText("最新一章: ${comicFullInfo.lastChapter}", detailStyle),
        if(showPopular) _buildDetailText("熱度: ${comicFullInfo.popular}", detailStyle),
      ],
    );
  }

  // 構建標題文字
  Widget _buildTitleText(String text, TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: "${heroTag}_title",
          child: Text(
            text,
            overflow: titleOverflow,
            style: style,
            ),
          ),
        const Divider(height: 6),
      ],
    );
  }

  // 構建漫畫細節文字
  Widget _buildDetailText(String text, TextStyle style, {bool underline = false}) {
    return Text(
      text,
      style: underline ? style.copyWith(decoration: TextDecoration.underline) : style,
    );
  }
}