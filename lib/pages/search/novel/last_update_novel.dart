import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mixnma/api/novel/wenku8_api.dart';
import 'package:mixnma/models/novel/novel_info.dart';
import 'package:mixnma/widgets/novel/novel_info_widget.dart';
import 'package:mixnma/pages/cateloge/novel_cateloge.dart';

class LastUpdateNovel extends StatefulWidget {
  const LastUpdateNovel({super.key});

  @override
  State<LastUpdateNovel> createState() => _LastUpdateNovelState();
}


class _LastUpdateNovelState extends State<LastUpdateNovel> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController(); // 用來監聽滾動事件的控制器
  final initLoadData = Completer(); // 用來追蹤初次數據加載狀態的Completer
  List<Novel> novels = []; // 小說列表
  bool isloading = false; // 當前是否正在加載數據
  int _currentPage = 1; // 當前頁碼
  int _loadedPage = 0; // 已加載的最大頁碼

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // 添加滾動監聽器
    _fetchNextPage(); // 加載初始數據
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 清理資源
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // 保持頁面切換時不被清除

  // 滾動事件處理
  void _onScroll() {
    if(!isloading && _isBottom) {
      setState(() {
        _currentPage++; // 增加當前頁碼
        _fetchNextPage(); // 加載下一頁
      });
    }
  }

  // 判斷是否滾動到最底部
  bool get _isBottom {
    return _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
  }

  // 加載下一頁數據
  Future<void> _fetchNextPage() async {
    if(_currentPage <= _loadedPage) return; // 避免重複加載

    setState(() {
      isloading = true; // 開始加載
    });

    final newNovels = await Wenku8API.getNovelListWithInfo(NovelSortBy.lastUpdate, _currentPage);

    setState(() {
      novels.addAll(newNovels); // 添加新數據到小說列表
      _loadedPage = _currentPage; // 更新已加載的最大頁碼
      isloading = false; // 加載結束
    });

    if(!initLoadData.isCompleted) {
      initLoadData.complete(); // 標記數據初次加載完成
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: initLoadData.future, // 監控初次加載的狀態
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 顯示加載中的進度條
        }

        return ListView.builder(
          shrinkWrap: true, // 只占用子項目所需的空間
          controller: _scrollController, // 設置滾動控制器
          itemCount: novels.length, // 設置列表項目的數量
          itemBuilder: (context, index) {
            final novel = novels[index];
            final heroTag = "${index}_novel_${novel.aid}";

            return NovelInfoWidget(
              heroTag: heroTag,
              novel: novel,
              showTotalHitsCount: true,
              showPushCount: true,
              showFavCount: true,
              onTap: () => _navigateToNovelCateloge(context, novel, heroTag),
            );
          }
        );
      }
    );
  }

  void _navigateToNovelCateloge(BuildContext context, Novel novel, String heroTag) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NovelCateloge(
          novel: novel, 
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));

          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        }
      ),
    );
  }
}
