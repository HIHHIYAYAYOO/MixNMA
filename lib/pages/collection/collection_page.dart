import 'package:flutter/material.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage  ({super.key});
  
  @override
  State<CollectionPage> createState() => _CollectionPage();  
}

class _CollectionPage extends State<CollectionPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Collection"),
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            tabs: const <Widget>[
              Tab(
                text: 'Novel',
                icon: Icon(Icons.book),
              ),
              Tab(
                text: 'Manga',
                icon: Icon(Icons.menu_book),
              ),
              Tab(
                text: 'Anime',
                icon: Icon(Icons.live_tv),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const<Widget>[
            Center(child: Text("It is Novel"),
            ),
            Center(child: Text("It is Manga"),
            ),
            Center(child: Text("It is Anime"),
            ),
          ],
        ),
      ),
    );
  }
}