import 'package:flutter/material.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';

class ReviewsWidget extends StatelessWidget {
  final List<CustomerReview> customerReviews;

  const ReviewsWidget({super.key, required this.customerReviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.reviews,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox.square(dimension: 8),
            ExpansionTile(
              title: Text(Strings.seeReviews),
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 300.0,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: customerReviews.length,
                      itemBuilder: (context, index) {
                        final review = customerReviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // reviewer name
                                Text(
                                  review.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),

                                // date review
                                Text(
                                  review.date,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 12),

                                // review message
                                Text(
                                  review.review,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
