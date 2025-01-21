import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late final DetailProvider _detailProvider;

  @override
  void initState() {
    super.initState();

    _detailProvider = context.read<DetailProvider>();
    _detailProvider.fetchRestaurantDetail(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Consumer<DetailProvider>(
        builder: (context, value, child) {
          return switch (value.resultState) {
            RestaurantDetailLoadingState() =>
              const Center(child: CircularProgressIndicator()),
            RestaurantDetailLoadedState(data: var restaurant) =>
              BodyDetailScreen(restaurantDetailItem: restaurant),
            RestaurantDetailErrorState(error: var message) =>
              Center(child: Text(message)),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
