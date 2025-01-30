import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/feature/detail/screen/body_detail_screen.dart';

class DetailScreen extends StatefulWidget {
  final String restaurantId;
  final String heroTag;

  const DetailScreen({
    super.key,
    required this.restaurantId,
    required this.heroTag,
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

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSecondaryContainer,
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
          // handle review submission feedback
          if (provider.isReviewSubmissionComplete) {
            if (provider.reviewSubmissionError != null) {
              _showSnackBar(
                context,
                provider.reviewSubmissionError!,
                isError: true,
              );
            } else {
              _showSnackBar(
                context,
                Strings.submitReviewSuccess,
              );
            }

            // reset the submission state after showing feedback
            provider.resetReviewSubmissionState();
          }

          return Stack(
            children: [
              // refresh handle
              RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchRestaurantDetail(
                    widget.restaurantId,
                    refresh: true,
                  );
                },
                child: _buildContent(provider),
              ),

              // show loading and alpha background when submitting a review
              if (provider.isReviewSubmission)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(DetailProvider provider) {
    final resultState = provider.resultState;

    if (resultState is RestaurantDetailLoadedState &&
        provider.cachedData != null) {
      return ListView(
        children: [
          BodyDetailScreen(
            restaurantDetailItem: provider.cachedData!,
            heroTag: widget.heroTag,
          ),
        ],
      );
    } else if (resultState is RestaurantDetailLoadedState) {
      return ListView(
        children: [
          BodyDetailScreen(
            restaurantDetailItem: resultState.data,
            heroTag: widget.heroTag,
          ),
        ],
      );
    } else if (resultState is RestaurantDetailErrorState) {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 200), // Spacer if needed
          Center(
            child: Column(
              children: [
                Image.asset(
                  "images/general_error.png",
                  width: 200,
                ),
                const SizedBox(height: 8),
                Text(
                  resultState.error,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Default loading indicator
      return const Center(child: CircularProgressIndicator());
    }
  }
}
