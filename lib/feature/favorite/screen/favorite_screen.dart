import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';
import 'package:restaurantzz/static/navigation_route.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    Future.microtask(() {
      context.read<LocalDatabaseProvider>().loadAllRestaurant();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.yourFavorite),
      ),
      body: Consumer<LocalDatabaseProvider>(
        builder: (context, value, child) {
          final favoriteList = value.restaurantList ?? [];

          return switch (favoriteList.isNotEmpty) {
            true => ListView.builder(
                itemCount: favoriteList.length,
                itemBuilder: (context, index) {
                  final restaurant = favoriteList[index];

                  return RestaurantCard(
                    restaurant: restaurant,
                    heroTag: "favorite",
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        NavigationRoute.detailRoute.name,
                        arguments: {
                          'restaurantId': restaurant.id,
                          'heroTag': 'favorite',
                        },
                      );
                    },
                  );
                },
              ),
            _ => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No Item"),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}
