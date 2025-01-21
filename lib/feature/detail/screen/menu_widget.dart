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
  final List<Category> categories;

  const MenuCategoryListView({
    super.key,
    required this.title,
    required this.categories,
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
          height: 150,
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: RawScrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // picture menu
                        Image.asset(
                          'images/food.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),

                        // menu name
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Center(
                              child: Text(
                                maxLines: 1,
                                category.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
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
