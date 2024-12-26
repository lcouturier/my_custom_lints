int calculateSum(int a, int b) {
  final sum = a + b;
  return sum; // LINT: Prefer returning the result immediately instead of declaring an intermediate variable right before the return statement.
}

class MyClass {
  int calculateSum(int a, int b) {
    final sum = a + b;
    return sum; // LINT: Prefer returning the result immediately instead of declaring an intermediate variable right before the return statement.
  }

  List<Itinerary> fetchHomeItinerariesFavorites() {
    final homeFavoritesItineraries = [
      Itinerary(),
      Itinerary(),
      Itinerary(),
    ];
    return homeFavoritesItineraries;
  }
}

class Itinerary {}
