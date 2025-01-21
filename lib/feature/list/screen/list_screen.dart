import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/networking/states/list_result_state.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';
import 'package:restaurantzz/static/navigation_route.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ListProvider>().fetchRestaurantList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant List"),
      ),
      body: Consumer<ListProvider>(
       builder: (context, value, child) {
         return switch (value.resultState) {
           RestaurantListLoadingState() => const Center(
               child: CircularProgressIndicator(),
             ),
           RestaurantListLoadedState(data: var restaurantList) => ListView.builder(
               itemCount: restaurantList.length,
               itemBuilder: (context, index) {
                 final restaurant = restaurantList[index];
 
                 return RestaurantCard(
                   restaurant: restaurant,
                   onTap: () {
                     Navigator.pushNamed(
                       context,
                       NavigationRoute.detailRoute.name,
                       arguments: restaurant.id,
                     );
                   },
                 );
               },
             ),
           RestaurantListErrorState(error: var message) => Center(
               child: Text(message),
             ),
           _ => const SizedBox(),
         };
       },
     ),
    );
  }
}
