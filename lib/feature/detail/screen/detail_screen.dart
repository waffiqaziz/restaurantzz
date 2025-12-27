import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/constants.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/feature/detail/screen/body_detail_screen.dart';

class DetailScreen extends StatefulWidget {
  final String restaurantId;
  final String heroTag;

  const DetailScreen({super.key, required this.restaurantId, required this.heroTag});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
    });
  }

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
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Consumer<DetailProvider>(
        builder: (context, provider, _) {
          final state = provider.viewStateOf(widget.restaurantId);

          if (state.reviewCompleted) {
            if (state.reviewError != null) {
              _showSnackBar(context, state.reviewError!, isError: true);
            } else {
              _showSnackBar(context, Strings.submitReviewSuccess);
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.resetReviewSubmissionState(widget.restaurantId);
            });
          }

          if (state.resultState is RestaurantDetailLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.resultState is RestaurantDetailErrorState) {
            return _errorDetail(context, (state.resultState as RestaurantDetailErrorState).error);
          }

          if (state.resultState is RestaurantDetailLoadedState) {
            final data = (state.resultState as RestaurantDetailLoadedState).data;

            return Stack(
              children: [
                _buildDetailScaffold(context, data),
                if (state.isSubmittingReview)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _errorDetail(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 350, child: Image.asset("images/general_error.png")),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<DetailProvider>().fetchRestaurantDetail(widget.restaurantId),
              child: Text(Strings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailScaffold(BuildContext context, RestaurantDetailItem restaurantDetailItem) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate height based on aspect ratio
    final dynamicHeight = screenWidth / (16 / 9);
    final expandedHeight = dynamicHeight > 400 ? 400 : dynamicHeight; // Cap at 400

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: 0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                child: CircleAvatar(
                  radius: 20,
                  child: IconButton(
                    key: Key('back_button'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: Strings.close,
                  ),
                ),
              ),
              backgroundColor: innerBoxIsScrolled
                  ? Theme.of(context).colorScheme.onSecondaryFixedVariant
                  : Colors.transparent,
              expandedHeight: expandedHeight.toDouble(),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // get the current screen width
                          final screenWidth = constraints.maxWidth;
                          final imageWidth = screenWidth > 900 ? 900 : screenWidth;

                          return Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: SizedBox(
                              width: imageWidth.toDouble(), // max width for image
                              child: Hero(
                                tag: "${restaurantDetailItem.pictureId}_${widget.heroTag}",
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16.0),
                                    bottomRight: Radius.circular(16.0),
                                  ),
                                  child: Image.network(
                                    Constants.imageURLMediumResolution +
                                        restaurantDetailItem.pictureId,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'images/images_error.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await context.read<DetailProvider>().fetchRestaurantDetail(
              widget.restaurantId,
              refresh: true,
            );
          },
          child: ListView(
            children: [
              BodyDetailScreen(restaurantDetailItem: restaurantDetailItem, heroTag: widget.heroTag),
            ],
          ),
        ),
      ),
    );
  }
}
