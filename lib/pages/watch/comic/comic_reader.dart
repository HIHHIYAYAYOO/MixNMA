import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mixnma/global.dart';

import 'package:mixnma/models/comic/comic_info.dart';
import 'package:mixnma/api/comic/copymanga_api.dart';

class ComicReader extends StatefulWidget {
  final String pathword;
  final String uuid;

  const ComicReader({
    required this.pathword,
    required this.uuid,
    super.key,
  });

  @override
  State<ComicReader> createState() => _ComicReaderState();
}

class _ComicReaderState extends State<ComicReader> {
  late final ScrollController _scrollController = ScrollController();
  late final Future<ComicChapterData> comicChapterData = CopyMangaAPI.getComicPage(widget.pathword, widget.uuid);
  final TransformationController _transformationController = TransformationController();
  Offset _doubleTapPostion = Offset.zero;
  bool _isOverlayVisible = false;
  double _sliderValue =0.0;
  String? lastReadChapterUuid;
  double? lastReadPosition;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _scrollController.addListener(_onScroll);
    lastReadChapterUuid = Global.preferences.getString("last_read_chapter${widget.pathword}");
    lastReadPosition = Global.preferences.getDouble("last_read_position${widget.pathword}");
    _jumpToLastReadPosition();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToLastReadPosition() {
    if(lastReadChapterUuid == widget.uuid) {
      _scrollController.jumpTo(lastReadPosition!);
    } else {
      Global.preferences.setDouble("last_read_position:${widget.pathword}", 0.0);
    }
  }

  void _toggleOverlay() => setState(() => _isOverlayVisible = !_isOverlayVisible);

  void  _onScroll() {
    if(_scrollController.hasClients) {
      setState(() {
        _sliderValue =(_scrollController.position.pixels / _scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
      });
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value.clamp(0.0, 1.0);
      final position = _sliderValue * _scrollController.position.maxScrollExtent;
      Global.preferences.setDouble("last_read_position:${widget.pathword}", position);
      _scrollController.jumpTo(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: comicChapterData, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          ComicChapterData comicChapterData = snapshot.data!;
          return Scaffold(
            body: Stack(   
              children: [
                InteractiveViewer(
                  transformationController: _transformationController,
                  child: GestureDetector(
                    onTap: _toggleOverlay,
                    onDoubleTap: _handleDoubleTap,
                    onDoubleTapDown: (details) => _doubleTapPostion = details.localPosition,
                    child: _buildImageWidget(comicChapterData),
                  )
                ),
                _buildOverlayAppBar(comicChapterData),
                _buildOverlaySetting(),
              ],
            ),
          );
        }
      }
    );
  }

  void _handleDoubleTap() {
    setState(() {
      if(_transformationController.value.isIdentity()) {
        _transformationController.value = Matrix4.identity()
          ..translate(-_doubleTapPostion.dx, -_doubleTapPostion.dy)
          ..scale(2.0);
      } else {
        _transformationController.value = Matrix4.identity();
      }
    });
  }

  // 構建漫畫內容
  Widget _buildImageWidget(ComicChapterData comicChapterData) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: comicChapterData.chapterContents!.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: CachedNetworkImage(
            imageUrl: comicChapterData.chapterContents![index],
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }

  // 顯示標題欄的動畫
  Widget _buildOverlayAppBar(ComicChapterData comicChapterData) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _isOverlayVisible ? 0 : -100, // 顯示或隱藏標題欄
      left: 0,
      right: 0,
      child: Material(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        elevation: 0,
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comicChapterData.comicName ?? 'No comic name',
                  style: const TextStyle(
                  fontSize: 18,
                )
              ),
              Text(
                comicChapterData.chapterName ?? 'No chapter name', 
                style: const TextStyle(
                  fontSize: 13,
                )
              ),
            ]
          )
        ),
      ),
    );
  }

  // 顯示設定導覽列的動畫
  Widget _buildOverlaySetting() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: _isOverlayVisible ? 0 : -50, // 顯示或隱藏導覽列
      left: 0,
      right: 0,
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        elevation: 50,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _sliderValue,
                  onChanged: _onSliderChanged,
                )
              ),
              const Icon(Icons.settings),
            ],
          ),
        ),
      ),
    );
  }
}