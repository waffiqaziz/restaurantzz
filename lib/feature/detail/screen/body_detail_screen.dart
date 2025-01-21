import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:restaurantzz/core/common/constants.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';

class BodyDetailScreen extends StatelessWidget {
  const BodyDetailScreen({
    super.key,
    required this.restaurantDetailItem,
  });

  final RestaurantDetailItem restaurantDetailItem;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 900,
          child: Container(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Column(
              children: [
                // image
                Hero(
                  tag: restaurantDetailItem.id,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        Constants.imageURLMediumResolution +
                            restaurantDetailItem.pictureId,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // restaurant information
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // restaurant name
                                Text(
                                  restaurantDetailItem.name,
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),

                                // restaurant address
                                Text(
                                  "${restaurantDetailItem.city}, ${restaurantDetailItem.address}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),

                          // restaurant rating
                          RatingBarIndicator(
                            rating: restaurantDetailItem.rating,
                            itemCount: 5,
                            itemSize: 30.0,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox.square(dimension: 4),
                          Text(
                            "(${restaurantDetailItem.rating}/5.0)",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox.square(dimension: 16),
                      Text(
                        restaurantDetailItem.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
