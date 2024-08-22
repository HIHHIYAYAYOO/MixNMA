import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mixnma/models/anime/anime_info.dart';
import 'package:mixnma/utils/context_extension.dart';

class AnimeInfoWidget extends StatelessWidget {
  final String heroTag;
  final Anime anime;
  final bool showPopular;
  final bool showLastUpdate;
  final TextOverflow? titleOverflow;
  final void Function()? onTap;

  const AnimeInfoWidget({
    required this.heroTag,
    required this.anime,
    this.showPopular = false,
    this.showLastUpdate = false,
    this.titleOverflow = TextOverflow.ellipsis,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.themeData.textTheme;
    final comicTitleTextStyle = textTheme.titleMedium!.copyWith(color: context.colorScheme.primary);
    final comicDetailTextStyle = textTheme.titleMedium!.copyWith(color: context.colorScheme.onSurface);

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

  // 構建動畫封面縮圖區域
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
                imageUrl: anime.cover ?? "無資料",
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

  // 顯示動畫封面大圖
  /*
  void _viewImage(BuildContext context){

  }
  */

  // 構建動畫資訊區域
  Widget _buildDetails(TextStyle titleStyle, TextStyle detailStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: "${heroTag}_title",
          child: Text(
            anime.name ?? "無資料",
            overflow: titleOverflow,
            style: titleStyle,
          ),
        ),
        const Divider(height: 6),
        if(showPopular) _buildDetailText("熱度: ${anime.popular}", detailStyle),
        if(showLastUpdate) _buildDetailText("更新時間: ${anime.lastUpdate?.toIso8601String().split('T').first}", detailStyle),
      ],
    );
  }

  // 構建動畫細節文字
  Widget _buildDetailText(String text, TextStyle style, {bool underline = false}) {
    return Text(
      text,
      style: underline ? style.copyWith(decoration: TextDecoration.underline) : style,
    );
  }
}