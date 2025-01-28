import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/main/index_nav_provider.dart';
import 'package:restaurantzz/feature/favorite/screen/favorite_screen.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/feature/search/screen/search_screen.dart';
import 'package:restaurantzz/feature/settings/screen/settings_screen.dart';

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
              FavoriteScreen(),
              SettingsScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: context.watch<IndexNavProvider>().indexBottomNavBar,
        onDestinationSelected: (index) {
          context.read<IndexNavProvider>().setIndextBottomNavBar = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list_rounded),
            label: Strings.list,
            tooltip: Strings.list,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            label: Strings.search,
            tooltip: Strings.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline_rounded),
            label: Strings.favorite,
            tooltip: Strings.favorite,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: Strings.settings,
            tooltip: Strings.settings,
          ),
        ],
      ),
    );
  }
}
