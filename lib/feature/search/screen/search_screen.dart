import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/states/search_result_state.dart';
import 'package:restaurantzz/core/provider/search/search_provider.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';
import 'package:restaurantzz/static/navigation_route.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      context.read<SearchProvider>().updateClearButton(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 5.0,
              pinned: false,
              title: Padding(
                padding: const EdgeInsets.all(0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Strings.searchAnyRestaurant,
                    filled: false, // Make the background filled
                    suffixIcon: searchProvider.isClearVisible
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchProvider.clearSearchResults();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (query) {
                    searchProvider.fetchRestaurantList(query);
                  }, // Trigger search on submit
                ),
              ),
            ),
          ];
        },
        body: Consumer<SearchProvider>(
          builder: (context, value, child) {
            return switch (value.resultState) {
              RestaurantSearchNotFoundState() =>
                Center(child: Text(Strings.noResult)),
              RestaurantSearchLoadingState() => const Center(
                  child: CircularProgressIndicator(),
                ),
              RestaurantSearchLoadedState(data: var restaurantList) =>
                ListView.builder(
                  itemCount: restaurantList.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurantList[index];

                    return RestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          NavigationRoute.detailRoute.name,
                          arguments: restaurant.id,
                        );
                      },
                    );
                  },
                ),
              RestaurantSearchErrorState(error: var message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}
