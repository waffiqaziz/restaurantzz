import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final FocusNode _focusNode = FocusNode();
  String _lastQuery = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    // set focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onSubmit(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      context.read<SearchProvider>().clearSearchResults(); // Reset search results
    } else if (query != _lastQuery) {
      setState(() {
        _isSearching = true;
        _lastQuery = query;
      });
      context.read<SearchProvider>().fetchRestaurantList(query); // Start searching
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  focusNode: _focusNode, // Attach FocusNode
                  decoration: InputDecoration(
                    hintText: 'Search for a restaurant...',
                    filled: false, // Make the background filled
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSubmit('');
                            },
                          )
                        : null,
                  ),
                  onSubmitted: _onSubmit, // Trigger search on submit
                ),
              ),
            ),
          ];
        },
        body: Consumer<SearchProvider>(
          builder: (context, value, child) {
            return switch (value.resultState) {
              RestaurantSearchNotFoundState() =>
                const Center(child: Text('No results found')),
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
                  child: Text(message),
                ),
              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}
