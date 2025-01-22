import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MenuCategoryListView extends StatelessWidget {
  final String title;
  final List<CustomerReview> customerReview;

  const MenuCategoryListView({
    super.key,
    required this.title,
    required this.customerReview,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(
          height: 400,
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: RawScrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                itemCount: customerReview.length,
                itemBuilder: (context, index) {
                  final data = customerReview[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          maxLines: 1,
                          data.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(data.review)
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
