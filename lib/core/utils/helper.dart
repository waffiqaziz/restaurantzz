class Helper {
  static String formatRating(String rating) {
    return rating.length == 1 ? "$rating.0" : rating;
  }
}
