import 'package:flutter/material.dart';

// import 'package:mixnma/pages/search/novel/recent_novel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Text("Home Page"),
      )
    );
  }
}