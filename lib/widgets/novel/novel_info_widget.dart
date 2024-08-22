import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mixnma/models/novel/novel_info.dart';
import 'package:mixnma/utils/context_extension.dart';

class NovelInfoWidget extends StatelessWidget {
  final String heroTag;
  final Novel novel;
  final bool showTitle;
  final bool showAuthor;
  final bool showBookStatus;
  final bool showTotalHitsCount;
  final bool showPushCount;
  final bool showFavCount;
  final bool showLastUpdate;
  final TextOverflow? titleOverflow;
  final void Function()? onTap;

  const NovelInfoWidget({
    required this.heroTag,
    required this.novel,
    this.showTitle = false,
    this.showAuthor = false,
    this.showBookStatus = false,
    this.showTotalHitsCount = false,
    this.showPushCount = false,
    this.showFavCount = false,
    this.showLastUpdate = false,
    this.titleOverflow = TextOverflow.ellipsis,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.themeData.textTheme;
    final novelTitleTextStyle = textTheme.titleMedium!.copyWith(color: context.colorScheme.primary);
    final novelDetailTextStyle = textTheme.titleMedium!.copyWith(color: context.colorScheme.onSurface, fontSize: 15);

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
              _buildThumbnail(context), // 顯示小說縮圖
              const SizedBox(width: 12),
              Expanded(child: _buildDetails(novelTitleTextStyle, novelDetailTextStyle)), // 顯示小說資訊
            ],
          ),
        ),
      ),
    );
  }

  // 構建小說封面縮圖區域
  Widget _buildThumbnail(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          SizedBox(
            height: 100,
            width: 66.67,
            child: Hero(
              tag: "${heroTag}_cover",
              child: CachedNetworkImage(
                imageUrl: novel.coverURL,
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

  // 顯示小說封面大圖
  /*
  void _viewImage(BuildContext context){

  }
  */

  // 構建小說資訊區域
  Widget _buildDetails(TextStyle titleStyle, TextStyle detailStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(showTitle) _buildTitleText("${novel.title}", titleStyle),
        if(showAuthor) _buildDetailText("作者: ${novel.author}", detailStyle, underline: true),
        if(showBookStatus) _buildDetailText("連載狀態: ${novel.bookStatus}", detailStyle),
        if(showTotalHitsCount) _buildDetailText("總點擊數: ${novel.totalHitsCount}", detailStyle),
        if(showPushCount) _buildDetailText("總推薦數: ${novel.pushCount}", detailStyle),
        if(showFavCount) _buildDetailText("總收藏數: ${novel.favCount}", detailStyle),
        if(showLastUpdate) _buildDetailText("更新時間: ${novel.lastUpdate!.toIso8601String().split('T').first}", detailStyle),
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

  // 構建小說細節文字
  Widget _buildDetailText(String text, TextStyle style, {bool underline = false}) {
    return Text(
      text,
      style: underline ? style.copyWith(decoration: TextDecoration.underline) : style,
    );
  }
}