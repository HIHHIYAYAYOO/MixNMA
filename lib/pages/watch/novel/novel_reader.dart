
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mixnma/api/novel/wenku8_api.dart';
import 'package:mixnma/utils/context_extension.dart';
import 'package:mixnma/pages/watch/novel/novel_image_reader.dart';
import 'package:mixnma/pages/watch/novel/novel_reader_settings.dart';

class NovelReader extends StatefulWidget {
  final int aid;
  final int cid;
  final String novelName;
  final String cdata;

  const NovelReader({
    required this.aid,
    required this.cid,
    required this.novelName,
    required this.cdata,
    super.key,
  });

  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  late final ScrollController _scrollController = ScrollController();
  late final Future<List<String>> novelContent = Wenku8API.getNovelContent(widget.aid, widget.cid);
  bool _isOverlayVisible = false;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _scrollController.addListener(_onScroll); // 監聽滾動事件
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // 移除監聽器
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleOverlay() => setState(() => _isOverlayVisible = !_isOverlayVisible);

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        // 計算滑條的value並使用clamp限制在0.0到1.0之間
        _sliderValue = (_scrollController.position.pixels / _scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
      });
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      // 限制滑條的值在0.0到1.0之間
      _sliderValue = value.clamp(0.0, 1.0);
      // 根據滑條的value移動到相應位置
      final position = _sliderValue * _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        NovelReaderSettings.fontSize,
        NovelReaderSettings.lineHeight,
        NovelReaderSettings.letterSpacing,
        NovelReaderSettings.paragraphSpacing,
        NovelReaderSettings.paragraphMargin,
      ]),
      builder: (context, _) {
        final fontSize = NovelReaderSettings.fontSize.value;
        final lineHeight = NovelReaderSettings.lineHeight.value;
        final letterSpacing = NovelReaderSettings.letterSpacing.value;
        final paragraphSpacing = NovelReaderSettings.paragraphSpacing.value;
        final paragraphMargin = NovelReaderSettings.paragraphMargin.value;

        final firstLineTextStyle = context.themeData.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.onSurfaceVariant,
          fontSize: fontSize,
          height: lineHeight,
          letterSpacing: letterSpacing,
        );

        final contentTextStyle = context.themeData.textTheme.bodyLarge!.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontSize: fontSize,
          height: lineHeight,
          letterSpacing: letterSpacing,
        );

        return Scaffold(
          body: Stack(
            children: [
              GestureDetector(
                onTap: _toggleOverlay,
                child: FutureBuilder<List<String>>(
                  future: novelContent,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      final content = snapshot.data!;
                      return _buildChaptercontent(content, paragraphSpacing, paragraphMargin, firstLineTextStyle, contentTextStyle);
                    }
                  },
                ),
              ),
              _buildOverlayAppBar(),
              _buildOverlaySetting(),
            ],
          ),
        );
      },
    );
  }

  // 顯示小說內容
  Widget _buildChaptercontent(List<String> content, paragraphSpacing, paragraphMargin, firstLineTextStyle, contentTextStyle) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: content.length,
      itemBuilder: (context, index) {
        if (imageRegex.hasMatch(content[index])) {
          return NovelImageReader.buildImageWidgets(content[index]);
        }
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paragraphMargin, 
            vertical: paragraphSpacing,
          ),
          child: Text(
            content[index],
            style: index == 0 ? firstLineTextStyle : contentTextStyle,
          ),
        );
      },
    );
  }

  // 顯示標題欄的動畫
  Widget _buildOverlayAppBar() {
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
                  widget.novelName,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              Text(
                widget.cdata,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          )
        )
      )
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
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => NovelReaderSettings.showSettingsModal(context), // 顯示設定上拉選單
              ),
            ],
          ),
        ),
      ),
    );
  }
}
