import 'package:flutter/material.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'package:restaurantzz/core/common/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  final RestaurantListItem restaurant;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.grey.withOpacity(0.1),
      splashColor: const Color.fromARGB(255, 46, 106, 71).withOpacity(0.3),
      borderRadius: BorderRadius.circular(8.0),
      onTap: onTap,
      onHover: (isHovering) {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Material(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              Hero(
                tag: restaurant.id,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 80,
                    minHeight: 80,
                    maxWidth: 120,
                    minWidth: 120,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      Constants.imageURLSmallResolution + restaurant.pictureId,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox.square(dimension: 8),

              // description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // restaurant name
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    // rating bar
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: restaurant.rating,
                          itemCount: 5,
                          itemSize: 15.0,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          "(${restaurant.rating}/5.0)",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox.square(dimension: 6),

                    // city
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, size: 20),
                        const SizedBox.square(dimension: 4),
                        Expanded(
                          child: Text(
                            restaurant.city,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
