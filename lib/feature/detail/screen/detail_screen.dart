import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/feature/detail/screen/body_detail_screen.dart';

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

    Future.microtask(() {
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

          // if error, shows snackbar with error message
          if (resultState is RestaurantDetailErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resultState.error)),
              );
            });
          } else if (resultState is RestaurantDetailLoadedState &&
              value.isReviewSubmission) {
            // if the state trigger submit review, shows snackbar
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
              BodyDetailScreen(restaurantDetailItem: restaurant),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
