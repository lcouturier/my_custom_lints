// ignore_for_file: unused_field, prefer_enum_with_sentinel_value

import 'package:flutter/material.dart';

enum TripMotive {
  personal,
  professional,
}

extension TripMotiveExtensions on TripMotive {
  String get name => toString().split('.').last;
}

enum DayChoiceState {
  DEFAULT,
  HOVER,
}

enum HighlightPainterStyle {
  highlightLeading,
  highlightTrailing,
  highlightAll,
}

enum EnumFileDisplayType {
  pdf,
  image,
  other,
}

enum _EnumPay {
  googlePay,
  applePay,
}

enum ColorNames {
  red(Colors.red),
  green(Color.fromARGB(255, 86, 86, 86)),
  blue(Colors.blue);

  final Color color;
  const ColorNames(this.color);
}

enum Medal {
  gold(categoryName: 'GOLD'),
  silver(categoryName: 'SILVER'),
  bronze(categoryName: 'BRONZE');

  final String categoryName;

  const Medal({required this.categoryName});
}

extension MedalStringExtension on String {
  Medal toMedal() => switch (this) {
        'GOLD' => Medal.gold,
        'SILVER' => Medal.silver,
        'BRONZE' => Medal.bronze,
        _ => Medal.bronze,
      };
}
