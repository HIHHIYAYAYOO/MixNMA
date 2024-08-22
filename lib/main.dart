import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mixnma/pages/home/home_page.dart';
import 'package:mixnma/pages/search/search_page.dart';
import 'package:mixnma/pages/collection/collection_page.dart';

import 'package:mixnma/api/novel/wenku8_api.dart';
import 'package:mixnma/global.dart';

void main() async{
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Global.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MixNMA Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:Colors.deepPurple,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:Colors.deepPurple,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    CollectionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (index) => setState(() {
          _currentPageIndex = index;
        }),
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.saved_search),
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.collections_bookmark),
            icon: Icon(Icons.collections_bookmark_outlined),
            label: 'Collection',
          ),
        ],
      ),
      body: IndexedStack( // 切換分頁後保留頁面狀態
        index: _currentPageIndex,
        children: _pages,
      ),
    );
  }
}