import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/states/list_result_state.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';
import 'package:restaurantzz/static/navigation_route.dart';
import 'package:url_launcher/url_launcher.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final Uri _url = Uri.parse(Strings.githubUrl);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListProvider>().fetchRestaurantList();
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
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
              centerTitle: true,
              title: Text(
                Strings.ourRecommendation,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset('images/github-mark.png'),
                  ),
                ),
                onPressed: () {
                  _launchUrl();
                },
              ),
            ),
          ];
        },
        body: Consumer<ListProvider>(
          builder: (context, value, child) {
            return switch (value.resultState) {
              RestaurantListLoadingState() => const Center(
                  child: CircularProgressIndicator(),
                ),
              RestaurantListLoadedState(data: var restaurantList) =>
                RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ListProvider>().fetchRestaurantList();
                  },
                  child: ListView.builder(
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
                ),
              RestaurantListErrorState(error: var message) => RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ListProvider>().fetchRestaurantList();
                  },
                  child: ListView(
                    children: [
                      const SizedBox(height: 200),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            message,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
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
