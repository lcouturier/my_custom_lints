// ignore_for_file: unused_field

enum TripMotive {
  personal,
  professional,
}

extension TripMotiveExtensions on TripMotive {
  String get name => toString().split('.').last;
}

enum DayChoiceState { DEFAULT, HOVER }

enum HighlightPainterStyle {
  none,
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
