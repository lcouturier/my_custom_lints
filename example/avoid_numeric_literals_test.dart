import 'dart:math';

int maxItems = 100;

const int maxItemsLimit = 100;
int otherMaxItems = maxItemsLimit;

const pi = 3.14;
double circleArea(double radius) => pi * pow(radius, 2); // Correct, moved to a named constant

const productCountThresholdForDiscount = 4;
const discount = 0.25;

final someDay = DateTime(2006, 12, 1);

final items = [1, 2, 3, 4, 5];
final sum = items.reduce((a, b) => a + b);
