import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mixnma/api/comic/copymanga_api.dart';
import 'package:mixnma/models/comic/comic_info.dart';
import 'package:mixnma/widgets/comic/comic_info_widget.dart';
import 'package:mixnma/pages/cateloge/comic_cateloge.dart';

class OrderingComic extends StatefulWidget {
  final String orderingBy;

  const OrderingComic({
    required this.orderingBy, 
    super.key
  });

  @override
  State<OrderingComic> createState() => _OrderingComicState();
}


class _OrderingComicState extends State<OrderingComic> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController(); // 用來監聽滾動事件的控制器
  final initLoadData = Completer(); // 用來追蹤初次數據加載狀態的Completer
  List<Comic> comics = []; // 漫畫列表
  bool isloading = false; // 當前是否正在加載數據
  int _currentPage = 0; // 當前頁碼
  int _loadedPage = -1; // 已加載的最大頁碼

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

    final newComics = await CopyMangaAPI.getComicList(page: _currentPage, orderingBy: widget.orderingBy);

    setState(() {
      comics.addAll(newComics); // 添加新數據到漫畫列表
      _loadedPage = _currentPage; // 更新已加載的最大頁碼
      isloading = false; // 加載結束
    });

    if(!initLoadData.isCompleted) {
      initLoadData.complete(); // 標記數據初次加載完成
    }
  }

  // 下拉刷新頁面
  Future<void> _refresh() async {
    setState(() {
      comics.clear(); // 清空當前漫畫列表
      _currentPage = 0;
      _loadedPage = -1;
    });
    await _fetchNextPage(); //重新加載頁面
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

        return RefreshIndicator(
          onRefresh: _refresh, // 設置下拉刷新觸發的函數
          child: ListView.builder(
            shrinkWrap: true, // 只占用子項目所需的空間
            controller: _scrollController, // 設置滾動控制器
            itemCount: comics.length, // 設置列表項目的數量
            itemBuilder: (context, index) {
              final comic = comics[index];
              final heroTag = "${index}_comic_${comic.pathword}";
              return ComicInfoWidget(
                heroTag: heroTag,
                comic: comic,
                showPopular: true,
                showLastUpdate: true,
                onTap: () => _navigateToComicCateloge(context, comic.pathword!, heroTag),
              );
            }
          ),
        );
      }
    );
  }

  void _navigateToComicCateloge(BuildContext context, String pathword, String heroTag) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ComicCateloge(
          heroTag: heroTag,
          pathword: pathword,
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
