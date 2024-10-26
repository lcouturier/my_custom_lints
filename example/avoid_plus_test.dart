// ignore_for_file: avoid_print

import 'extensions.dart';

void fn1() {
  final result = ["label1", "label2", 'label3', 'label4']
      .fold('', (p0, p1) => '$p0 $p1')
      .plus(element: ',')
      .plus(element: ',')
      .plus(element: ',')
      .plus(element: ',');
  print(result);
}

void fn2() {
  final result = ["label1", "label2", 'label3', 'label4'].fold('', (p0, p1) => '$p0 $p1').plus();
  print(result);
}
