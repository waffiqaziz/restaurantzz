import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/feature/detail/screen/body_detail_screen.dart';
import 'package:restaurantzz/static/navigation_route.dart';

class DetailScreen extends StatefulWidget {
  final String restaurantId;

  const DetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().fetchRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: Consumer<DetailProvider>(
        builder: (context, value, child) {
          final resultState = value.resultState;

          // handle state submit action
          if (resultState is RestaurantDetailErrorState &&
              value.isReviewSubmission) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resultState.error)),
              );
            });
          } else if (resultState is RestaurantDetailLoadedState &&
              value.isReviewSubmission) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Strings.submitReviewSuccess),
                  duration: const Duration(seconds: 1),
                ),
              );
            });
          }

          // show all UI
          return switch (resultState) {
            RestaurantDetailLoadingState() =>
              const Center(child: CircularProgressIndicator()),
            RestaurantDetailLoadedState(data: var restaurant) =>
              RefreshIndicator(
                onRefresh: () async {
                  // reset flag
                  context.read<DetailProvider>().refresDate();
                  await context
                      .read<DetailProvider>()
                      .fetchRestaurantDetail(restaurant.id);
                },
                child: ListView(
                  children: [
                    BodyDetailScreen(restaurantDetailItem: restaurant),
                  ],
                ),
              ),
            RestaurantDetailErrorState(
              error: var message,
              restaurantId: var id,
            ) =>
              RefreshIndicator(
                onRefresh: () async {
                  await context
                      .read<DetailProvider>()
                      .fetchRestaurantDetail(id);
                },
                child: ListView(children: [
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
                ]),
              ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
