import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';

class ReviewForm extends StatefulWidget {
  final String restaurantId;

  const ReviewForm({super.key, required this.restaurantId});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.addAReview,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),

              // name reviewer
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: Strings.yourName),
                validator: (value) => value?.isEmpty == true ? Strings.nameIsRequired : null,
              ),
              const SizedBox(height: 8.0),

              // review message
              TextFormField(
                controller: _reviewController,
                decoration: InputDecoration(labelText: Strings.yourReview),
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? Strings.reviewIsRequired : null,
              ),
              const SizedBox(height: 16.0),

              // submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    context.read<DetailProvider>().addReview(
                      widget.restaurantId,
                      _nameController.text,
                      _reviewController.text,
                    );

                    // clear the form
                    _nameController.clear();
                    _reviewController.clear();
                  }
                },
                child: Text(Strings.submitReview),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
