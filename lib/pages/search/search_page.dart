import 'package:flutter/material.dart';
import 'package:mixnma/api/novel/wenku8_api.dart';
import 'package:mixnma/pages/search/novel/sorted_novel.dart';
import 'package:mixnma/pages/search/comic/ordering_comic.dart';
import 'package:mixnma/pages/search/anime/ordering_anime.dart';
// import 'package:mixnma/pages/search/novel/last_update_novel.dart';
// import 'package:mixnma/pages/search/novel/day_visit_novel.dart';

class SearchPage extends StatelessWidget {
  const SearchPage  ({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Search"),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Novel',icon: Icon(Icons.book)),
              Tab(text: 'Manga',icon: Icon(Icons.menu_book)),
              Tab(text: 'Anime',icon: Icon(Icons.live_tv)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NovelNestedTabBar(outerTab: 'Novel'),
            ComicNestedTabBar(outerTab: 'Manga'),
            AnimeNestedTabBar(outerTab: 'Anime'),
          ],
        )
      )
    );
  }
}

class NovelNestedTabBar extends StatelessWidget {
  const NovelNestedTabBar({required this.outerTab, super.key});

  final String outerTab;

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 13,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Last Update"),
              Tab(text: "All Visit"),
              Tab(text: "All Vote"),
              Tab(text: "Month Visit"),
              Tab(text: "Month Vote"),
              Tab(text: "Week Visit"),
              Tab(text: "Week Vote"),
              Tab(text: "Day Visit"),
              Tab(text: "Day Vote"),
              Tab(text: "Post Data"),
              Tab(text: "Good Num"),
              Tab(text: "Size"),
              Tab(text: "Full Flag"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SortedNovel(sortBy: NovelSortBy.lastUpdate),
                SortedNovel(sortBy: NovelSortBy.allVisit),
                SortedNovel(sortBy: NovelSortBy.allVote),
                SortedNovel(sortBy: NovelSortBy.monthVisit),
                SortedNovel(sortBy: NovelSortBy.monthVote),
                SortedNovel(sortBy: NovelSortBy.weekVisit),
                SortedNovel(sortBy: NovelSortBy.weekVote),
                SortedNovel(sortBy: NovelSortBy.dayVisit),
                SortedNovel(sortBy: NovelSortBy.dayVote),
                SortedNovel(sortBy: NovelSortBy.postDate),
                SortedNovel(sortBy: NovelSortBy.goodNum),
                SortedNovel(sortBy: NovelSortBy.size),
                SortedNovel(sortBy: NovelSortBy.fullFlag),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ComicNestedTabBar extends StatelessWidget {
  const ComicNestedTabBar({required this.outerTab, super.key});

  final String outerTab;

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "-datetime Updated"),
              Tab(text: "-Popular"),
              Tab(text: "Datetime Updated"),
              Tab(text: "Popular"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                OrderingComic(orderingBy: "-datetime_updated"),
                OrderingComic(orderingBy: "-popular"),
                OrderingComic(orderingBy: "datetime_updated"),
                OrderingComic(orderingBy: "popular"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AnimeNestedTabBar extends StatelessWidget {
  const AnimeNestedTabBar({required this.outerTab, super.key});

  final String outerTab;

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 6,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "-datetime Updated"),
              Tab(text: "-Popular"),
              Tab(text: "-Pub Year"),
              Tab(text: "Datetime Updated"),
              Tab(text: "Popular"),
              Tab(text: "Pub Year"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                OrderingAnime(orderingBy: "-datetime_updated"),
                OrderingAnime(orderingBy: "-popular"),
                OrderingAnime(orderingBy: "-pub_year"),
                OrderingAnime(orderingBy: "datetime_updated"),
                OrderingAnime(orderingBy: "popular"),
                OrderingAnime(orderingBy: "pub_year"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NestedTabBar extends StatelessWidget {
  const NestedTabBar({required this.outerTab, super.key});

  final String outerTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Last Update"),
              Tab(text: "Day Visit"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTabContent("Last Update"),
                _buildTabContent("Day Visit"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabContent(String tabType) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Center(
        child: Text('$outerTab: $tabType tab'),
      ),
    );
  }
}