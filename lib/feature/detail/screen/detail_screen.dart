import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
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
  RestaurantDetailItem? _cachedRestaurantDetail;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().fetchRestaurantDetail(widget.restaurantId);
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      );
    });
  }

  void _showSnackBarError(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: Consumer<DetailProvider>(
        builder: (context, provider, child) {
          final resultState = provider.resultState;

          // handle review submission feedback
          if (provider.isReviewSubmission) {
            if (resultState is RestaurantDetailErrorState) {
              _showSnackBarError(context, resultState.error);
            } else if (resultState is RestaurantDetailLoadedState) {
              _showSnackBar(context, Strings.submitReviewSuccess);
            }
          } else if (resultState is RestaurantDetailErrorState) {
            _showSnackBarError(context, resultState.error);
          }

          // cache data if successfully loaded
          if (resultState is RestaurantDetailLoadedState) {
            _cachedRestaurantDetail = resultState.data;
          }

          return Stack(
            children: [
              // refresh handle
              RefreshIndicator(
                onRefresh: () async {
                  provider.refresDate();
                  await provider.fetchRestaurantDetail(widget.restaurantId);
                },
                child: _buildContent(resultState),
              ),

              // show indicator loading when submit a review
              if (provider.isReviewSubmission &&
                  provider.resultState is RestaurantDetailLoadingState) ...[
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(dynamic resultState) {
    if (resultState is RestaurantDetailLoadingState &&
        _cachedRestaurantDetail != null) {
      return ListView(
        children: [
          BodyDetailScreen(restaurantDetailItem: _cachedRestaurantDetail!),
        ],
      );
    } else if (resultState is RestaurantDetailLoadedState) {
      return ListView(
        children: [
          BodyDetailScreen(restaurantDetailItem: resultState.data),
        ],
      );
    } else if (resultState is RestaurantDetailErrorState &&
        _cachedRestaurantDetail != null) {
      return ListView(
        children: [
          BodyDetailScreen(restaurantDetailItem: _cachedRestaurantDetail!),
        ],
      );
    } else if (resultState is RestaurantDetailErrorState) {
      return ListView(
        children: [
          const SizedBox(height: 200),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                resultState.error,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
