import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/main/index_nav_provider.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/feature/search/screen/search_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IndexNavProvider>(
        builder: (context, value, child) {
          return IndexedStack(
            index: value.indexBottomNavBar,
            children: const [
              ListScreen(),
              SearchScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.watch<IndexNavProvider>().indexBottomNavBar,
        onTap: (index) {
          context.read<IndexNavProvider>().setIndextBottomNavBar = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_rounded),
            label: Strings.list,
            tooltip: Strings.list,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_rounded),
            label: Strings.search,
            tooltip: Strings.search,
          ),
        ],
      ),
    );
  }
}
