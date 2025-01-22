import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:restaurantzz/core/common/constants.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/utils/helper.dart';
import 'package:restaurantzz/feature/detail/screen/menu_widget.dart';
import 'package:restaurantzz/feature/detail/screen/reviews_widget.dart';

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
            color: Theme.of(context).colorScheme.secondaryContainer,
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
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 8),

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

                                // restaurant rating
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        Helper.formatRating(
                                            "${restaurantDetailItem.rating}"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                    const SizedBox.square(dimension: 4),
                                    Flexible(
                                      flex: 1,
                                      child: RatingBarIndicator(
                                        rating: restaurantDetailItem.rating,
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox.square(dimension: 4),
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        "(${restaurantDetailItem.customerReviews.length})",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),

                                // restaurant address
                                const SizedBox.square(dimension: 4),
                                Text(
                                  "${restaurantDetailItem.address}, ${restaurantDetailItem.city}",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),

                                // restaurant categorie
                                const SizedBox.square(dimension: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: restaurantDetailItem.categories
                                      .map((category) {
                                    return Chip(
                                      label: Text(category.name),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      elevation: 4.0,
                                    );
                                  }).toList(),
                                ),
                                const SizedBox.square(dimension: 4),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // restaurant description
                      const SizedBox.square(dimension: 16),
                      ReadMoreText(
                        trimMode: TrimMode.Line,
                        trimLines: 4,
                        trimCollapsedText: Strings.readMore,
                        trimExpandedText: Strings.showLess,
                        restaurantDetailItem.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox.square(dimension: 16),
                      MenuCategoryListView(
                        title: Strings.foods,
                        categories: restaurantDetailItem.menus.foods,
                      ),

                      const SizedBox.square(dimension: 8),
                      MenuCategoryListView(
                        title: Strings.drinks,
                        categories: restaurantDetailItem.menus.drinks,
                      ),

                      const SizedBox.square(dimension: 16),
                      ReviewsWidget(
                        customerReviews: restaurantDetailItem.customerReviews,
                      ),
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
