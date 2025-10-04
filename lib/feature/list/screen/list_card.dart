import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:restaurantzz/core/common/constants.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.heroTag,
  });

  final Restaurant restaurant;
  final Function() onTap;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.grey.withValues(alpha: 0.1),
      splashColor: const Color.fromARGB(255, 46, 106, 71).withValues(alpha: 0.3),
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
                tag: "${restaurant.pictureId}_$heroTag",
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Image.asset('images/placeholder.webp', fit: BoxFit.cover);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('images/images_error.png', fit: BoxFit.cover);
                      },
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
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),

                    // rating bar
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: RatingBarIndicator(
                            rating: restaurant.rating,
                            itemCount: 5,
                            itemSize: 15.0,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Text(
                            "(${restaurant.rating}/5.0)",
                            style: Theme.of(context).textTheme.labelSmall,
                            textAlign: TextAlign.end,
                          ),
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
